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

  factory AttendanceHistorySummary.fromItems({
    required int month,
    required int year,
    required List<AttendanceHistoryItem> items,
  }) {
    final totals = <AttendanceDayStatus, int>{
      for (final status in AttendanceDayStatus.values) status: 0,
    };

    for (final item in items) {
      totals[item.status] = (totals[item.status] ?? 0) + 1;
    }

    return AttendanceHistorySummary(
      month: month,
      year: year,
      totals: totals,
    );
  }

  int countOf(AttendanceDayStatus status) => totals[status] ?? 0;

  int get totalDays =>
      totals.values.fold<int>(0, (previous, current) => previous + current);
}
