import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/subordinate_submission_item.dart';
import '../models/submission_item.dart';

abstract class SubordinateSubmissionService {
  Future<List<SubordinateSubmissionItem>> fetchSubordinateSubmissions({
    required SubmissionStatus status,
  });
  Future<SubordinateSubmissionItem> approveSubmission(int id, String? note);
  Future<SubordinateSubmissionItem> rejectSubmission(int id, String reason);
}

class ApiSubordinateSubmissionService implements SubordinateSubmissionService {
  final Dio _dio;

  ApiSubordinateSubmissionService(this._dio);

  @override
  Future<List<SubordinateSubmissionItem>> fetchSubordinateSubmissions({
    required SubmissionStatus status,
  }) async {
    try {
      final statusString = status.name; // 'pending', 'approved', 'rejected'
      final response = await _dio.get<Map<String, dynamic>>(
        '/submissions/subordinates',
        queryParameters: {
          'status': statusString,
          'per_page': 100, // Fetch more for local filtering or implement pagination
        },
      );

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => (data as List)
            .map((e) => SubordinateSubmissionItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      return envelope.data ?? [];
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat pengajuan bawahan');
    }
  }

  @override
  Future<SubordinateSubmissionItem> approveSubmission(int id, String? note) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/submissions/approvals/$id/approve',
        data: note != null && note.isNotEmpty ? {'note': note} : {},
      );

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => SubordinateSubmissionItem.fromJson(data as Map<String, dynamic>),
      );

      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menyetujui pengajuan');
    }
  }

  @override
  Future<SubordinateSubmissionItem> rejectSubmission(int id, String reason) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/submissions/approvals/$id/reject',
        data: {'note': reason},
      );

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => SubordinateSubmissionItem.fromJson(data as Map<String, dynamic>),
      );

      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menolak pengajuan');
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
