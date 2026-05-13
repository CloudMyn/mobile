/// Tipe presensi
enum AttendanceType { checkIn, checkOut }

extension AttendanceTypeExtension on AttendanceType {
  String get value => switch (this) {
        AttendanceType.checkIn => 'check_in',
        AttendanceType.checkOut => 'check_out',
      };
  String get label => switch (this) {
        AttendanceType.checkIn => 'Presensi Masuk',
        AttendanceType.checkOut => 'Presensi Pulang',
      };
}

/// Request body ke API submit presensi
class AttendanceSubmissionRequest {
  final AttendanceType type;
  final String? faceImageUrl;
  final List<double>? faceEmbedding;
  final double? latitude;
  final double? longitude;
  final double? accuracy;

  const AttendanceSubmissionRequest({
    required this.type,
    this.faceImageUrl,
    this.faceEmbedding,
    this.latitude,
    this.longitude,
    this.accuracy,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.value,
      if (faceImageUrl != null) 'face_image_url': faceImageUrl,
      if (faceEmbedding != null) 'face_embedding': faceEmbedding,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (accuracy != null) 'accuracy': accuracy,
    };
  }
}

/// Response dari API submit presensi
class AttendanceSubmissionResponse {
  final bool success;
  final String message;
  final String? recordedAt;

  const AttendanceSubmissionResponse({
    required this.success,
    required this.message,
    this.recordedAt,
  });

  factory AttendanceSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceSubmissionResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      recordedAt: json['recorded_at'] as String?,
    );
  }
}
