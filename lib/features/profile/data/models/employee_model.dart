class EmployeeModel {
  final String id;
  final String nip;
  final String name;
  final String position;
  final String unit;
  final String email;
  final String phone;
  final String address;
  final String? photoUrl;

  const EmployeeModel({
    required this.id,
    required this.nip,
    required this.name,
    required this.position,
    required this.unit,
    required this.email,
    required this.phone,
    required this.address,
    this.photoUrl,
  });

  EmployeeModel copyWith({
    String? id,
    String? nip,
    String? name,
    String? position,
    String? unit,
    String? email,
    String? phone,
    String? address,
    String? photoUrl,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      nip: nip ?? this.nip,
      name: name ?? this.name,
      position: position ?? this.position,
      unit: unit ?? this.unit,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
