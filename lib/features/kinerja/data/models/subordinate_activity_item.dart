import 'activity_item.dart';

enum ActivityStatus { pending, approved, rejected }

class SubordinateActivityItem {
  final String id;
  final String typeId;
  final String typeName;
  final String? title;
  final String description;
  final String? output;
  final String? locationText;
  final DateTime date;
  final String? attachmentUrl; 
  final List<ActivityAttachment> attachments;
  final DateTime createdAt;
  final String? startTime;
  final String? endTime;
  
  // Pegawai info
  final String subordinateName;
  final String subordinateNip;
  final String subordinateAvatar;
  final String? institutionName;
  final String? departmentName;
  
  // Approval
  final ActivityStatus status;
  final String? rejectReason;

  // E-Kinerja Sync info
  final String? ekinerjaSyncStatus;
  final String? ekinerjaSyncAction;
  final String? ekinerjaSyncError;
  final DateTime? ekinerjaSyncedAt;

  const SubordinateActivityItem({
    required this.id,
    required this.typeId,
    required this.typeName,
    this.title,
    required this.description,
    this.output,
    this.locationText,
    required this.date,
    this.attachmentUrl,
    this.attachments = const [],
    required this.createdAt,
    this.startTime,
    this.endTime,
    required this.subordinateName,
    required this.subordinateNip,
    required this.subordinateAvatar,
    this.institutionName,
    this.departmentName,
    required this.status,
    this.rejectReason,
    this.ekinerjaSyncStatus,
    this.ekinerjaSyncAction,
    this.ekinerjaSyncError,
    this.ekinerjaSyncedAt,
  });

  String get displayTitle =>
      (title != null && title!.trim().isNotEmpty) ? title! : (typeName.isNotEmpty ? typeName : description);

  bool get isPdf {
    if (attachments.isNotEmpty) {
      return attachments.any((a) => a.isPdf);
    }
    return attachmentUrl?.toLowerCase().endsWith('.pdf') ?? false;
  }

  bool get hasAttachment =>
      attachments.isNotEmpty || (attachmentUrl != null && attachmentUrl!.isNotEmpty);

  SubordinateActivityItem copyWith({
    String? id,
    String? typeId,
    String? typeName,
    String? title,
    String? description,
    String? output,
    String? locationText,
    DateTime? date,
    String? attachmentUrl,
    List<ActivityAttachment>? attachments,
    DateTime? createdAt,
    String? startTime,
    String? endTime,
    String? subordinateName,
    String? subordinateNip,
    String? subordinateAvatar,
    String? institutionName,
    String? departmentName,
    ActivityStatus? status,
    String? rejectReason,
    String? ekinerjaSyncStatus,
    String? ekinerjaSyncAction,
    String? ekinerjaSyncError,
    DateTime? ekinerjaSyncedAt,
  }) {
    return SubordinateActivityItem(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
      title: title ?? this.title,
      description: description ?? this.description,
      output: output ?? this.output,
      locationText: locationText ?? this.locationText,
      date: date ?? this.date,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      subordinateName: subordinateName ?? this.subordinateName,
      subordinateNip: subordinateNip ?? this.subordinateNip,
      subordinateAvatar: subordinateAvatar ?? this.subordinateAvatar,
      institutionName: institutionName ?? this.institutionName,
      departmentName: departmentName ?? this.departmentName,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
      ekinerjaSyncStatus: ekinerjaSyncStatus ?? this.ekinerjaSyncStatus,
      ekinerjaSyncAction: ekinerjaSyncAction ?? this.ekinerjaSyncAction,
      ekinerjaSyncError: ekinerjaSyncError ?? this.ekinerjaSyncError,
      ekinerjaSyncedAt: ekinerjaSyncedAt ?? this.ekinerjaSyncedAt,
    );
  }

  factory SubordinateActivityItem.fromJson(Map<String, dynamic> json) {
    ActivityStatus mapStatus(String? statusStr) {
      switch (statusStr?.toLowerCase()) {
        case 'approved':
          return ActivityStatus.approved;
        case 'rejected':
          return ActivityStatus.rejected;
        default:
          return ActivityStatus.pending; // submitted maps to pending
      }
    }

    String? parseTime(dynamic val) {
      if (val == null) return null;
      final str = val.toString();
      var parsed = DateTime.tryParse(str);
      if (parsed != null) {
        parsed = parsed.toUtc().add(const Duration(hours: 8));
        return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
      }
      final parts = str.split(':');
      if (parts.length >= 2) {
        return '${parts[0].trim().padLeft(2, '0')}:${parts[1].trim().padLeft(2, '0')}';
      }
      return str;
    }

    String? startStr;
    String? endStr;
    if (json['time'] != null) {
      startStr = parseTime(json['time']['start_at']);
      endStr = parseTime(json['time']['end_at']);
    } else {
      startStr = parseTime(json['start_at']);
      endStr = parseTime(json['end_at']);
    }

    final attachmentList = <ActivityAttachment>[];
    if (json['attachments'] != null && json['attachments'] is List) {
      for (final a in json['attachments']) {
        if (a is Map<String, dynamic>) {
          attachmentList.add(ActivityAttachment.fromJson(a));
        }
      }
    }

    String? attachment;
    if (attachmentList.isNotEmpty) {
      attachment = attachmentList.first.url;
    } else if (json['attachments'] != null && (json['attachments'] as List).isNotEmpty) {
      attachment = json['attachments'][0]['url'];
    }

    final userObj = json['user'] as Map<String, dynamic>?;
    final subordinateName = userObj?['full_name'] ?? userObj?['name'] ?? '';
    final subordinateNip = userObj?['nip'] ?? '';
    final subordinateAvatar = userObj?['avatar'] ?? (subordinateName.isNotEmpty ? subordinateName[0].toUpperCase() : '?');

    final instObj = json['institution'] as Map<String, dynamic>?;
    final deptObj = json['department'] as Map<String, dynamic>?;

    final syncData = json['latest_ekinerja_sync'] as Map<String, dynamic>?;
    final syncStatus = syncData?['sync_status']?.toString();
    final syncAction = syncData?['sync_action']?.toString();
    final syncError = syncData?['sync_error']?.toString();
    DateTime? syncedAt;
    if (syncData?['synced_at'] != null) {
      syncedAt = DateTime.tryParse(syncData!['synced_at'].toString())
          ?.toUtc()
          .add(const Duration(hours: 8));
    }

    return SubordinateActivityItem(
      id: json['id']?.toString() ?? '',
      typeId: json['activity_type_id']?.toString() ?? '',
      typeName: json['activity_type']?['name']?.toString() ?? '',
      title: json['title']?.toString(),
      description: json['description'] ?? '',
      output: json['output']?.toString(),
      locationText: json['location_text']?.toString(),
      date: json['activity_date'] != null
          ? DateTime.parse(json['activity_date'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      startTime: startStr,
      endTime: endStr,
      attachmentUrl: attachment,
      attachments: attachmentList,
      subordinateName: subordinateName,
      subordinateNip: subordinateNip,
      subordinateAvatar: subordinateAvatar,
      institutionName: instObj?['name']?.toString(),
      departmentName: deptObj?['name']?.toString(),
      status: mapStatus(json['status']),
      rejectReason: json['reject_reason'],
      ekinerjaSyncStatus: syncStatus,
      ekinerjaSyncAction: syncAction,
      ekinerjaSyncError: syncError,
      ekinerjaSyncedAt: syncedAt,
    );
  }
}
