import 'submission_attachment.dart';
import 'submission_item.dart';

class SubordinateSubmissionItem {
  final int id;
  final int typeId;
  final String typeName;
  final String typeCode;
  final String title;
  final String description;
  final String? reason;
  final DateTime startDate;
  final DateTime? endDate;
  final int? totalDays;
  final String? startTime;
  final String? endTime;
  final int? totalHours;
  final SubmissionStatus status;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? approvalNote;
  final List<SubmissionAttachment> attachments;

  // Subordinate specific info
  final String subordinateName;
  final String subordinateNip;
  final String subordinateAvatar;

  const SubordinateSubmissionItem({
    required this.id,
    required this.typeId,
    required this.typeName,
    required this.typeCode,
    this.title = '',
    this.description = '',
    this.reason,
    required this.startDate,
    this.endDate,
    this.totalDays,
    this.startTime,
    this.endTime,
    this.totalHours,
    required this.status,
    required this.createdAt,
    this.submittedAt,
    this.approvedAt,
    this.rejectedAt,
    this.approvalNote,
    this.attachments = const [],
    required this.subordinateName,
    required this.subordinateNip,
    required this.subordinateAvatar,
  });

  String get formattedDate {
    final start = _formatDate(startDate);
    if (endDate == null) return start;
    return '$start – ${_formatDate(endDate!)}';
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  SubordinateSubmissionItem copyWith({
    int? id,
    int? typeId,
    String? typeName,
    String? typeCode,
    String? title,
    String? description,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDays,
    String? startTime,
    String? endTime,
    int? totalHours,
    SubmissionStatus? status,
    DateTime? createdAt,
    DateTime? submittedAt,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    String? approvalNote,
    List<SubmissionAttachment>? attachments,
    String? subordinateName,
    String? subordinateNip,
    String? subordinateAvatar,
  }) {
    return SubordinateSubmissionItem(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
      typeCode: typeCode ?? this.typeCode,
      title: title ?? this.title,
      description: description ?? this.description,
      reason: reason ?? this.reason,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalDays: totalDays ?? this.totalDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalHours: totalHours ?? this.totalHours,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      submittedAt: submittedAt ?? this.submittedAt,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      approvalNote: approvalNote ?? this.approvalNote,
      attachments: attachments ?? this.attachments,
      subordinateName: subordinateName ?? this.subordinateName,
      subordinateNip: subordinateNip ?? this.subordinateNip,
      subordinateAvatar: subordinateAvatar ?? this.subordinateAvatar,
    );
  }
}
