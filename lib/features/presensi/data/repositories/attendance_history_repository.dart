import 'package:dio/dio.dart';
import '../models/attendance_history_item.dart';

abstract class AttendanceHistoryRepository {
  Future<List<AttendanceHistoryItem>> fetchMonthlyHistory({
    required int month,
    required int year,
  });
}

class ApiAttendanceHistoryRepository implements AttendanceHistoryRepository {
  final Dio _dio;

  ApiAttendanceHistoryRepository(this._dio);

  @override
  Future<List<AttendanceHistoryItem>> fetchMonthlyHistory({
    required int month,
    required int year,
  }) async {
    try {
      final response = await _dio.get(
        '/attendance/my-records',
        queryParameters: {
          'month': month,
          'year': year,
          'per_page': 31,
        },
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      
      return data
          .map((json) => AttendanceHistoryItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Re-throw or handle specific exceptions
      rethrow;
    }
  }
}
