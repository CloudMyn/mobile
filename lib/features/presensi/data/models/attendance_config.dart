import '../../../home/data/models/dashboard_model.dart';

class AttendanceConfig {
  final bool faceRecognition;
  final bool faceCapture;
  final bool geofenceEnabled;
  final bool requiredLocation;
  final List<RequiredLocation> validLocations;
  final int defaultRadius;
  final String? storedFaceData;
  final String? locationEventName;
  final String geofenceMode; // "default" | "override" | "additional"

  const AttendanceConfig({
    required this.faceRecognition,
    required this.faceCapture,
    required this.geofenceEnabled,
    required this.requiredLocation,
    required this.validLocations,
    required this.defaultRadius,
    this.storedFaceData,
    this.locationEventName,
    this.geofenceMode = 'default',
  });

  bool get needsGeofenceCheck => geofenceEnabled && requiredLocation;
  bool get needsFaceWork => faceRecognition || faceCapture;
  bool get hasValidGeofence => validLocations.isNotEmpty;

  factory AttendanceConfig.fromJson(Map<String, dynamic> json) {
    return AttendanceConfig(
      faceRecognition: json['face_recognition'] as bool? ?? true,
      faceCapture: json['face_capture'] as bool? ?? true,
      geofenceEnabled: json['geofence'] as bool? ?? true,
      requiredLocation: json['required_location'] as bool? ?? true,
      validLocations: [],
      defaultRadius: 100,
    );
  }

  /// Buat config dari data [TodayRecord] yang berasal dari dashboard response.
  factory AttendanceConfig.fromRecord(
    TodayRecord record,
    List<RequiredLocation> locations,
    int defaultRadius, {
    String? storedFaceData,
    String? locationEventName,
    String geofenceMode = 'default',
  }) {
    return AttendanceConfig(
      faceRecognition: record.attendanceType.requiresFaceVerification,
      faceCapture: record.attendanceType.requiresPhoto,
      geofenceEnabled: record.attendanceType.requiresLocation,
      requiredLocation: record.attendanceType.requiresLocation,
      validLocations: locations,
      defaultRadius: defaultRadius,
      storedFaceData: storedFaceData,
      locationEventName: locationEventName,
      geofenceMode: geofenceMode,
    );
  }

  AttendanceConfig copyWith({
    bool? faceRecognition,
    bool? faceCapture,
    bool? geofenceEnabled,
    bool? requiredLocation,
    List<RequiredLocation>? validLocations,
    int? defaultRadius,
    String? storedFaceData,
    String? locationEventName,
    String? geofenceMode,
  }) {
    return AttendanceConfig(
      faceRecognition: faceRecognition ?? this.faceRecognition,
      faceCapture: faceCapture ?? this.faceCapture,
      geofenceEnabled: geofenceEnabled ?? this.geofenceEnabled,
      requiredLocation: requiredLocation ?? this.requiredLocation,
      validLocations: validLocations ?? this.validLocations,
      defaultRadius: defaultRadius ?? this.defaultRadius,
      storedFaceData: storedFaceData ?? this.storedFaceData,
      locationEventName: locationEventName ?? this.locationEventName,
      geofenceMode: geofenceMode ?? this.geofenceMode,
    );
  }
}
