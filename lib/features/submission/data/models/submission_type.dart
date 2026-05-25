import 'package:flutter/material.dart';

class SubmissionType {
  final int id;
  final String code;
  final String name;
  final double defaultYearlyQuota;
  final bool allowCarryForward;
  final double? maxCarryForwardDays;
  final bool isActive;

  const SubmissionType({
    required this.id,
    required this.code,
    required this.name,
    required this.defaultYearlyQuota,
    required this.allowCarryForward,
    this.maxCarryForwardDays,
    required this.isActive,
  });

  factory SubmissionType.fromJson(Map<String, dynamic> json) {
    return SubmissionType(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      defaultYearlyQuota:
          (json['default_yearly_quota'] as num?)?.toDouble() ?? 0,
      allowCarryForward: json['allow_carry_forward'] as bool? ?? false,
      maxCarryForwardDays:
          (json['max_carry_forward_days'] as num?)?.toDouble(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  bool get hasQuota => defaultYearlyQuota > 0;

  IconData get icon => switch (code) {
        'annual_leave' => Icons.beach_access_rounded,
        'sick_leave' => Icons.local_hospital_rounded,
        'maternity_leave' => Icons.pregnant_woman_rounded,
        'paternity_leave' => Icons.family_restroom_rounded,
        'official_trip' || 'dinas_luar' => Icons.flight_rounded,
        'permission' || 'izin' => Icons.event_busy_rounded,
        _ => Icons.description_rounded,
      };
}
