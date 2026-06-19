import 'shift_model.dart';

/// Combined response model from GET /mobile/profile/schedules.
class ScheduleDataModel {
  final bool canChooseSchedule;
  final bool hasCheckedInToday;
  final int? currentScheduleId;
  final List<ShiftModel> availableSchedules;

  const ScheduleDataModel({
    required this.canChooseSchedule,
    required this.hasCheckedInToday,
    this.currentScheduleId,
    this.availableSchedules = const [],
  });

  factory ScheduleDataModel.fromJson(Map<String, dynamic> json) {
    return ScheduleDataModel(
      canChooseSchedule: json['can_choose_schedule'] as bool? ?? false,
      hasCheckedInToday: json['has_checked_in_today'] as bool? ?? false,
      currentScheduleId: json['current_schedule_id'] as int?,
      availableSchedules: (json['available_schedules'] as List<dynamic>?)
              ?.map((e) => ShiftModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
