class ShiftScheduleRuleModel {
  final int weekday;
  final bool isWorkday;
  final String? startTime;
  final String? endTime;
  final bool isOvernight;

  const ShiftScheduleRuleModel({
    required this.weekday,
    required this.isWorkday,
    this.startTime,
    this.endTime,
    this.isOvernight = false,
  });

  factory ShiftScheduleRuleModel.fromJson(Map<String, dynamic> json) {
    return ShiftScheduleRuleModel(
      weekday: json['weekday'] as int,
      isWorkday: json['is_workday'] as bool? ?? true,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      isOvernight: json['is_overnight'] as bool? ?? false,
    );
  }

  String get weekdayName {
    switch (weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return 'Hari $weekday';
    }
  }
}

class ShiftModel {
  final int id;
  final String code;
  final String name;
  final int? institutionId;
  final String? institutionName;
  final bool isActive;
  final List<ShiftScheduleRuleModel> rules;

  const ShiftModel({
    required this.id,
    required this.code,
    required this.name,
    this.institutionId,
    this.institutionName,
    required this.isActive,
    this.rules = const [],
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      institutionId: json['institution_id'] as int?,
      institutionName: json['institution_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      rules: (json['rules'] as List<dynamic>?)
              ?.map(
                  (e) => ShiftScheduleRuleModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Returns the rule for the given weekday (1=Monday .. 7=Sunday).
  ShiftScheduleRuleModel? ruleForWeekday(int weekday) {
    return rules.cast<ShiftScheduleRuleModel?>().firstWhere(
          (r) => r!.weekday == weekday,
          orElse: () => null,
        );
  }

  /// Returns the rule for today.
  ShiftScheduleRuleModel? get todayRule {
    final now = DateTime.now();
    // DateTime.weekday: 1=Monday .. 7=Sunday (matches ISO)
    return ruleForWeekday(now.weekday);
  }

  /// Returns formatted check-in time for today, or fallback from first workday rule.
  String get checkIn {
    final rule = todayRule ?? rules.firstWhere(
      (r) => r.isWorkday && r.startTime != null,
      orElse: () => rules.isNotEmpty ? rules.first : const ShiftScheduleRuleModel(weekday: 1, isWorkday: false),
    );
    return rule.startTime ?? '-';
  }

  /// Returns formatted check-out time for today, or fallback from first workday rule.
  String get checkOut {
    final rule = todayRule ?? rules.firstWhere(
      (r) => r.isWorkday && r.endTime != null,
      orElse: () => rules.isNotEmpty ? rules.first : const ShiftScheduleRuleModel(weekday: 1, isWorkday: false),
    );
    return rule.endTime ?? '-';
  }

  /// Whether this is a global schedule (not institution-specific).
  bool get isGlobal => institutionId == null;
}
