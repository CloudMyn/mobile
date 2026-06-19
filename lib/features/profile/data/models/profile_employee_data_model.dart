import 'employee_enums.dart';

class ProfileEmployeeDataModel {
  const ProfileEmployeeDataModel({
    required this.id,
    required this.fullName,
    this.titlePrefix,
    this.titleSuffix,
    this.gender,
    this.birthPlace,
    this.birthDate,
    this.religion,
    this.maritalStatus,
    this.nik,
    required this.nip,
    this.phone,
    required this.address,
    this.postalCode,
    this.bankAccountNumber,
    this.bankName,
    this.bankAccountHolderName,
    this.motherName,
    this.fatherName,
    this.childrenCount,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelationship,
  });

  final int id;
  final String fullName;
  final String? titlePrefix;
  final String? titleSuffix;
  final Gender? gender;
  final String? birthPlace;
  final DateTime? birthDate;
  final Religion? religion;
  final MaritalStatus? maritalStatus;
  final String? nik;
  final String nip;
  final String? phone;
  final String address;
  final String? postalCode;
  final String? bankAccountNumber;
  final String? bankName;
  final String? bankAccountHolderName;
  final String? motherName;
  final String? fatherName;
  final int? childrenCount;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelationship;

  factory ProfileEmployeeDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileEmployeeDataModel(
      id: json['id'] as int? ?? 0,
      fullName: json['full_name'] as String? ?? '',
      titlePrefix: json['title_prefix'] as String?,
      titleSuffix: json['title_suffix'] as String?,
      gender: Gender.values.where((e) => e.name == json['gender']).firstOrNull,
      birthPlace: json['birth_place'] as String?,
      birthDate: json['birth_date'] != null ? DateTime.tryParse(json['birth_date'] as String) : null,
      religion: Religion.values.where((e) => e.name == json['religion']).firstOrNull,
      maritalStatus: MaritalStatus.values.where((e) => e.name == json['marital_status']).firstOrNull,
      nik: json['nik'] as String?,
      nip: json['nip'] as String? ?? '',
      phone: json['phone'] as String?,
      address: json['address'] as String? ?? '',
      postalCode: json['postal_code'] as String?,
      bankAccountNumber: json['bank_account_number'] as String?,
      bankName: json['bank_name'] as String?,
      bankAccountHolderName: json['bank_account_holder_name'] as String?,
      motherName: json['mother_name'] as String?,
      fatherName: json['father_name'] as String?,
      childrenCount: json['children_count'] as int?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      emergencyContactRelationship: json['emergency_contact_relationship'] as String?,
    );
  }

  ProfileEmployeeDataModel copyWith({
    int? id,
    String? fullName,
    String? titlePrefix,
    String? titleSuffix,
    Gender? gender,
    String? birthPlace,
    DateTime? birthDate,
    Religion? religion,
    MaritalStatus? maritalStatus,
    String? nik,
    String? nip,
    String? phone,
    String? address,
    String? postalCode,
    String? bankAccountNumber,
    String? bankName,
    String? bankAccountHolderName,
    String? motherName,
    String? fatherName,
    int? childrenCount,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelationship,
  }) {
    return ProfileEmployeeDataModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      titlePrefix: titlePrefix ?? this.titlePrefix,
      titleSuffix: titleSuffix ?? this.titleSuffix,
      gender: gender ?? this.gender,
      birthPlace: birthPlace ?? this.birthPlace,
      birthDate: birthDate ?? this.birthDate,
      religion: religion ?? this.religion,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      nik: nik ?? this.nik,
      nip: nip ?? this.nip,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankName: bankName ?? this.bankName,
      bankAccountHolderName: bankAccountHolderName ?? this.bankAccountHolderName,
      motherName: motherName ?? this.motherName,
      fatherName: fatherName ?? this.fatherName,
      childrenCount: childrenCount ?? this.childrenCount,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelationship: emergencyContactRelationship ?? this.emergencyContactRelationship,
    );
  }
}
