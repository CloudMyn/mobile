enum ActivityStatus { pending, approved, rejected }

class SubordinateActivityItem {
  final String id;
  final String typeId;
  final String typeName;
  final String description;
  final DateTime date;
  final String? attachmentUrl; 
  final DateTime createdAt;
  
  // Pegawai info
  final String subordinateName;
  final String subordinateNip;
  final String subordinateAvatar;
  
  // Approval
  final ActivityStatus status;
  final String? rejectReason;

  const SubordinateActivityItem({
    required this.id,
    required this.typeId,
    required this.typeName,
    required this.description,
    required this.date,
    this.attachmentUrl,
    required this.createdAt,
    required this.subordinateName,
    required this.subordinateNip,
    required this.subordinateAvatar,
    required this.status,
    this.rejectReason,
  });

  bool get isPdf => attachmentUrl?.toLowerCase().endsWith('.pdf') ?? false;
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;

  SubordinateActivityItem copyWith({
    String? id,
    String? typeId,
    String? typeName,
    String? description,
    DateTime? date,
    String? attachmentUrl,
    DateTime? createdAt,
    String? subordinateName,
    String? subordinateNip,
    String? subordinateAvatar,
    ActivityStatus? status,
    String? rejectReason,
  }) {
    return SubordinateActivityItem(
      id: id ?? this.id,
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
      description: description ?? this.description,
      date: date ?? this.date,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      createdAt: createdAt ?? this.createdAt,
      subordinateName: subordinateName ?? this.subordinateName,
      subordinateNip: subordinateNip ?? this.subordinateNip,
      subordinateAvatar: subordinateAvatar ?? this.subordinateAvatar,
      status: status ?? this.status,
      rejectReason: rejectReason ?? this.rejectReason,
    );
  }
}
