

enum AttendanceDayStatus {
  workday,
  offday,
  holiday,
  exempt,
  leave,
  permit,
  sick,
  wfh,
  wfa,
  outsideDuty,
  present,
  partial,
  absent,
}

extension AttendanceDayStatusExt on AttendanceDayStatus {
  static AttendanceDayStatus fromString(String value) {
    switch (value) {
      case 'workday': return AttendanceDayStatus.workday;
      case 'offday': return AttendanceDayStatus.offday;
      case 'holiday': return AttendanceDayStatus.holiday;
      case 'exempt': return AttendanceDayStatus.exempt;
      case 'leave': return AttendanceDayStatus.leave;
      case 'permit': return AttendanceDayStatus.permit;
      case 'sick': return AttendanceDayStatus.sick;
      case 'wfh': return AttendanceDayStatus.wfh;
      case 'wfa': return AttendanceDayStatus.wfa;
      case 'outside_duty': return AttendanceDayStatus.outsideDuty;
      case 'present': return AttendanceDayStatus.present;
      case 'partial': return AttendanceDayStatus.partial;
      case 'absent': return AttendanceDayStatus.absent;
      default: return AttendanceDayStatus.workday;
    }
  }
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

  factory AttendanceHistoryItem.fromJson(Map<String, dynamic> json) {
    final workDate = DateTime.parse(json['work_date'] as String);
    final statusStr = json['day_status'] as String? ?? 'workday';
    final status = AttendanceDayStatusExt.fromString(statusStr);

    String? checkIn;
    String? checkOut;

    final records = json['records'] as List<dynamic>? ?? [];
    for (final r in records) {
      final rec = r as Map<String, dynamic>;
      final type = rec['attendance_type'] as Map<String, dynamic>?;
      final attendedAtStr = rec['attended_at'] as String?;
      
      if (type != null && attendedAtStr != null) {
        final direction = type['direction'] as String?;
        final timeStr = attendedAtStr.substring(11, 16);
        
        if (direction == 'in' && checkIn == null) {
          checkIn = timeStr;
        } else if (direction == 'out') {
          checkOut = timeStr;
        }
      }
    }

    return AttendanceHistoryItem(
      date: workDate,
      status: status,
      label: getLabelForStatus(status),
      checkInTime: checkIn,
      checkOutTime: checkOut,
      note: json['summary_note'] as String?,
    );
  }

  static String getLabelForStatus(AttendanceDayStatus status) {
    return switch (status) {
      AttendanceDayStatus.workday => 'Hari Kerja',
      AttendanceDayStatus.offday => 'Hari Libur / Off',
      AttendanceDayStatus.holiday => 'Libur Nasional',
      AttendanceDayStatus.exempt => 'Dikecualikan',
      AttendanceDayStatus.leave => 'Cuti',
      AttendanceDayStatus.permit => 'Izin',
      AttendanceDayStatus.sick => 'Sakit',
      AttendanceDayStatus.wfh => 'WFH',
      AttendanceDayStatus.wfa => 'WFA',
      AttendanceDayStatus.outsideDuty => 'Dinas Luar',
      AttendanceDayStatus.present => 'Hadir',
      AttendanceDayStatus.partial => 'Hadir Sebagian',
      AttendanceDayStatus.absent => 'Alpa',
    };
  }
}

