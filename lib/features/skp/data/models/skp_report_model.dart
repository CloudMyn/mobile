class SkpReportUser {
  final int id;
  final String name;
  final String? fullName;
  final String? nip;

  SkpReportUser({
    required this.id,
    required this.name,
    this.fullName,
    this.nip,
  });

  String get displayName => fullName?.isNotEmpty == true ? fullName! : name;

  factory SkpReportUser.fromJson(Map<String, dynamic> json) {
    return SkpReportUser(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
      nip: json['nip']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'full_name': fullName,
    'nip': nip,
  };
}

class SkpReportInstitution {
  final int id;
  final String name;

  SkpReportInstitution({
    required this.id,
    required this.name,
  });

  factory SkpReportInstitution.fromJson(Map<String, dynamic> json) {
    return SkpReportInstitution(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class SkpReportVerifier {
  final int id;
  final String name;
  final String? fullName;

  SkpReportVerifier({
    required this.id,
    required this.name,
    this.fullName,
  });

  String get displayName => fullName?.isNotEmpty == true ? fullName! : name;

  factory SkpReportVerifier.fromJson(Map<String, dynamic> json) {
    return SkpReportVerifier(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      fullName: json['full_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'full_name': fullName,
  };
}

class SkpReportModel {
  final int id;
  final int periodMonth;
  final int periodYear;
  final String fileName;
  final int fileSize;
  final String? fileUrl;
  final Map<String, dynamic>? jsonExtractedData;
  final int? tppPercentage;
  final String status;
  final DateTime? verifiedAt;
  final String? rejectionNote;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SkpReportUser? user;
  final SkpReportInstitution? institution;
  final SkpReportVerifier? verifier;

  SkpReportModel({
    required this.id,
    required this.periodMonth,
    required this.periodYear,
    required this.fileName,
    this.fileSize = 0,
    this.fileUrl,
    this.jsonExtractedData,
    this.tppPercentage,
    this.status = 'pending',
    this.verifiedAt,
    this.rejectionNote,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.institution,
    this.verifier,
  });

  bool get isApproved => status.toLowerCase() == 'disetujui';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'ditolak';

  String get displayName => user?.displayName ?? 'Pegawai';
  String get verifierDisplayName => verifier?.displayName ?? '-';

  String? get predikatKinerja =>
      jsonExtractedData?['predikat_kinerja_pegawai']?.toString();

  String? get capaianOrganisasi =>
      jsonExtractedData?['capaian_kinerja_organisasi']?.toString();

  factory SkpReportModel.fromJson(Map<String, dynamic> json) {
    return SkpReportModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      periodMonth: json['period_month'] is int
          ? json['period_month']
          : int.tryParse(json['period_month']?.toString() ?? '1') ?? 1,
      periodYear: json['period_year'] is int
          ? json['period_year']
          : int.tryParse(json['period_year']?.toString() ?? '2026') ?? 2026,
      fileName: json['file_name']?.toString() ?? 'unknown.pdf',
      fileSize: json['file_size'] is int
          ? json['file_size']
          : int.tryParse(json['file_size']?.toString() ?? '0') ?? 0,
      fileUrl: json['file_url']?.toString(),
      jsonExtractedData: json['json_extracted_data'] is Map<String, dynamic>
          ? json['json_extracted_data'] as Map<String, dynamic>
          : null,
      tppPercentage: json['tpp_percentage'] is int
          ? json['tpp_percentage']
          : int.tryParse(json['tpp_percentage']?.toString() ?? ''),
      status: json['status']?.toString() ?? 'pending',
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'].toString())
          : null,
      rejectionNote: json['rejection_note']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      user: json['user'] is Map<String, dynamic>
          ? SkpReportUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      institution: json['institution'] is Map<String, dynamic>
          ? SkpReportInstitution.fromJson(json['institution'] as Map<String, dynamic>)
          : null,
      verifier: json['verifier'] is Map<String, dynamic>
          ? SkpReportVerifier.fromJson(json['verifier'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'period_month': periodMonth,
    'period_year': periodYear,
    'file_name': fileName,
    'file_size': fileSize,
    'file_url': fileUrl,
    'json_extracted_data': jsonExtractedData,
    'tpp_percentage': tppPercentage,
    'status': status,
    'verified_at': verifiedAt?.toIso8601String(),
    'rejection_note': rejectionNote,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'user': user?.toJson(),
    'institution': institution?.toJson(),
    'verifier': verifier?.toJson(),
  };

  SkpReportModel copyWith({
    int? id,
    int? periodMonth,
    int? periodYear,
    String? fileName,
    int? fileSize,
    String? fileUrl,
    Map<String, dynamic>? jsonExtractedData,
    int? tppPercentage,
    String? status,
    DateTime? verifiedAt,
    String? rejectionNote,
    DateTime? createdAt,
    DateTime? updatedAt,
    SkpReportUser? user,
    SkpReportInstitution? institution,
    SkpReportVerifier? verifier,
  }) {
    return SkpReportModel(
      id: id ?? this.id,
      periodMonth: periodMonth ?? this.periodMonth,
      periodYear: periodYear ?? this.periodYear,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      fileUrl: fileUrl ?? this.fileUrl,
      jsonExtractedData: jsonExtractedData ?? this.jsonExtractedData,
      tppPercentage: tppPercentage ?? this.tppPercentage,
      status: status ?? this.status,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectionNote: rejectionNote ?? this.rejectionNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
      institution: institution ?? this.institution,
      verifier: verifier ?? this.verifier,
    );
  }
}
