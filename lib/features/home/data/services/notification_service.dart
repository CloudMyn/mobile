import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/notification_item.dart';

class NotificationService {
  NotificationService(this._dio);

  final Dio _dio;

  Future<List<NotificationItem>> fetchNotifications({int limit = 100}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/notifications',
        queryParameters: {'limit': limit},
      );

      final envelope = ApiResponse.fromJsonList(
        response.data!,
        NotificationItem.fromJson,
      );

      return envelope.data ?? const <NotificationItem>[];
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat notifikasi');
    }
  }

  Future<NotificationItem> markAsRead(String id) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        '/notifications/$id/read',
      );

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => NotificationItem.fromJson(data as Map<String, dynamic>),
      );

      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menandai notifikasi dibaca');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.post<Map<String, dynamic>>('/notifications/read-all');
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menandai semua notifikasi dibaca');
    }
  }

  Future<void> deleteAll() async {
    try {
      await _dio.delete<Map<String, dynamic>>('/notifications');
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menghapus semua notifikasi');
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
