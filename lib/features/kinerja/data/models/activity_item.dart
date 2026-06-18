class ActivityItem {
  final String id;
  final String typeId;
  final String typeName;
  final String description;
  final DateTime date;
  final String? imageUrl;
  final DateTime createdAt;
  final String? startTime;
  final String? endTime;
  final String? status;

  const ActivityItem({
    required this.id,
    required this.typeId,
    required this.typeName,
    required this.description,
    required this.date,
    this.imageUrl,
    required this.createdAt,
    this.startTime,
    this.endTime,
    this.status,
  });

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  ActivityItem copyWith({
    String? typeId,
    String? typeName,
    String? description,
    DateTime? date,
    String? imageUrl,
    String? startTime,
    String? endTime,
    String? status,
  }) =>
      ActivityItem(
        id: id,
        typeId: typeId ?? this.typeId,
        typeName: typeName ?? this.typeName,
        description: description ?? this.description,
        date: date ?? this.date,
        imageUrl: imageUrl ?? this.imageUrl,
        createdAt: createdAt,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        status: status ?? this.status,
      );

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    String? startStr;
    String? endStr;
    if (json['time'] != null) {
      final startAt = json['time']['start_at'];
      final endAt = json['time']['end_at'];
      if (startAt != null) {
        final parsed = DateTime.tryParse(startAt);
        if (parsed != null) {
          startStr = '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
        } else {
          startStr = startAt.toString();
        }
      }
      if (endAt != null) {
        final parsed = DateTime.tryParse(endAt);
        if (parsed != null) {
          endStr = '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
        } else {
          endStr = endAt.toString();
        }
      }
    }

    String? imgUrl;
    if (json['attachments'] != null && (json['attachments'] as List).isNotEmpty) {
      imgUrl = json['attachments'][0]['url'];
    }

    // Map backend status to mobile status string
    String mapStatus(String? statusStr) {
      switch (statusStr?.toLowerCase()) {
        case 'approved':
          return 'Selesai';
        case 'submitted':
          return 'Selesai'; // map submitted/approved to 'Selesai' for consistent UI chips
        default:
          return 'Belum Selesai'; // draft/rejected maps to 'Belum Selesai'
      }
    }

    return ActivityItem(
      id: json['id']?.toString() ?? '',
      typeId: json['activity_type_id']?.toString() ?? '',
      typeName: json['activity_type']?['name']?.toString() ?? '',
      description: json['description'] ?? '',
      date: json['activity_date'] != null
          ? DateTime.parse(json['activity_date'])
          : DateTime.now(),
      imageUrl: imgUrl,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      startTime: startStr,
      endTime: endStr,
      status: mapStatus(json['status']),
    );
  }
}
