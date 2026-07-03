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

  factory SubordinateSubmissionItem.fromJson(Map<String, dynamic> json) {
    final typeJson = json['submission_type'] as Map<String, dynamic>?;
    final userJson = json['user'] as Map<String, dynamic>?;
    final dateRange = json['date_range'] as Map<String, dynamic>?;
    final timeRange = json['time_range'] as Map<String, dynamic>?;
    final tracking = json['tracking'] as Map<String, dynamic>?;

    final attachmentsList = json['attachments'] as List<dynamic>?;
    final attachments = attachmentsList
        ?.map((a) => SubmissionAttachment.fromJson(a as Map<String, dynamic>))
        .toList() ??
        [];

    final subordinateName = userJson?['name'] as String? ?? '-';
    String avatar = 'UK'; // Unknown
    if (subordinateName.isNotEmpty && subordinateName != '-') {
      final parts = subordinateName.trim().split(RegExp(r'\s+'));
      if (parts.length > 1) {
        avatar = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      } else {
        avatar = subordinateName.substring(0, subordinateName.length >= 2 ? 2 : 1).toUpperCase();
      }
    }

    return SubordinateSubmissionItem(
      id: json['id'] as int,
      typeId: typeJson?['id'] as int? ?? 0,
      typeName: typeJson?['name'] as String? ?? 'Unknown',
      typeCode: typeJson?['code'] as String? ?? 'unknown',
      title: typeJson?['name'] as String? ?? 'Pengajuan',
      description: json['reason'] as String? ?? '-',
      reason: json['reason'] as String?,
      startDate: dateRange?['start_date'] != null
          ? DateTime.parse(dateRange!['start_date'] as String)
          : DateTime.now(),
      endDate: dateRange?['end_date'] != null
          ? DateTime.parse(dateRange!['end_date'] as String)
          : null,
      totalDays: dateRange?['total_days'] != null
          ? double.tryParse(dateRange!['total_days'].toString())?.toInt()
          : null,
      startTime: timeRange?['start_time'] as String?,
      endTime: timeRange?['end_time'] as String?,
      totalHours: timeRange?['total_hours'] != null
          ? double.tryParse(timeRange!['total_hours'].toString())?.toInt()
          : null,
      status: _parseStatus(json['status'] as String?),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      submittedAt: tracking?['submitted_at'] != null
          ? DateTime.parse(tracking!['submitted_at'] as String)
          : null,
      approvedAt: tracking?['approved_at'] != null
          ? DateTime.parse(tracking!['approved_at'] as String)
          : null,
      rejectedAt: tracking?['rejected_at'] != null
          ? DateTime.parse(tracking!['rejected_at'] as String)
          : null,
      approvalNote: null, // Note isn't usually sent directly in summary list API, requires steps check
      attachments: attachments,
      subordinateName: subordinateName,
      subordinateNip: userJson?['nip'] as String? ?? '-',
      subordinateAvatar: avatar,
    );
  }

  static SubmissionStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return SubmissionStatus.pending;
      case 'approved':
        return SubmissionStatus.approved;
      case 'rejected':
        return SubmissionStatus.rejected;
      case 'draft':
        return SubmissionStatus.draft;
      case 'cancelled':
        return SubmissionStatus.cancelled;
      default:
        return SubmissionStatus.pending;
    }
  }
}
