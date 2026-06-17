import 'package:flutter/foundation.dart';
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

  /// Ambil posisi GPS saat ini dengan multi-tier fallback.
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
    } on LocationServiceDisabledException {
      return LocationResult.failure(LocationError.serviceDisabled);
    } catch (e) {
      debugPrint('[LocationService] isLocationServiceEnabled check failed: $e');
    }

    // TIER 1: High Accuracy (Primary)
    try {
      debugPrint('[LocationService] Tier 1: Fetching current position with LocationAccuracy.high (10s timeout)...');
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      debugPrint('[LocationService] Tier 1 Success: Lat: ${pos.latitude}, Lng: ${pos.longitude}, Accuracy: ${pos.accuracy}m');
      return LocationResult.success(pos);
    } on LocationServiceDisabledException {
      return LocationResult.failure(LocationError.serviceDisabled);
    } catch (e) {
      debugPrint('[LocationService] Tier 1 failed/timed out. Error: $e');
    }

    // TIER 2: Fresh Last Known Position (< 10 minutes old)
    try {
      debugPrint('[LocationService] Tier 2: Fetching last known position (fresh check)...');
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final age = DateTime.now().difference(lastKnown.timestamp).abs();
        debugPrint('[LocationService] Found last known position. Lat: ${lastKnown.latitude}, Lng: ${lastKnown.longitude}, Accuracy: ${lastKnown.accuracy}m, Age: ${age.inSeconds} seconds');
        if (age.inMinutes < 10) {
          debugPrint('[LocationService] Tier 2 Success: Last known position is fresh enough (< 10 mins). Using it.');
          return LocationResult.success(lastKnown);
        } else {
          debugPrint('[LocationService] Last known position is stale (${age.inMinutes} mins old). Skipping Tier 2.');
        }
      } else {
        debugPrint('[LocationService] No last known position found.');
      }
    } catch (e) {
      debugPrint('[LocationService] Tier 2 check failed. Error: $e');
    }

    // TIER 3: Medium Accuracy (5s timeout)
    try {
      debugPrint('[LocationService] Tier 3: Fetching current position with LocationAccuracy.medium (5s timeout)...');
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 5),
        ),
      );
      debugPrint('[LocationService] Tier 3 Success: Lat: ${pos.latitude}, Lng: ${pos.longitude}, Accuracy: ${pos.accuracy}m');
      return LocationResult.success(pos);
    } on LocationServiceDisabledException {
      return LocationResult.failure(LocationError.serviceDisabled);
    } catch (e) {
      debugPrint('[LocationService] Tier 3 failed/timed out. Error: $e');
    }

    // TIER 4: Older Last Known Position (< 30 minutes old)
    try {
      debugPrint('[LocationService] Tier 4: Fetching last known position (relaxed check)...');
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final age = DateTime.now().difference(lastKnown.timestamp).abs();
        debugPrint('[LocationService] Found last known position. Lat: ${lastKnown.latitude}, Lng: ${lastKnown.longitude}, Accuracy: ${lastKnown.accuracy}m, Age: ${age.inSeconds} seconds');
        if (age.inMinutes < 30) {
          debugPrint('[LocationService] Tier 4 Success: Last known position is within 30 mins limit. Using it.');
          return LocationResult.success(lastKnown);
        } else {
          debugPrint('[LocationService] Last known position is too stale (${age.inMinutes} mins old).');
        }
      }
    } catch (e) {
      debugPrint('[LocationService] Tier 4 check failed. Error: $e');
    }

    debugPrint('[LocationService] All tiers failed/timed out. Returning LocationError.timeout.');
    return LocationResult.failure(LocationError.timeout);
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
