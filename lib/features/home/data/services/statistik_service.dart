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

  Future<List<int>> downloadAttendanceReportPdf({
    required int year,
    required int month,
    String scope = 'monthly',
    String? date,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'year': year,
        'month': month,
        'scope': scope,
      };
      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      final response = await _dio.get<List<int>>(
        '/reports/attendance/my/pdf',
        queryParameters: queryParams,
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? [];
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiException) throw err;
      if (err is NetworkException) throw err;
      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Gagal mengunduh laporan PDF presensi',
      );
    }
  }

  Future<List<int>> downloadTppReportPdf({
    required int year,
    required int month,
    required int userId,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        '/reports/tpp/user/$userId/pdf',
        queryParameters: {
          'year': year,
          'month': month,
        },
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data ?? [];
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiException) throw err;
      if (err is NetworkException) throw err;
      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Gagal mengunduh laporan PDF TPP',
      );
    }
  }
}

