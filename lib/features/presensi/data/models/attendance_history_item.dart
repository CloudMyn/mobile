enum AttendanceDayStatus {
  present,
  absent,
  weekend,
  holiday,
  noSchedule,
  permission,
  leave,
}

class AttendanceHistoryItem {
  final DateTime date;
  final AttendanceDayStatus status;
  final String label;
  final String? checkInTime;
  final String? checkOutTime;
  final String? note;

  const AttendanceHistoryItem({
    required this.date,
    required this.status,
    required this.label,
    this.checkInTime,
    this.checkOutTime,
    this.note,
  });
}
