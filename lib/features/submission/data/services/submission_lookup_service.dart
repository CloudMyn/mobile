import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/submission_item.dart';

class SubmissionLookupService {
  SubmissionLookupService(this._dio);

  final Dio _dio;

  Future<SubmissionItem> fetchSubmissionDetail(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/submissions/$id');
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => SubmissionItem.fromJson(data as Map<String, dynamic>),
      );

      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat detail pengajuan');
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
