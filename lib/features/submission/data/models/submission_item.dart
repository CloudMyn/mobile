import 'submission_attachment.dart';

enum SubmissionStatus { draft, pending, approved, rejected, cancelled }

extension SubmissionStatusExt on SubmissionStatus {
  String get label => switch (this) {
    SubmissionStatus.draft => 'Draft',
    SubmissionStatus.pending => 'Menunggu',
    SubmissionStatus.approved => 'Disetujui',
    SubmissionStatus.rejected => 'Ditolak',
    SubmissionStatus.cancelled => 'Dibatalkan',
  };
}

SubmissionStatus submissionStatusFromString(String s) =>
    switch (s.toLowerCase()) {
      'draft' => SubmissionStatus.draft,
      'pending' => SubmissionStatus.pending,
      'approved' => SubmissionStatus.approved,
      'rejected' => SubmissionStatus.rejected,
      'cancelled' => SubmissionStatus.cancelled,
      _ => SubmissionStatus.pending,
    };

class SubmissionItem {
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
  final DateTime? cancelledAt;
  final String? approvalNote;
  final bool isWfhFromHome;
  final List<SubmissionAttachment> attachments;

  const SubmissionItem({
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
    this.cancelledAt,
    this.approvalNote,
    this.isWfhFromHome = false,
    this.attachments = const [],
  });

  factory SubmissionItem.fromJson(Map<String, dynamic> json) {
    final subType = json['submission_type'] as Map<String, dynamic>? ?? {};
    final dateRange = json['date_range'] as Map<String, dynamic>? ?? {};
    final timeRange = json['time_range'] as Map<String, dynamic>? ?? {};
    final tracking = json['tracking'] as Map<String, dynamic>? ?? {};
    final rawAttachments = json['attachments'] as List? ?? [];
    final typeName = subType['name'] as String? ?? '';
    final reason = json['reason'] as String?;

    return SubmissionItem(
      id: json['id'] as int,
      typeId: subType['id'] as int? ?? 0,
      typeName: typeName,
      typeCode: subType['code'] as String? ?? '',
      title: json['title'] as String? ?? typeName,
      description: json['description'] as String? ?? reason ?? '',
      reason: reason,
      startDate: DateTime.parse(
        dateRange['start_date'] as String? ?? DateTime.now().toIso8601String(),
      ),
      endDate: dateRange['end_date'] != null
          ? DateTime.parse(dateRange['end_date'] as String)
          : null,
      totalDays: int.tryParse(dateRange['total_days']?.toString() ?? ''),
      startTime: timeRange['start_time'] as String?,
      endTime: timeRange['end_time'] as String?,
      totalHours: int.tryParse(timeRange['total_hours']?.toString() ?? ''),
      status: submissionStatusFromString(
        json['status'] as String? ?? 'pending',
      ),
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      submittedAt: tracking['submitted_at'] != null
          ? DateTime.tryParse(tracking['submitted_at'] as String)
          : null,
      approvedAt: tracking['approved_at'] != null
          ? DateTime.tryParse(tracking['approved_at'] as String)
          : null,
      rejectedAt: tracking['rejected_at'] != null
          ? DateTime.tryParse(tracking['rejected_at'] as String)
          : null,
      cancelledAt: tracking['cancelled_at'] != null
          ? DateTime.tryParse(tracking['cancelled_at'] as String)
          : null,
      approvalNote: json['approval_note'] as String?,
      isWfhFromHome: json['is_wfh_from_home'] as bool? ?? false,
      attachments: rawAttachments
          .map((e) => SubmissionAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  List<String> get attachmentNames =>
      attachments.map((e) => e.fileName).toList();

  String get formattedDate {
    final start = _formatDate(startDate);
    if (endDate == null) return start;
    return '$start – ${_formatDate(endDate!)}';
  }

  static String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  bool get isDeletable => status == SubmissionStatus.draft;
  bool get isCancellable => status == SubmissionStatus.pending;
}
