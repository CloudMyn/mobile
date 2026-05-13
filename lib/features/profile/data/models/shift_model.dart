class ShiftModel {
  final String id;
  final String name;
  final String checkIn;
  final String checkOut;
  final bool isActive;

  const ShiftModel({
    required this.id,
    required this.name,
    required this.checkIn,
    required this.checkOut,
    required this.isActive,
  });

  ShiftModel copyWith({
    String? id,
    String? name,
    String? checkIn,
    String? checkOut,
    bool? isActive,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      name: name ?? this.name,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      isActive: isActive ?? this.isActive,
    );
  }
}
