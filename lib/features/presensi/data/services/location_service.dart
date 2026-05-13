import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'permission_helper.dart';

enum LocationError {
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  timeout,
  unknown,
}

class LocationResult {
  final Position? position;
  final LocationError? error;

  const LocationResult._({this.position, this.error});

  factory LocationResult.success(Position pos) =>
      LocationResult._(position: pos);
  factory LocationResult.failure(LocationError err) =>
      LocationResult._(error: err);

  bool get isSuccess => position != null;
}

class LocationService {
  /// Minta permission lokasi jika belum diberikan.
  Future<bool> requestPermission() => PermissionHelper.requestLocation();

  /// Cek apakah permission lokasi sudah diberikan.
  Future<bool> hasPermission() async {
    final status = await PermissionHelper.locationStatus();
    return status.isGranted;
  }

  /// Ambil posisi GPS saat ini.
  Future<LocationResult> getCurrentPosition({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    final permStatus = await PermissionHelper.locationStatus();

    if (permStatus == PermissionStatus.permanentlyDenied) {
      return LocationResult.failure(LocationError.permissionDeniedForever);
    }

    if (!permStatus.isGranted) {
      final granted = await PermissionHelper.requestLocation();
      if (!granted) {
        return LocationResult.failure(LocationError.permissionDenied);
      }
    }

    // Cek location service aktif (hanya relevan di mobile)
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationResult.failure(LocationError.serviceDisabled);
      }
    } catch (_) {
      // Platform tidak mendukung cek ini — lanjutkan
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      ).timeout(timeout);
      return LocationResult.success(pos);
    } on LocationServiceDisabledException {
      return LocationResult.failure(LocationError.serviceDisabled);
    } catch (_) {
      return LocationResult.failure(LocationError.timeout);
    }
  }

  /// Hitung apakah posisi berada dalam radius geofence (meter).
  bool isInsideGeofence({
    required double userLat,
    required double userLng,
    required double fenceLat,
    required double fenceLng,
    required double radiusMeters,
  }) {
    final distance = Geolocator.distanceBetween(
      userLat,
      userLng,
      fenceLat,
      fenceLng,
    );
    return distance <= radiusMeters;
  }

  /// Hitung jarak antara user dan pusat geofence.
  double distanceToFence({
    required double userLat,
    required double userLng,
    required double fenceLat,
    required double fenceLng,
  }) {
    return Geolocator.distanceBetween(userLat, userLng, fenceLat, fenceLng);
  }
}
