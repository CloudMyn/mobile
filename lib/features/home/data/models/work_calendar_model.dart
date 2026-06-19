class WorkCalendarModel {
  const WorkCalendarModel({
    required this.id,
    required this.institutionId,
    required this.calendarDate,
    required this.dayType,
    this.holiday,
    this.note,
  });

  final int id;
  final int institutionId;
  final DateTime calendarDate;
  final String dayType; // 'workday', 'holiday', 'weekend'
  final HolidayModel? holiday;
  final String? note;

  factory WorkCalendarModel.fromJson(Map<String, dynamic> json) {
    return WorkCalendarModel(
      id: json['id'] as int,
      institutionId: json['institution_id'] as int,
      calendarDate: DateTime.parse(json['calendar_date'] as String),
      dayType: json['day_type'] as String? ?? 'workday',
      holiday: json['holiday'] != null
          ? HolidayModel.fromJson(json['holiday'] as Map<String, dynamic>)
          : null,
      note: json['note'] as String?,
    );
  }

  bool get isWorkday => dayType == 'workday';
  bool get isHoliday => dayType == 'holiday';
  bool get isWeekend => dayType == 'weekend';
}

class HolidayModel {
  const HolidayModel({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }
}
