import 'dart:convert';

/// Model data untuk satu entry log request/response.
class RequestLogEntry {
  const RequestLogEntry({
    this.id,
    required this.method,
    required this.url,
    this.requestHeaders,
    this.requestBody,
    this.requestSize = 0,
    this.statusCode,
    this.responseBody,
    this.responseSize = 0,
    this.durationMs = 0,
    required this.timestamp,
    this.isError = false,
  });

  final int? id;
  final String method;
  final String url;
  final String? requestHeaders;
  final String? requestBody;
  final int requestSize;
  final int? statusCode;
  final String? responseBody;
  final int responseSize;
  final int durationMs;
  final DateTime timestamp;
  final bool isError;

  /// Buat salinan RequestLogEntry dengan field yang diubah.
  RequestLogEntry copyWith({
    int? id,
    String? method,
    String? url,
    String? requestHeaders,
    String? requestBody,
    int? requestSize,
    int? statusCode,
    String? responseBody,
    int? responseSize,
    int? durationMs,
    DateTime? timestamp,
    bool? isError,
  }) {
    return RequestLogEntry(
      id: id ?? this.id,
      method: method ?? this.method,
      url: url ?? this.url,
      requestHeaders: requestHeaders ?? this.requestHeaders,
      requestBody: requestBody ?? this.requestBody,
      requestSize: requestSize ?? this.requestSize,
      statusCode: statusCode ?? this.statusCode,
      responseBody: responseBody ?? this.responseBody,
      responseSize: responseSize ?? this.responseSize,
      durationMs: durationMs ?? this.durationMs,
      timestamp: timestamp ?? this.timestamp,
      isError: isError ?? this.isError,
    );
  }

  /// Buat dari Map (SQLite row).
  factory RequestLogEntry.fromMap(Map<String, dynamic> map) {
    return RequestLogEntry(
      id: map['id'] as int?,
      method: map['method'] as String,
      url: map['url'] as String,
      requestHeaders: map['request_headers'] as String?,
      requestBody: map['request_body'] as String?,
      requestSize: map['request_size'] as int? ?? 0,
      statusCode: map['status_code'] as int?,
      responseBody: map['response_body'] as String?,
      responseSize: map['response_size'] as int? ?? 0,
      durationMs: map['duration_ms'] as int? ?? 0,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isError: (map['is_error'] as int? ?? 0) == 1,
    );
  }

  /// Konversi ke Map untuk insert ke SQLite.
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'method': method,
      'url': url,
      'request_headers': requestHeaders,
      'request_body': requestBody,
      'request_size': requestSize,
      'status_code': statusCode,
      'response_body': responseBody,
      'response_size': responseSize,
      'duration_ms': durationMs,
      'timestamp': timestamp.toIso8601String(),
      'is_error': isError ? 1 : 0,
    };
  }

  /// Format log entry sebagai teks readable (untuk copy ke clipboard).
  String toReadableText() {
    final buffer = StringBuffer();
    buffer.writeln('═══ Request Log ═══');
    buffer.writeln('Method: $method');
    buffer.writeln('URL: $url');
    buffer.writeln('Status: ${statusCode ?? 'N/A'}');
    buffer.writeln('Duration: ${durationMs}ms');
    buffer.writeln('Time: ${timestamp.toLocal()}');
    buffer.writeln('Request Size: ${_formatBytes(requestSize)}');
    buffer.writeln('Response Size: ${_formatBytes(responseSize)}');
    buffer.writeln();

    if (requestHeaders != null && requestHeaders!.isNotEmpty) {
      buffer.writeln('── Request Headers ──');
      buffer.writeln(_prettyJson(requestHeaders!));
      buffer.writeln();
    }

    if (requestBody != null && requestBody!.isNotEmpty) {
      buffer.writeln('── Request Body ──');
      buffer.writeln(_prettyJson(requestBody!));
      buffer.writeln();
    }

    if (responseBody != null && responseBody!.isNotEmpty) {
      buffer.writeln('── Response Body ──');
      buffer.writeln(_prettyJson(responseBody!));
    }

    return buffer.toString();
  }

  /// Print log entry ke console/terminal dengan format dan ANSI warna.
  void printColoredToConsole() {
    const reset = '\x1B[0m';
    const bold = '\x1B[1m';
    const underline = '\x1B[4m';
    
    const blue = '\x1B[34m';

    const boldRed = '\x1B[1;31m';
    const boldGreen = '\x1B[1;32m';
    const boldYellow = '\x1B[1;33m';
    const boldBlue = '\x1B[1;34m';
    const boldMagenta = '\x1B[1;35m';
    const boldCyan = '\x1B[1;36m';

    String methodColor = boldCyan;
    switch (method.toUpperCase()) {
      case 'GET':
        methodColor = boldGreen;
        break;
      case 'POST':
        methodColor = boldBlue;
        break;
      case 'PUT':
        methodColor = boldYellow;
        break;
      case 'DELETE':
        methodColor = boldRed;
        break;
    }

    final statusColor = isError ? boldRed : boldGreen;

    final buffer = StringBuffer();
    buffer.writeln('$boldCyan═══════════════════════════════════ Request Log ═══════════════════════════════════$reset');
    buffer.writeln('${bold}Method:$reset $methodColor$method$reset');
    buffer.writeln('${bold}URL:$reset $underline$blue$url$reset');
    buffer.writeln('${bold}Status:$reset $statusColor${statusCode ?? "N/A"}$reset');
    buffer.writeln('${bold}Duration:$reset $boldYellow${durationMs}ms$reset');
    buffer.writeln('${bold}Time:$reset ${timestamp.toLocal()}');
    buffer.writeln('${bold}Request Size:$reset ${_formatBytes(requestSize)}');
    buffer.writeln('${bold}Response Size:$reset ${_formatBytes(responseSize)}');
    buffer.writeln();

    if (requestHeaders != null && requestHeaders!.isNotEmpty) {
      buffer.writeln('$boldMagenta── Request Headers ──$reset');
      buffer.writeln(_prettyJson(requestHeaders!));
      buffer.writeln();
    }

    if (requestBody != null && requestBody!.isNotEmpty) {
      buffer.writeln('$boldYellow── Request Body ──$reset');
      buffer.writeln(_prettyJson(requestBody!));
      buffer.writeln();
    }

    if (responseBody != null && responseBody!.isNotEmpty) {
      final responseHeaderColor = isError ? boldRed : boldGreen;
      buffer.writeln('$responseHeaderColor── Response Body ──$reset');
      buffer.writeln(_prettyJson(responseBody!));
    }
    buffer.writeln('$boldCyan══════════════════════════════════════════════════════════════════════════════════════════$reset');

    print(buffer.toString());
  }

  String _prettyJson(String jsonStr) {
    try {
      final decoded = jsonDecode(jsonStr);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return jsonStr;
    }
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Helper untuk format bytes (dipakai di UI juga).
  static String formatBytes(int bytes) => _formatBytes(bytes);
}
