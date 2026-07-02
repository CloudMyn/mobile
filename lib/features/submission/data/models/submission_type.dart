import 'package:flutter/material.dart';

class SubmissionType {
  final int id;
  final String code;
  final String name;
  final String? description;
  final bool deductsLeaveBalance;
  final String? approverName;
  final String? approverPosition;
  final int? maxDaysPerRequest;
  final bool requiresDateRange;
  final bool requiresTimeRange;
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
    this.maxDaysPerRequest,
    this.requiresDateRange = false,
    this.requiresTimeRange = false,
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
      deductsLeaveBalance: json['uses_leave_balance'] as bool? ?? false,
      approverName: json['approver_name'] as String?,
      approverPosition: json['approver_position'] as String?,
      maxDaysPerRequest: json['max_days_per_request'] as int?,
      requiresDateRange: json['requires_date_range'] as bool? ?? false,
      requiresTimeRange: json['requires_time_range'] as bool? ?? false,
      attachmentFields: (json['documents'] as List?)
              ?.map((e) => AttachmentFieldConfig(
                    id: e['id'].toString(),
                    name: e['name'] as String? ?? '',
                    description: e['description'] as String?,
                    isRequired: e['is_required'] as bool? ?? false,
                    allowedExtensions: (e['allowed_extensions'] as List?)
                            ?.map((ext) => ext.toString())
                            .toList() ??
                        [],
                    maxFileSizeKb: e['max_file_size_kb'] as int?,
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
        'CUTI' => Icons.beach_access_rounded,
        'IZIN_SAKIT' => Icons.local_hospital_rounded,
        'WFH' || 'WFA' => Icons.laptop_mac_rounded,
        'DINAS_LUAR' || 'DINAS_DALAM' => Icons.flight_rounded,
        'ERROR_DEVICE' => Icons.warning_amber_rounded,
        _ => Icons.description_rounded,
      };
}

class AttachmentFieldConfig {
  final String id;
  final String name;
  final String? description;
  final bool isRequired;
  final List<String> allowedExtensions;
  final int? maxFileSizeKb;

  const AttachmentFieldConfig({
    required this.id,
    required this.name,
    this.description,
    this.isRequired = false,
    this.allowedExtensions = const [],
    this.maxFileSizeKb,
  });
}
