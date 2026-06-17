import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/token_storage.dart';
import '../../data/models/attendance_config.dart';
import '../../data/models/attendance_submission.dart';
import '../../data/repositories/presensi_repository.dart';
import '../../data/services/face_service.dart';
import '../../data/services/location_service.dart';
import '../pages/face_capture_page.dart';
import '../pages/liveness_page.dart';
import '../../../home/data/models/dashboard_model.dart';
import '../../../home/data/services/dashboard_service.dart';

enum PresensiStep {
  idle,
  liveness,
  faceCapture,
  geofenceCheck,
  submitting,
  success,
  error,
}

enum PresensiErrorType {
  cameraPermissionDenied,
  livenessFailed,
  locationPermissionDenied,
  locationPermissionPermanentlyDenied,
  locationServiceDisabled,
  locationTimeout,
  outsideGeofence,
  submitFailed,
}

class PresensiController extends GetxController {
  PresensiController({
    required PresensiRepository repository,
    required FaceService faceService,
    required LocationService locationService,
    required TokenStorage tokenStorage,
    required DashboardService dashboardService,
  }) : _repository = repository,
       _faceService = faceService,
       _locationService = locationService,
       _tokenStorage = tokenStorage,
       _dashboardService = dashboardService;

  final PresensiRepository _repository;
  final FaceService _faceService;
  final LocationService _locationService;
  final TokenStorage _tokenStorage;
  final DashboardService _dashboardService;

  // =========================================================================
  //  Reactive State
  // =========================================================================

  final step = PresensiStep.idle.obs;
  final config = Rx<AttendanceConfig?>(null);
  final errorType = Rx<PresensiErrorType?>(null);
  final errorMessage = Rx<String?>(null);

  /// Rekam presensi saat ini
  final activeRecord = Rx<TodayRecord?>(null);

  /// Code tipe presensi aktif — contoh: "check-in", "check-out"
  final activeCode = Rx<String?>(null);

  /// Bytes foto wajah hasil crop + compress
  final faceImageBytes = Rx<Uint8List?>(null);

  /// Face confidence score dari ML Kit (0.0–1.0)
  final faceScore = Rx<double?>(null);

  /// Posisi GPS saat ini
  final currentPosition = Rx<Position?>(null);

  /// Status berada di dalam / luar geofence
  final isInsideGeofence = false.obs;

  /// Jarak ke pusat geofence (meter)
  final distanceToFence = 0.0.obs;

  final closestLocationName = Rx<String?>(null);

  /// Nomor shift aktif untuk daily record
  final shiftNo = 1.obs;

  // =========================================================================
  //  Entry Point — dipanggil dari HomeController
  // =========================================================================

  void setConfig(TodayRecord record, AttendanceConfig cfg, {int shiftNo = 1}) {
    _reset();
    activeRecord.value = record;
    activeCode.value = record.attendanceType.code;
    config.value = cfg;
    this.shiftNo.value = shiftNo;
  }

  // =========================================================================
  //  Refresh Config — memanggil API dashboard untuk perbarui konfigurasi lokasi
  // =========================================================================

  Future<void> refreshLocationConfig() async {
    final record = activeRecord.value;
    if (record == null) {
      debugPrint(
        '[PresensiController] refreshLocationConfig: activeRecord is null',
      );
      return;
    }

    step.value = PresensiStep.geofenceCheck; // Tampilkan loading check lokasi

    try {
      debugPrint(
        '[PresensiController] refreshLocationConfig: Fetching dashboard data...',
      );
      final dashboard = await _dashboardService.fetchDashboard();

      // Update config dengan data terbaru
      final newConfig = AttendanceConfig.fromDashboard(dashboard, record);
      config.value = newConfig;
      debugPrint('[PresensiController] refreshLocationConfig: Config updated');

      // Setelah mendapatkan konfigurasi terbaru, cek ulang lokasi
      await checkLocation();
    } catch (e) {
      debugPrint('[PresensiController] refreshLocationConfig: Error $e');
      _setError(
        PresensiErrorType.locationTimeout,
        'Gagal memperbarui data lokasi presensi.',
      );
    }
  }

  // =========================================================================
  //  Location Checking — dipanggil saat PresencePage dibuka
  // =========================================================================

  Future<void> checkLocation() async {
    final cfg = config.value;
    if (cfg == null) {
      debugPrint('[PresensiController] checkLocation: config is null');
      return;
    }

    debugPrint(
      '[PresensiController] checkLocation: Starting location check. Needs geofence: ${cfg.needsGeofenceCheck}',
    );

    if (!cfg.needsGeofenceCheck) {
      debugPrint(
        '[PresensiController] checkLocation: Geofence check not required. Setting isInsideGeofence = true',
      );
      isInsideGeofence.value = true;

      // Ambil lokasi best-effort agar peta memiliki posisi untuk dirender
      step.value = PresensiStep.geofenceCheck;
      try {
        final result = await _locationService.getCurrentPosition();
        if (result.isSuccess) {
          currentPosition.value = result.position;
        }
      } catch (e) {
        debugPrint(
          '[PresensiController] checkLocation best-effort failed: $e',
        );
      }
      step.value = PresensiStep.idle;
      return;
    }

    step.value = PresensiStep.geofenceCheck;
    errorType.value = null;
    errorMessage.value = null;

    debugPrint(
      '[PresensiController] checkLocation: Fetching current position...',
    );
    final result = await _locationService.getCurrentPosition();
    if (!result.isSuccess) {
      debugPrint(
        '[PresensiController] checkLocation: Failed to get position. Error: ${result.error}',
      );
      final errType = switch (result.error!) {
        LocationError.permissionDenied =>
          PresensiErrorType.locationPermissionDenied,
        LocationError.permissionDeniedForever =>
          PresensiErrorType.locationPermissionPermanentlyDenied,
        LocationError.serviceDisabled =>
          PresensiErrorType.locationServiceDisabled,
        LocationError.timeout ||
        LocationError.unknown => PresensiErrorType.locationTimeout,
      };
      _setError(errType, _locationErrorMessage(result.error!));
      return;
    }

    final pos = result.position!;
    currentPosition.value = pos;
    debugPrint(
      '[PresensiController] checkLocation: Current position: Lat: ${pos.latitude}, Lng: ${pos.longitude}, Accuracy: ${pos.accuracy}m',
    );

    if (cfg.hasValidGeofence) {
      debugPrint(
        '[PresensiController] checkLocation: Config has valid geofence. Locations count: ${cfg.validLocations.length}',
      );
      double minDistance = double.infinity;
      bool anyInside = false;
      String? closestName;

      for (final loc in cfg.validLocations) {
        final r = loc.radiusMeters ?? cfg.defaultRadius;
        final dist = _locationService.distanceToFence(
          userLat: pos.latitude,
          userLng: pos.longitude,
          fenceLat: loc.latitude,
          fenceLng: loc.longitude,
        );

        debugPrint(
          '[PresensiController] checkLocation: Location "${loc.name}" (Lat: ${loc.latitude}, Lng: ${loc.longitude}), Radius: $r, Calculated Distance: ${dist.toStringAsFixed(2)}m',
        );

        if (dist < minDistance) {
          minDistance = dist;
          closestName = loc.name;
        }

        if (_locationService.isInsideGeofence(
          userLat: pos.latitude,
          userLng: pos.longitude,
          fenceLat: loc.latitude,
          fenceLng: loc.longitude,
          radiusMeters: r.toDouble(),
        )) {
          anyInside = true;
          debugPrint(
            '[PresensiController] checkLocation: User IS inside geofence for location "${loc.name}"',
          );
        }
      }

      distanceToFence.value = minDistance;
      isInsideGeofence.value = anyInside;
      closestLocationName.value = closestName;
      debugPrint(
        '[PresensiController] checkLocation: Min distance to closest fence: ${minDistance.toStringAsFixed(2)}m, isInsideGeofence: $anyInside, closestLocationName: $closestName',
      );
    } else {
      isInsideGeofence.value = true;
      debugPrint(
        '[PresensiController] checkLocation: No valid geofence configurations found. Setting isInsideGeofence = true',
      );
    }

    step.value = PresensiStep.idle;
  }

  // =========================================================================
  //  Lanjutkan Presensi — dipanggil dari tombol di PresencePage
  // =========================================================================

  Future<void> proceedPresensi() async {
    final cfg = config.value;
    if (cfg == null) {
      debugPrint('[PresensiController] proceedPresensi: config is null');
      return;
    }

    debugPrint(
      '[PresensiController] proceedPresensi: Proceeding. Active Code: ${activeCode.value}, FaceRecognition: ${cfg.faceRecognition}, FaceCapture: ${cfg.faceCapture}',
    );

    if (cfg.needsGeofenceCheck && !isInsideGeofence.value) {
      debugPrint(
        '[PresensiController] proceedPresensi: Blocked. User is outside geofence',
      );
      return; // Tombol seharusnya disabled
    }

    if (cfg.faceRecognition) {
      debugPrint(
        '[PresensiController] proceedPresensi: Starting liveness detection step...',
      );
      if (cfg.storedFaceData == null || cfg.storedFaceData!.isEmpty) {
        debugPrint(
          '[PresensiController] proceedPresensi: Error. Stored face data is empty/null',
        );
        _setError(
          PresensiErrorType.livenessFailed,
          'Wajah Anda belum terdaftar. Silakan daftarkan wajah terlebih dahulu melalui halaman Profil.',
        );
        return;
      }

      step.value = PresensiStep.liveness;
      final resultBytes = await Get.to<Uint8List?>(() => const LivenessPage());
      if (resultBytes == null) {
        debugPrint(
          '[PresensiController] proceedPresensi: Liveness cancelled or returned null bytes',
        );
        _setError(
          PresensiErrorType.livenessFailed,
          'Liveness detection tidak berhasil atau dibatalkan. Silakan coba lagi.',
        );
        return;
      }

      step.value = PresensiStep.submitting;
      debugPrint(
        '[PresensiController] proceedPresensi: Liveness success, result bytes length: ${resultBytes.length}. Extracting embedding...',
      );

      try {
        final liveResult = await _faceService.extractEmbeddingFromBytes(
          resultBytes,
        );
        if (liveResult == null) {
          debugPrint(
            '[PresensiController] proceedPresensi: Failed to extract embedding (face not detected)',
          );
          _setError(
            PresensiErrorType.livenessFailed,
            'Wajah tidak terdeteksi pada foto.',
          );
          return;
        }

        debugPrint(
          '[PresensiController] proceedPresensi: Embedding extracted. Comparing with stored embedding...',
        );
        final storedEmb = _faceService.base64ToEmbedding(cfg.storedFaceData!);
        final verifyResult = _faceService.verify(
          liveResult.embedding,
          storedEmb,
        );
        debugPrint(
          '[PresensiController] proceedPresensi: Verification result - Match: ${verifyResult.isMatch}, Cosine Similarity: ${verifyResult.cosineSimilarity}, Euclidean Distance: ${verifyResult.euclideanDistance}',
        );

        if (!verifyResult.isMatch) {
          _setError(
            PresensiErrorType.livenessFailed,
            'Wajah tidak dikenali. Pastikan Anda menghadap kamera dengan jelas.',
          );
          return;
        }

        faceScore.value = verifyResult.cosineSimilarity;
        faceImageBytes.value = liveResult.processedImageBytes ?? resultBytes;

        debugPrint(
          '[PresensiController] proceedPresensi: Face matched. Proceeding to submit...',
        );
        await _submitPresensi();
      } catch (e) {
        debugPrint(
          '[PresensiController] proceedPresensi: Exception during face matching: $e',
        );
        _setError(
          PresensiErrorType.livenessFailed,
          'Gagal memproses pengenalan wajah.',
        );
        return;
      }
    } else if (cfg.faceCapture) {
      debugPrint(
        '[PresensiController] proceedPresensi: Starting face capture...',
      );
      step.value = PresensiStep.faceCapture;
      await _handleFaceCapture();
    } else {
      debugPrint(
        '[PresensiController] proceedPresensi: Direct submit (no face verification/capture required)...',
      );
      await _submitPresensi();
    }
  }

  // =========================================================================
  //  Face Capture
  // =========================================================================

  Future<void> _handleFaceCapture() async {
    step.value = PresensiStep.faceCapture;
    debugPrint(
      '[PresensiController] _handleFaceCapture: Opening FaceCapturePage...',
    );
    final imageBytes = await Get.to<Uint8List?>(() => const FaceCapturePage());
    if (imageBytes == null) {
      debugPrint(
        '[PresensiController] _handleFaceCapture: FaceCapture cancelled or returned null',
      );
      step.value = PresensiStep.idle;
      return;
    }
    debugPrint(
      '[PresensiController] _handleFaceCapture: Captured image bytes length: ${imageBytes.length}. Cropping and compressing...',
    );
    final compressed = await _faceService.cropAndCompress(imageBytes);
    faceImageBytes.value = compressed ?? imageBytes;
    debugPrint(
      '[PresensiController] _handleFaceCapture: Final compressed image bytes length: ${faceImageBytes.value?.length}. Submitting presence...',
    );
    await _submitPresensi();
  }

  // =========================================================================
  //  Submit Presensi ke API
  // =========================================================================

  Future<void> _submitPresensi() async {
    step.value = PresensiStep.submitting;
    final pos = currentPosition.value;

    debugPrint(
      '[PresensiController] _submitPresensi: Generating/fetching device UUID...',
    );
    final deviceUuid = await _tokenStorage.getOrCreateDeviceUuid();

    debugPrint(
      '[PresensiController] _submitPresensi: Preparing submission request. '
      'Code: ${activeCode.value}, '
      'Device UUID: $deviceUuid, '
      'Latitude: ${pos?.latitude}, '
      'Longitude: ${pos?.longitude}, '
      'Accuracy: ${pos?.accuracy}m, '
      'Distance: ${distanceToFence.value}m, '
      'Face Score: ${faceScore.value}, '
      'Photo length: ${faceImageBytes.value?.length ?? 0} bytes',
    );

    final request = AttendanceSubmissionRequest(
      code: activeCode.value!,
      shiftNo: shiftNo.value,
      deviceUuid: deviceUuid,
      latitude: pos?.latitude,
      longitude: pos?.longitude,
      accuracyMeters: pos?.accuracy,
      distanceMeters: distanceToFence.value,
      faceScore: faceScore.value,
      photoBytes: faceImageBytes.value,
    );

    try {
      debugPrint(
        '[PresensiController] _submitPresensi: Submitting via repository...',
      );
      final response = await _repository.submit(request);
      debugPrint(
        '[PresensiController] _submitPresensi: Submission SUCCESS! ID: ${response.id}, Status: ${response.status}, AttendedAt: ${response.attendedAt}',
      );
      step.value = PresensiStep.success;
    } on ApiException catch (e) {
      debugPrint(
        '[PresensiController] _submitPresensi: ApiException: ${e.statusCode} - ${e.errorCode} - ${e.message}',
      );
      final msg = switch (e.errorCode) {
        'ATTENDANCE_ALREADY_SUBMITTED' => 'Presensi hari ini sudah tercatat.',
        'ATTENDANCE_WINDOW_NOT_OPEN' =>
          'Belum waktunya presensi. Lihat jadwal Anda.',
        'ATTENDANCE_WINDOW_CLOSED' => 'Waktu presensi sudah ditutup.',
        'ATTENDANCE_SEQUENCE_ERROR' =>
          'Urutan presensi tidak sesuai. Lakukan presensi sebelumnya terlebih dahulu.',
        'LOCATION_REQUIRED' => 'Lokasi GPS diperlukan untuk presensi ini.',
        'DEVICE_LOCK_REQUIRED' =>
          'Perangkat ini tidak terdaftar untuk presensi.',
        _ => e.message.isNotEmpty ? e.message : 'Gagal menyimpan presensi.',
      };
      _setError(PresensiErrorType.submitFailed, msg);
    } on NetworkException catch (e) {
      debugPrint('[PresensiController] _submitPresensi: NetworkException: $e');
      _setError(
        PresensiErrorType.submitFailed,
        'Tidak ada koneksi internet. Periksa jaringan Anda.',
      );
    } catch (e) {
      debugPrint('[PresensiController] _submitPresensi: Unknown exception: $e');
      _setError(PresensiErrorType.submitFailed, 'Gagal submit presensi: $e');
    }
  }

  // =========================================================================
  //  Retry
  // =========================================================================

  Future<void> retry() async {
    final err = errorType.value;
    if (err == null || config.value == null || activeCode.value == null) return;
    errorType.value = null;
    errorMessage.value = null;
    step.value = PresensiStep.idle;

    switch (err) {
      case PresensiErrorType.locationPermissionDenied:
      case PresensiErrorType.locationPermissionPermanentlyDenied:
      case PresensiErrorType.locationServiceDisabled:
      case PresensiErrorType.locationTimeout:
      case PresensiErrorType.outsideGeofence:
        await checkLocation();
      case PresensiErrorType.livenessFailed:
      case PresensiErrorType.cameraPermissionDenied:
        await proceedPresensi();
      case PresensiErrorType.submitFailed:
        await _submitPresensi();
    }
  }

  void cancel() => _reset();

  // =========================================================================
  //  Helpers
  // =========================================================================

  void _reset() {
    step.value = PresensiStep.idle;
    config.value = null;
    activeRecord.value = null;
    errorType.value = null;
    errorMessage.value = null;
    faceImageBytes.value = null;
    faceScore.value = null;
    currentPosition.value = null;
    isInsideGeofence.value = false;
    distanceToFence.value = 0.0;
    closestLocationName.value = null;
    shiftNo.value = 1;
  }

  void _setError(PresensiErrorType type, String message) {
    errorType.value = type;
    errorMessage.value = message;
    step.value = PresensiStep.error;
    debugPrint('[PresensiController] Error ($type): $message');
  }

  String _locationErrorMessage(LocationError err) {
    return switch (err) {
      LocationError.permissionDenied =>
        'Izin lokasi diperlukan untuk presensi. Silakan berikan akses lokasi.',
      LocationError.permissionDeniedForever =>
        'Izin lokasi diblokir permanen. Buka Pengaturan → Izin Aplikasi untuk mengaktifkan.',
      LocationError.serviceDisabled =>
        'Layanan GPS tidak aktif. Aktifkan lokasi di pengaturan perangkat.',
      LocationError.timeout || LocationError.unknown =>
        'Gagal mendapatkan lokasi. Pastikan GPS aktif dan coba lagi.',
    };
  }

  // =========================================================================
  //  Computed
  // =========================================================================

  bool get isLoading =>
      step.value == PresensiStep.geofenceCheck ||
      step.value == PresensiStep.submitting;

  String get stepLabel => switch (step.value) {
    PresensiStep.idle => '',
    PresensiStep.liveness => 'Liveness detection',
    PresensiStep.faceCapture => 'Ambil foto wajah',
    PresensiStep.geofenceCheck => 'Memeriksa lokasi...',
    PresensiStep.submitting => 'Menyimpan presensi...',
    PresensiStep.success => 'Presensi berhasil!',
    PresensiStep.error => 'Terjadi kesalahan',
  };
}
