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
}
