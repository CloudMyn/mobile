class ProfileEmployeeDataModel {
  const ProfileEmployeeDataModel({
    required this.id,
    required this.fullName,
    required this.nip,
    required this.phone,
    required this.address,
  });

  final int id;
  final String fullName;
  final String nip;
  final String? phone;
  final String address;

  factory ProfileEmployeeDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileEmployeeDataModel(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      nip: json['nip'] as String? ?? '',
      phone: json['phone'] as String?,
      address: json['address'] as String? ?? '',
    );
  }

  ProfileEmployeeDataModel copyWith({
    int? id,
    String? fullName,
    String? nip,
    String? phone,
    String? address,
  }) {
    return ProfileEmployeeDataModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nip: nip ?? this.nip,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
