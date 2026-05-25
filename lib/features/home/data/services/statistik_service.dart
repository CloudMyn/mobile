import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/statistik_model.dart';

/// Service untuk GET /mobile/statistik
class StatistikService {
  StatistikService(this._dio);

  final Dio _dio;

  Future<StatistikModel> fetchStatistik({
    required int month,
    required int year,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/statistik',
        queryParameters: {'month': month, 'year': year},
      );
      return ApiResponse.fromJson(
        response.data!,
        (data) => StatistikModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiException) throw err;
      if (err is NetworkException) throw err;
      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Gagal memuat statistik',
      );
    }
  }
}
