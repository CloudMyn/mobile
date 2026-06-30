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
          ? DateTime.parse(json['activity_date']).toUtc().add(const Duration(hours: 8))
          : DateTime.now().toUtc().add(const Duration(hours: 8)),
      imageUrl: imgUrl,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toUtc().add(const Duration(hours: 8))
          : DateTime.now().toUtc().add(const Duration(hours: 8)),
      startTime: startStr,
      endTime: endStr,
      status: mapStatus(json['status']),
    );
  }
}
