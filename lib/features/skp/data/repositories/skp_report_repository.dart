import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/paginated_result.dart';
import '../models/skp_report_model.dart';

abstract class SkpReportRepository {
  Future<PaginatedResult<SkpReportModel>> getReports({
    int page = 1,
    int? month,
    int? year,
    String? status,
  });

  Future<PaginatedResult<SkpReportModel>> getSubordinateReports({
    int page = 1,
    int? month,
    int? year,
    String? status,
    int? userId,
  });

  Future<SkpReportModel> uploadReport({
    required File file,
    required int periodMonth,
    required int periodYear,
    Map<String, dynamic>? jsonExtractedData,
  });

  Future<SkpReportModel> show(int id);

  Future<void> deleteReport(int id);

  Future<SkpReportModel> verifyReport(
    int id, {
    required String status,
    String? rejectionNote,
  });
}

class ApiSkpReportRepository implements SkpReportRepository {
  final Dio _dio;

  ApiSkpReportRepository(this._dio);

  @override
  Future<PaginatedResult<SkpReportModel>> getReports({
    int page = 1,
    int? month,
    int? year,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
      };
      if (month != null) queryParams['period_month'] = month;
      if (year != null) queryParams['period_year'] = year;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;

      final response = await _dio.get<Map<String, dynamic>>(
        '/skp-reports',
        queryParameters: queryParams,
      );

      final envelope = ApiResponse.fromJsonList<SkpReportModel>(
        response.data!,
        SkpReportModel.fromJson,
      );

      return PaginatedResult<SkpReportModel>(
        items: envelope.data ?? [],
        meta: envelope.meta ??
            ApiMeta(
              currentPage: page,
              perPage: 15,
              total: envelope.data?.length ?? 0,
              lastPage: page,
            ),
      );
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat laporan SKP');
    }
  }

  @override
  Future<PaginatedResult<SkpReportModel>> getSubordinateReports({
    int page = 1,
    int? month,
    int? year,
    String? status,
    int? userId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
      };
      if (month != null) queryParams['period_month'] = month;
      if (year != null) queryParams['period_year'] = year;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (userId != null) queryParams['user_id'] = userId;

      final response = await _dio.get<Map<String, dynamic>>(
        '/skp-reports/subordinates',
        queryParameters: queryParams,
      );

      final envelope = ApiResponse.fromJsonList<SkpReportModel>(
        response.data!,
        SkpReportModel.fromJson,
      );

      return PaginatedResult<SkpReportModel>(
        items: envelope.data ?? [],
        meta: envelope.meta ??
            ApiMeta(
              currentPage: page,
              perPage: 15,
              total: envelope.data?.length ?? 0,
              lastPage: page,
            ),
      );
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat laporan SKP bawahan');
    }
  }

  @override
  Future<SkpReportModel> uploadReport({
    required File file,
    required int periodMonth,
    required int periodYear,
    Map<String, dynamic>? jsonExtractedData,
  }) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final formMap = <String, dynamic>{
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'period_month': periodMonth,
        'period_year': periodYear,
      };

      if (jsonExtractedData != null && jsonExtractedData.isNotEmpty) {
        jsonExtractedData.forEach((key, value) {
          formMap['json_extracted_data[$key]'] = value;
        });
      }

      final formData = FormData.fromMap(formMap);

      final response = await _dio.post<Map<String, dynamic>>(
        '/skp-reports',
        data: formData,
      );

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => SkpReportModel.fromJson(data as Map<String, dynamic>),
      );

      if (envelope.data == null) {
        throw const ApiException(
          statusCode: 500,
          message: 'Data laporan SKP kosong dari server',
        );
      }

      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal mengunggah laporan SKP');
    }
  }

  @override
  Future<SkpReportModel> show(int id) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/skp-reports/$id',
      );

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => SkpReportModel.fromJson(data as Map<String, dynamic>),
      );

      if (envelope.data == null) {
        throw const ApiException(
          statusCode: 404,
          message: 'Laporan SKP tidak ditemukan',
        );
      }

      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat detail laporan SKP');
    }
  }

  @override
  Future<void> deleteReport(int id) async {
    try {
      await _dio.delete<Map<String, dynamic>>('/skp-reports/$id');
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menghapus laporan SKP');
    }
  }

  @override
  Future<SkpReportModel> verifyReport(
    int id, {
    required String status,
    String? rejectionNote,
  }) async {
    try {
      final payload = <String, dynamic>{
        'status': status,
      };
      if (rejectionNote != null && rejectionNote.isNotEmpty) {
        payload['rejection_note'] = rejectionNote;
      }

      final response = await _dio.patch<Map<String, dynamic>>(
        '/skp-reports/$id/verify',
        data: payload,
      );

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => SkpReportModel.fromJson(data as Map<String, dynamic>),
      );

      if (envelope.data == null) {
        throw const ApiException(
          statusCode: 500,
          message: 'Gagal memperbarui verifikasi laporan',
        );
      }

      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memverifikasi laporan SKP');
    }
  }

  Exception _mapDioError(DioException e, String fallbackMessage) {
    final err = e.error;
    if (err is ValidationException) return err;
    if (err is ApiException) return err;
    if (err is NetworkException) return err;

    return ApiException(
      statusCode: e.response?.statusCode ?? 0,
      message: e.message ?? fallbackMessage,
    );
  }
}
