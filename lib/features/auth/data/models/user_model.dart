/// Model user dari response API login dan GET /auth/me.
class UserModel {
  const UserModel({
    required this.id,
    required this.uuid,
    required this.nip,
    required this.name,
    required this.fullName,
    required this.email,
    this.phone,
    this.profilePictureUrl,
    this.faceData,
    this.institution,
    this.department,
    this.jobTitle,
    this.rank,
    required this.roles,
    required this.permissions,
    required this.isBypassFermuk,
  });

  final int id;
  final String uuid;
  final String nip;
  final String name;
  final String fullName;
  final String email;
  final String? phone;
  final String? profilePictureUrl;
  final String? faceData;
  final bool isBypassFermuk;
  final UserOrgUnit? institution;
  final UserOrgUnit? department;
  final UserOrgUnit? jobTitle;
  final UserRank? rank;
  final List<String> roles;
  final List<String> permissions;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String? ?? '',
      nip: json['nip'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
      faceData: json['face_data'] as String?,
      isBypassFermuk: json['is_bypass_fermuk'] as bool? ?? false,
      institution: json['institution'] != null
          ? UserOrgUnit.fromJson(json['institution'] as Map<String, dynamic>)
          : null,
      department: json['department'] != null
          ? UserOrgUnit.fromJson(json['department'] as Map<String, dynamic>)
          : null,
      jobTitle: json['job_title'] != null
          ? UserOrgUnit.fromJson(json['job_title'] as Map<String, dynamic>)
          : null,
      rank: json['rank'] != null
          ? UserRank.fromJson(json['rank'] as Map<String, dynamic>)
          : null,
      roles:
          (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      permissions:
          (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  bool hasRole(String role) => roles.contains(role);
  bool hasPermission(String permission) => permissions.contains(permission);

  UserModel copyWith({
    int? id,
    String? uuid,
    String? nip,
    String? name,
    String? fullName,
    String? email,
    String? phone,
    String? profilePictureUrl,
    String? faceData,
    bool? isBypassFermuk,
    UserOrgUnit? institution,
    UserOrgUnit? department,
    UserOrgUnit? jobTitle,
    UserRank? rank,
    List<String>? roles,
    List<String>? permissions,
  }) {
    return UserModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      nip: nip ?? this.nip,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      faceData: faceData ?? this.faceData,
      isBypassFermuk: isBypassFermuk ?? this.isBypassFermuk,
      institution: institution ?? this.institution,
      department: department ?? this.department,
      jobTitle: jobTitle ?? this.jobTitle,
      rank: rank ?? this.rank,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}

class UserRank {
  const UserRank({
    required this.id,
    required this.group,
    required this.space,
    required this.name,
    required this.fullLabel,
    required this.displayLabel,
  });

  final int id;
  final String group;
  final String space;
  final String name;
  final String fullLabel;
  final String displayLabel;

  factory UserRank.fromJson(Map<String, dynamic> json) {
    return UserRank(
      id: json['id'] as int? ?? 0,
      group: json['group'] as String? ?? '',
      space: json['space'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullLabel: json['full_label'] as String? ?? '',
      displayLabel: json['display_label'] as String? ?? '',
    );
  }
}

class UserOrgUnit {
  const UserOrgUnit({required this.id, required this.name});

  final int id;
  final String name;

  factory UserOrgUnit.fromJson(Map<String, dynamic> json) {
    return UserOrgUnit(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }
}
