class AttendanceConfig {
  final bool faceRecognition;
  final bool faceCapture;
  final bool geofenceEnabled;
  final bool requiredLocation;
  final double? geofenceLat;
  final double? geofenceLng;
  final double? geofenceRadius;

  const AttendanceConfig({
    required this.faceRecognition,
    required this.faceCapture,
    required this.geofenceEnabled,
    required this.requiredLocation,
    this.geofenceLat,
    this.geofenceLng,
    this.geofenceRadius,
  });

  bool get needsGeofenceCheck => geofenceEnabled && requiredLocation;
  bool get needsFaceWork => faceRecognition || faceCapture;
  bool get hasValidGeofence =>
      geofenceLat != null && geofenceLng != null && geofenceRadius != null;

  factory AttendanceConfig.fromJson(Map<String, dynamic> json) {
    return AttendanceConfig(
      faceRecognition: json['face_recognition'] as bool? ?? true,
      faceCapture: json['face_capture'] as bool? ?? true,
      geofenceEnabled: json['geofence'] as bool? ?? true,
      requiredLocation: json['required_location'] as bool? ?? true,
      geofenceLat: (json['geofence_lat'] as num?)?.toDouble(),
      geofenceLng: (json['geofence_lng'] as num?)?.toDouble(),
      geofenceRadius: (json['geofence_radius'] as num?)?.toDouble(),
    );
  }

  AttendanceConfig copyWith({
    bool? faceRecognition,
    bool? faceCapture,
    bool? geofenceEnabled,
    bool? requiredLocation,
    double? geofenceLat,
    double? geofenceLng,
    double? geofenceRadius,
  }) {
    return AttendanceConfig(
      faceRecognition: faceRecognition ?? this.faceRecognition,
      faceCapture: faceCapture ?? this.faceCapture,
      geofenceEnabled: geofenceEnabled ?? this.geofenceEnabled,
      requiredLocation: requiredLocation ?? this.requiredLocation,
      geofenceLat: geofenceLat ?? this.geofenceLat,
      geofenceLng: geofenceLng ?? this.geofenceLng,
      geofenceRadius: geofenceRadius ?? this.geofenceRadius,
    );
  }
}
