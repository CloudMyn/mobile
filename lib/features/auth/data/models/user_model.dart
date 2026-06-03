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
    required this.roles,
    required this.permissions,
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
  final UserOrgUnit? institution;
  final UserOrgUnit? department;
  final UserOrgUnit? jobTitle;
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
      institution: json['institution'] != null
          ? UserOrgUnit.fromJson(json['institution'] as Map<String, dynamic>)
          : null,
      department: json['department'] != null
          ? UserOrgUnit.fromJson(json['department'] as Map<String, dynamic>)
          : null,
      jobTitle: json['job_title'] != null
          ? UserOrgUnit.fromJson(json['job_title'] as Map<String, dynamic>)
          : null,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      permissions: (json['permissions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  bool hasRole(String role) => roles.contains(role);
  bool hasPermission(String permission) => permissions.contains(permission);

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
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
