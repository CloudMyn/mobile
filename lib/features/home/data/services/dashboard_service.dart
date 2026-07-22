import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/dashboard_model.dart';

/// Service untuk GET /mobile/dashboard — single request untuk home screen.
class DashboardService {
  DashboardService(this._dio);

  final Dio _dio;

  Future<DashboardModel> fetchDashboard() async {
    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/mobile/dashboard');
      return ApiResponse.fromJson(
        response.data!,
        (data) => DashboardModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiException) throw err;
      if (err is NetworkException) throw err;
      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Gagal memuat dashboard',
      );
    }
  }

  /// Status presensi hari ini — dipanggil untuk refresh ringan.
  Future<TodaySchedule?> fetchTodayPresensi({int shiftNo = 1}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/mobile/presensi',
        queryParameters: {'shift_no': shiftNo},
      );
      final data = response.data!['data'];
      if (data == null) return null;
      return TodaySchedule.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiException) throw err;
      if (err is NetworkException) throw err;
      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Gagal memuat data presensi',
      );
    }
  }

  /// Memulai WFH (Otomatis presensi In dan Out)
  Future<void> startWfh({int shiftNo = 1}) async {
    try {
      await _dio.post<Map<String, dynamic>>(
        '/mobile/presensi/wfh/start',
        data: {'shift_no': shiftNo},
      );
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiException) throw err;
      if (err is NetworkException) throw err;
      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Gagal memulai WFH',
      );
    }
  }
}
