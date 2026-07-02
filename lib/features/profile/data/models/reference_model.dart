class ReferenceItem {
  final int id;
  final String name;

  const ReferenceItem({required this.id, required this.name});

  factory ReferenceItem.fromJson(Map<String, dynamic> json) {
    return ReferenceItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}
