import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/supervisor_request_model.dart';

abstract class SupervisorRequestRepository {
  Future<ApiResponse<List<SupervisorRequestModel>>> getHistory({int page = 1, int perPage = 10});
  Future<ApiResponse<List<SupervisorRequestModel>>> getApprovals({int page = 1, int perPage = 10});
  Future<SupervisorRequestModel> submitRequest({required int supervisorId, String? reason});
  Future<SupervisorRequestModel> approveRequest(int requestId);
  Future<SupervisorRequestModel> rejectRequest({required int requestId, String? reason});
  Future<List<Map<String, dynamic>>> searchUsers(String query);
}

class SupervisorRequestRepositoryImpl implements SupervisorRequestRepository {
  final Dio _dio;

  SupervisorRequestRepositoryImpl(this._dio);

  Exception _mapDioError(DioException e, String fallbackMessage) {
    final err = e.error;
    if (err is ApiException) return err;
    if (err is NetworkException) return err;
    return ApiException(
      statusCode: e.response?.statusCode ?? 0,
      message: e.message ?? fallbackMessage,
    );
  }

  @override
  Future<ApiResponse<List<SupervisorRequestModel>>> getHistory({int page = 1, int perPage = 10}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/employee-data/supervisor-requests',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      return ApiResponse.fromJsonList(
        response.data!,
        (data) => SupervisorRequestModel.fromJson(data),
      );
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat riwayat pengajuan');
    }
  }

  @override
  Future<ApiResponse<List<SupervisorRequestModel>>> getApprovals({int page = 1, int perPage = 10}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/employee-data/supervisor-requests/approvals',
        queryParameters: {'page': page, 'per_page': perPage},
      );

      return ApiResponse.fromJsonList(
        response.data!,
        (data) => SupervisorRequestModel.fromJson(data),
      );
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat daftar persetujuan');
    }
  }

  @override
  Future<SupervisorRequestModel> submitRequest({required int supervisorId, String? reason}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/employee-data/supervisor-requests',
        data: {
          'requested_supervisor_id': supervisorId,
          'reason': reason,
        },
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => SupervisorRequestModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal mengajukan atasan');
    }
  }

  @override
  Future<SupervisorRequestModel> approveRequest(int requestId) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/employee-data/supervisor-requests/$requestId/approve',
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => SupervisorRequestModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menyetujui pengajuan');
    }
  }

  @override
  Future<SupervisorRequestModel> rejectRequest({required int requestId, String? reason}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/employee-data/supervisor-requests/$requestId/reject',
        data: {'reason': reason},
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => SupervisorRequestModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menolak pengajuan');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/users/reference',
        queryParameters: {'search': query},
      );

      return List<Map<String, dynamic>>.from(response.data!['data'] as List);
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal mencari pengguna');
    }
  }
}
