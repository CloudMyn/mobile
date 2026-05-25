import 'dart:typed_data';

/// Request body ke POST /mobile/presensi/{code}
class AttendanceSubmissionRequest {
  const AttendanceSubmissionRequest({
    required this.code,
    this.shiftNo = 1,
    this.latitude,
    this.longitude,
    this.accuracyMeters,
    required this.deviceUuid,
    this.faceScore,
    this.photoBytes,
    this.note,
  });

  /// AttendanceType.code — dipakai sebagai URL segment: /mobile/presensi/{code}
  final String code;

  final int shiftNo;
  final double? latitude;
  final double? longitude;
  final double? accuracyMeters;

  /// UUID perangkat dari [TokenStorage.getOrCreateDeviceUuid()]
  final String deviceUuid;

  /// Confidence score dari ML Kit face detection (0.0–1.0)
  final double? faceScore;

  /// Bytes foto wajah — dikirim sebagai multipart file
  final Uint8List? photoBytes;

  final String? note;
}

/// Response dari POST /mobile/presensi/{code}
class AttendanceSubmissionResponse {
  const AttendanceSubmissionResponse({
    required this.id,
    required this.status,
    required this.attendedAt,
    this.distanceToLocationMeters,
    this.message,
  });

  final int id;

  /// Status slot setelah presensi: "OnTime" | "Late" | "InvalidLocation"
  final String status;
  final String attendedAt;
  final double? distanceToLocationMeters;
  final String? message;

  factory AttendanceSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceSubmissionResponse(
      id: json['id'] as int,
      status: json['status'] as String? ?? '',
      attendedAt: json['attended_at'] as String? ?? '',
      distanceToLocationMeters:
          (json['distance_to_location_meters'] as num?)?.toDouble(),
      message: null,
    );
  }
}
