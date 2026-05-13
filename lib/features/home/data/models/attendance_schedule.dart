enum ScheduleStatus { active, dayOff, submitted, noSchedule }

class AttendanceSchedule {
  final String? shiftName;
  final String? checkInTime;
  final String? checkOutTime;
  final ScheduleStatus status;
  final String? message;

  const AttendanceSchedule({
    this.shiftName,
    this.checkInTime,
    this.checkOutTime,
    required this.status,
    this.message,
  });

  bool get isActive => status == ScheduleStatus.active;
}
