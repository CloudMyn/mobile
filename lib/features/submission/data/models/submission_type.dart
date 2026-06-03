import 'package:flutter/material.dart';

class SubmissionType {
  final int id;
  final String code;
  final String name;
  final String? description;
  final bool deductsLeaveBalance;
  final String? approverName;
  final String? approverPosition;
  final int? maxDays;
  final bool allowDateRange;
  final bool allowTimeRange;
  final List<AttachmentFieldConfig> attachmentFields;
  final double defaultYearlyQuota;
  final bool allowCarryForward;
  final double? maxCarryForwardDays;
  final bool isActive;

  const SubmissionType({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    this.deductsLeaveBalance = false,
    this.approverName,
    this.approverPosition,
    this.maxDays,
    this.allowDateRange = false,
    this.allowTimeRange = false,
    this.attachmentFields = const [],
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
      description: json['description'] as String?,
      deductsLeaveBalance: json['deducts_leave_balance'] as bool? ?? false,
      approverName: json['approver_name'] as String?,
      approverPosition: json['approver_position'] as String?,
      maxDays: json['max_days'] as int?,
      allowDateRange: json['allow_date_range'] as bool? ?? false,
      allowTimeRange: json['allow_time_range'] as bool? ?? false,
      attachmentFields: (json['attachment_fields'] as List?)
              ?.map((e) => AttachmentFieldConfig(
                    id: e['id'] as String? ?? '',
                    name: e['name'] as String? ?? '',
                    isRequired: e['is_required'] as bool? ?? false,
                  ))
              .toList() ??
          const [],
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

class AttachmentFieldConfig {
  final String id;
  final String name;
  final bool isRequired;

  const AttachmentFieldConfig({
    required this.id,
    required this.name,
    this.isRequired = false,
  });
}
