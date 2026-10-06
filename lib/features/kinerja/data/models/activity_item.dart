class ActivityAttachment {
  final String? id;
  final String fileName;
  final String url;

  const ActivityAttachment({
    this.id,
    required this.fileName,
    required this.url,
  });

  bool get isPdf =>
      fileName.toLowerCase().endsWith('.pdf') ||
      url.toLowerCase().contains('.pdf');

  factory ActivityAttachment.fromJson(Map<String, dynamic> json) {
    return ActivityAttachment(
      id: json['id']?.toString(),
      fileName: json['file_name']?.toString() ?? 'Lampiran',
      url: json['url']?.toString() ?? '',
    );
  }
}

class ActivityItem {
  final String id;
  final String typeId;
  final String typeName;
  final String? title;
  final String description;
  final String? output;
  final String? locationText;
  final DateTime date;
  final String? imageUrl;
  final List<ActivityAttachment> attachments;
  final DateTime createdAt;
  final String? startTime;
  final String? endTime;
  final String? status;
  final String? rawStatus;
  final String? rejectReason;
  final String? ekinerjaSyncStatus;
  final String? ekinerjaSyncAction;
  final String? ekinerjaSyncError;
  final DateTime? ekinerjaSyncedAt;

  const ActivityItem({
    required this.id,
    required this.typeId,
    required this.typeName,
    this.title,
    required this.description,
    this.output,
    this.locationText,
    required this.date,
    this.imageUrl,
    this.attachments = const [],
    required this.createdAt,
    this.startTime,
    this.endTime,
    this.status,
    this.rawStatus,
    this.rejectReason,
    this.ekinerjaSyncStatus,
    this.ekinerjaSyncAction,
    this.ekinerjaSyncError,
    this.ekinerjaSyncedAt,
  });

  String get displayTitle =>
      (title != null && title!.trim().isNotEmpty) ? title! : (typeName.isNotEmpty ? typeName : description);

  bool get hasAttachment =>
      attachments.isNotEmpty || (imageUrl != null && imageUrl!.isNotEmpty);

  bool get isDraft => (rawStatus?.toLowerCase() == 'draft') || (status?.toLowerCase() == 'draft');
  bool get isPending => (rawStatus?.toLowerCase() == 'submitted') || (status?.toLowerCase() == 'pending') || (status?.toLowerCase() == 'menunggu');
  bool get isApproved => (rawStatus?.toLowerCase() == 'approved') || (status?.toLowerCase() == 'disetujui');
  bool get isRejected => (rawStatus?.toLowerCase() == 'rejected') || (status?.toLowerCase() == 'ditolak');

  bool get isEditable => isDraft;
  bool get isDeletable => isDraft;

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  ActivityItem copyWith({
    String? typeId,
    String? typeName,
    String? title,
    String? description,
    String? output,
    String? locationText,
    DateTime? date,
    String? imageUrl,
    List<ActivityAttachment>? attachments,
    String? startTime,
    String? endTime,
    String? status,
    String? rawStatus,
    String? rejectReason,
    String? ekinerjaSyncStatus,
    String? ekinerjaSyncAction,
    String? ekinerjaSyncError,
    DateTime? ekinerjaSyncedAt,
  }) => ActivityItem(
    id: id,
    typeId: typeId ?? this.typeId,
    typeName: typeName ?? this.typeName,
    title: title ?? this.title,
    description: description ?? this.description,
    output: output ?? this.output,
    locationText: locationText ?? this.locationText,
    date: date ?? this.date,
    imageUrl: imageUrl ?? this.imageUrl,
    attachments: attachments ?? this.attachments,
    createdAt: createdAt,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    status: status ?? this.status,
    rawStatus: rawStatus ?? this.rawStatus,
    rejectReason: rejectReason ?? this.rejectReason,
    ekinerjaSyncStatus: ekinerjaSyncStatus ?? this.ekinerjaSyncStatus,
    ekinerjaSyncAction: ekinerjaSyncAction ?? this.ekinerjaSyncAction,
    ekinerjaSyncError: ekinerjaSyncError ?? this.ekinerjaSyncError,
    ekinerjaSyncedAt: ekinerjaSyncedAt ?? this.ekinerjaSyncedAt,
  );

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
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

    String? imgUrl;
    if (attachmentList.isNotEmpty) {
      imgUrl = attachmentList.first.url;
    } else if (json['attachments'] != null &&
        (json['attachments'] as List).isNotEmpty) {
      imgUrl = json['attachments'][0]['url'];
    }

    // Map backend status to mobile status string
    String mapStatus(String? statusStr) {
      switch (statusStr?.toLowerCase()) {
        case 'approved':
          return 'Disetujui';
        case 'submitted':
          return 'Pending';
        case 'rejected':
          return 'Ditolak';
        case 'draft':
          return 'Draft';
        case 'selesai':
          return 'Disetujui';
        case 'belum selesai':
          return 'Draft';
        default:
          return statusStr ?? 'Draft';
      }
    }

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

    return ActivityItem(
      id: json['id']?.toString() ?? '',
      typeId: json['activity_type_id']?.toString() ?? '',
      typeName: json['activity_type']?['name']?.toString() ?? '',
      title: json['title']?.toString(),
      description: json['description']?.toString() ?? '',
      output: json['output']?.toString(),
      locationText: json['location_text']?.toString(),
      date: json['activity_date'] != null
          ? DateTime.parse(
              json['activity_date'],
            ).toUtc().add(const Duration(hours: 8))
          : DateTime.now().toUtc().add(const Duration(hours: 8)),
      imageUrl: imgUrl,
      attachments: attachmentList,
      createdAt: json['created_at'] != null
          ? DateTime.parse(
              json['created_at'],
            ).toUtc().add(const Duration(hours: 8))
          : DateTime.now().toUtc().add(const Duration(hours: 8)),
      startTime: startStr,
      endTime: endStr,
      status: mapStatus(json['status']),
      rawStatus: json['status']?.toString(),
      rejectReason: json['reject_reason']?.toString(),
      ekinerjaSyncStatus: syncStatus,
      ekinerjaSyncAction: syncAction,
      ekinerjaSyncError: syncError,
      ekinerjaSyncedAt: syncedAt,
    );
  }
}
