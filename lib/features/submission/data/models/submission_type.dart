import 'package:flutter/material.dart';

class AttachmentFieldConfig {
  final String id;
  final String name;
  final bool isRequired;

  const AttachmentFieldConfig({
    required this.id,
    required this.name,
    required this.isRequired,
  });
}

class SubmissionType {
  final String id;
  final String name;
  final String description;
  final bool deductsLeaveBalance;
  final String approverName;
  final String approverPosition;
  final int maxDays;
  final bool allowDateRange;
  final bool allowTimeRange;
  final List<AttachmentFieldConfig> attachmentFields;
  final IconData icon;

  const SubmissionType({
    required this.id,
    required this.name,
    required this.description,
    required this.deductsLeaveBalance,
    required this.approverName,
    required this.approverPosition,
    required this.maxDays,
    required this.allowDateRange,
    required this.allowTimeRange,
    required this.attachmentFields,
    required this.icon,
  });
}
