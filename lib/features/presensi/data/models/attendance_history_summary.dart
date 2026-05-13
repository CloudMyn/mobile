import 'attendance_history_item.dart';

class AttendanceHistorySummary {
  final int month;
  final int year;
  final Map<AttendanceDayStatus, int> totals;

  const AttendanceHistorySummary({
    required this.month,
    required this.year,
    required this.totals,
  });

  int countOf(AttendanceDayStatus status) => totals[status] ?? 0;

  int get totalDays =>
      totals.values.fold<int>(0, (previous, current) => previous + current);
}
