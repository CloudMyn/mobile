import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:presensi/core/logging/request_log_db.dart';
import 'package:presensi/core/logging/request_log_entry.dart';

/// Dio interceptor yang mencatat setiap request/response ke SQLite.
///
/// Dipasang di Dio interceptor chain sebelum LogInterceptor (debug console).
/// Authorization token di-mask sebelum disimpan untuk keamanan.
class RequestLogInterceptor extends Interceptor {
  RequestLogInterceptor(this._db);

  final RequestLogDb _db;

  /// Key untuk menyimpan start time di request extras.
  static const _startTimeKey = '_request_log_start_ms';

  /// Batas maksimum body yang disimpan (10 KB).
  static const _maxBodySize = 10 * 1024;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Catat waktu mulai request
    options.extra[_startTimeKey] = DateTime.now().millisecondsSinceEpoch;
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _saveLog(
      requestOptions: response.requestOptions,
      statusCode: response.statusCode,
      responseData: response.data,
      isError: false,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _saveLog(
      requestOptions: err.requestOptions,
      statusCode: err.response?.statusCode,
      responseData: err.response?.data,
      isError: true,
    );
    handler.next(err);
  }

  /// Simpan log entry ke database (fire-and-forget).
  void _saveLog({
    required RequestOptions requestOptions,
    int? statusCode,
    dynamic responseData,
    required bool isError,
  }) {
    try {
      final startMs = requestOptions.extra[_startTimeKey] as int?;
      final durationMs = startMs != null
          ? DateTime.now().millisecondsSinceEpoch - startMs
          : 0;

      // Headers — mask Authorization
      final headers = Map<String, dynamic>.from(requestOptions.headers);
      if (headers.containsKey('Authorization')) {
        final auth = headers['Authorization'] as String?;
        if (auth != null && auth.length > 15) {
          headers['Authorization'] = '${auth.substring(0, 15)}...***';
        }
      }

      // Request body
      final requestBody = _encodeBody(requestOptions.data);
      final requestSize = requestBody?.length ?? 0;

      // Response body
      final responseBody = _encodeBody(responseData);
      final responseSize = responseBody?.length ?? 0;

      final entry = RequestLogEntry(
        method: requestOptions.method,
        url: requestOptions.uri.toString(),
        requestHeaders: _encodeBody(headers),
        requestBody: _truncate(requestBody),
        requestSize: requestSize,
        statusCode: statusCode,
        responseBody: _truncate(responseBody),
        responseSize: responseSize,
        durationMs: durationMs,
        timestamp: DateTime.now(),
        isError: isError,
      );

      // Fire-and-forget — jangan block request pipeline
      _db.insertLog(entry);
    } catch (_) {
      // Jangan sampai logging mengganggu flow utama
    }
  }

  /// Encode data ke JSON string.
  String? _encodeBody(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is FormData) {
      // FormData (multipart) — log field names saja, bukan file content
      final fields = <String, dynamic>{};
      for (final field in data.fields) {
        fields[field.key] = field.value;
      }
      for (final file in data.files) {
        fields[file.key] = '[File: ${file.value.filename ?? 'unknown'}]';
      }
      return jsonEncode(fields);
    }
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  /// Potong string jika melebihi batas.
  String? _truncate(String? str) {
    if (str == null) return null;
    if (str.length <= _maxBodySize) return str;
    return '${str.substring(0, _maxBodySize)}\n\n... [truncated, total ${str.length} chars]';
  }
}
