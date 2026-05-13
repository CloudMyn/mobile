import 'package:flutter/material.dart';

enum SubmissionStatus { pending, approved, rejected }

extension SubmissionStatusExt on SubmissionStatus {
  String get label => switch (this) {
        SubmissionStatus.pending => 'Menunggu',
        SubmissionStatus.approved => 'Disetujui',
        SubmissionStatus.rejected => 'Ditolak',
      };
}

class SubmissionItem {
  final String id;
  final String typeId;
  final String typeName;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime? endDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final SubmissionStatus status;
  final DateTime createdAt;
  final List<String> attachmentNames;
  final String? approvalNote;

  const SubmissionItem({
    required this.id,
    required this.typeId,
    required this.typeName,
    required this.title,
    required this.description,
    required this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    required this.status,
    required this.createdAt,
    this.attachmentNames = const [],
    this.approvalNote,
  });

  String get formattedDate {
    final start = _formatDate(startDate);
    if (endDate == null) return start;
    return '$start – ${_formatDate(endDate!)}';
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  SubmissionItem copyWith({SubmissionStatus? status, String? approvalNote}) =>
      SubmissionItem(
        id: id,
        typeId: typeId,
        typeName: typeName,
        title: title,
        description: description,
        startDate: startDate,
        endDate: endDate,
        startTime: startTime,
        endTime: endTime,
        status: status ?? this.status,
        createdAt: createdAt,
        attachmentNames: attachmentNames,
        approvalNote: approvalNote ?? this.approvalNote,
      );
}
