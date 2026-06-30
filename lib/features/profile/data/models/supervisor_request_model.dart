import '../../../auth/data/models/user_model.dart';

class SupervisorRequestModel {
  final int id;
  final int userId;
  final int requestedSupervisorId;
  final String? reason;
  final String status;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? user;
  final UserModel? requestedSupervisor;

  SupervisorRequestModel({
    required this.id,
    required this.userId,
    required this.requestedSupervisorId,
    this.reason,
    required this.status,
    this.approvedAt,
    this.rejectedAt,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.requestedSupervisor,
  });

  factory SupervisorRequestModel.fromJson(Map<String, dynamic> json) {
    return SupervisorRequestModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      requestedSupervisorId: json['requested_supervisor_id'] as int,
      reason: json['reason'] as String?,
      status: json['status'] as String,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'] as String)
          : null,
      rejectedAt: json['rejected_at'] != null
          ? DateTime.parse(json['rejected_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      requestedSupervisor: json['requested_supervisor'] != null
          ? UserModel.fromJson(json['requested_supervisor'] as Map<String, dynamic>)
          : null,
    );
  }
}
