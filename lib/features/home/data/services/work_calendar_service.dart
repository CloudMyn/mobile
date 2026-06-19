import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../models/work_calendar_model.dart';

class WorkCalendarService extends GetxService {
  final Dio _dio;

  WorkCalendarService(this._dio);

  Future<List<WorkCalendarModel>> getMyWorkCalendar({
    required int year,
    required int month,
  }) async {
    final response = await _dio.get(
      '/work-calendars/me',
      queryParameters: {
        'year': year.toString(),
        'month': month.toString(),
      },
    );

    final data = response.data['data'] as List;
    return data.map((json) => WorkCalendarModel.fromJson(json)).toList();
  }
}
