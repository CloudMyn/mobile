import 'dart:io';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/submission_item.dart';
import '../models/submission_type.dart';

abstract class SubmissionService {
  Future<List<SubmissionType>> fetchTypes();
  Future<List<SubmissionItem>> fetchSubmissions({int? typeId, SubmissionStatus? status});
  Future<SubmissionItem> createSubmission({
    required int typeId,
    required String title,
    required String description,
    required DateTime startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    Map<String, String?>? attachments,
    bool autoSubmit = false,
    bool isWfhFromHome = false,
  });
  Future<SubmissionItem> submitDraft(int id);
  Future<void> deleteSubmission(int id);
}

class ApiSubmissionService implements SubmissionService {
  final Dio _dio;

  ApiSubmissionService(this._dio);

  @override
  Future<List<SubmissionType>> fetchTypes() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/submission-types');
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => (data as List).map((e) => SubmissionType.fromJson(e as Map<String, dynamic>)).toList(),
      );
      return envelope.data ?? [];
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat jenis pengajuan');
    }
  }

  @override
  Future<List<SubmissionItem>> fetchSubmissions({int? typeId, SubmissionStatus? status}) async {
    try {
      final Map<String, dynamic> params = {'per_page': 100};
      if (typeId != null) params['submission_type_id'] = typeId;
      if (status != null) params['status'] = status.name;

      final response = await _dio.get<Map<String, dynamic>>(
        '/submissions',
        queryParameters: params,
      );

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) {
          final items = data is Map ? data['data'] as List : data as List;
          return items.map((e) => SubmissionItem.fromJson(e as Map<String, dynamic>)).toList();
        },
      );

      return envelope.data ?? [];
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat data pengajuan');
    }
  }

  @override
  Future<SubmissionItem> createSubmission({
    required int typeId,
    required String title,
    required String description, // Maps to reason
    required DateTime startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    Map<String, String?>? attachments, // key: document_id (string format of int), value: file path
    bool autoSubmit = false,
    bool isWfhFromHome = false,
  }) async {
    try {
      final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
      
      final Map<String, dynamic> data = {
        'submission_type_id': typeId,
        'start_date': dateFormat.format(startDate),
        'reason': description,
        'auto_submit': autoSubmit ? 1 : 0,
        if (isWfhFromHome) 'is_wfh_from_home': 1,
      };

      if (endDate != null) data['end_date'] = dateFormat.format(endDate);
      if (startTime != null && startTime.isNotEmpty) data['start_time'] = startTime;
      if (endTime != null && endTime.isNotEmpty) data['end_time'] = endTime;

      bool hasAttachments = attachments != null && attachments.isNotEmpty;
      
      var formData = FormData.fromMap(data);
      
      if (hasAttachments) {
        int index = 0;
        for (var entry in attachments.entries) {
          if (entry.value != null && entry.value!.isNotEmpty) {
            final file = File(entry.value!);
            if (await file.exists()) {
              formData.files.add(MapEntry(
                'attachments[$index]',
                await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
              ));
              formData.fields.add(MapEntry('attachment_document_ids[$index]', entry.key));
              index++;
            }
          }
        }
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/submissions',
        data: formData,
      );

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => SubmissionItem.fromJson(data as Map<String, dynamic>),
      );

      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal membuat pengajuan');
    }
  }

  @override
  Future<SubmissionItem> submitDraft(int id) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>('/submissions/$id/submit');
      
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => SubmissionItem.fromJson(data as Map<String, dynamic>),
      );

      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal mengajukan draft');
    }
  }

  @override
  Future<void> deleteSubmission(int id) async {
    try {
      await _dio.delete('/submissions/$id');
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menghapus pengajuan');
    }
  }

  Exception _mapDioError(DioException e, String fallbackMessage) {
    final err = e.error;
    if (err is ApiException) return err;
    if (err is NetworkException) return err;

    return ApiException(
      statusCode: e.response?.statusCode ?? 0,
      message: e.message ?? fallbackMessage,
    );
  }
}
