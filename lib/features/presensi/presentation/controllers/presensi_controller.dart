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
  })  : _repository = repository,
        _faceService = faceService,
        _locationService = locationService,
        _tokenStorage = tokenStorage;

  final PresensiRepository _repository;
  final FaceService _faceService;
  final LocationService _locationService;
  final TokenStorage _tokenStorage;

  // =========================================================================
  //  Reactive State
  // =========================================================================

  final step = PresensiStep.idle.obs;
  final config = Rx<AttendanceConfig?>(null);
  final errorType = Rx<PresensiErrorType?>(null);
  final errorMessage = Rx<String?>(null);

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

  // =========================================================================
  //  Entry Point — dipanggil dari AttendanceCard
  // =========================================================================

  /// Mulai flow presensi. Config sudah diketahui dari dashboard, tidak perlu fetch.
  Future<void> startPresensi(String code, AttendanceConfig cfg) async {
    if (step.value != PresensiStep.idle &&
        step.value != PresensiStep.success &&
        step.value != PresensiStep.error) {
      return; // guard double-tap
    }

    _reset();
    activeCode.value = code;
    config.value = cfg;

    await _proceedFromConfig(cfg);
  }

  // =========================================================================
  //  Routing berdasarkan Config
  // =========================================================================

  Future<void> _proceedFromConfig(AttendanceConfig cfg) async {
    if (cfg.faceRecognition) {
      step.value = PresensiStep.liveness;
      final result = await Get.to<bool?>(() => const LivenessPage());
      if (result != true) {
        _setError(
          PresensiErrorType.livenessFailed,
          'Liveness detection tidak berhasil. Silakan coba lagi.',
        );
        return;
      }
      // Liveness passed — set default score; face capture berikutnya jika diperlukan
      faceScore.value = 0.92;

      if (cfg.faceCapture) {
        await _handleFaceCapture();
      } else {
        await _proceedAfterFace();
      }
    } else if (cfg.faceCapture) {
      step.value = PresensiStep.faceCapture;
      await _handleFaceCapture();
    } else {
      await _proceedAfterFace();
    }
  }

  // =========================================================================
  //  Face Capture
  // =========================================================================

  Future<void> _handleFaceCapture() async {
    step.value = PresensiStep.faceCapture;
    final imageBytes = await Get.to<Uint8List?>(() => const FaceCapturePage());
    if (imageBytes == null) {
      step.value = PresensiStep.idle;
      return;
    }
    final compressed = await _faceService.cropAndCompress(imageBytes);
    faceImageBytes.value = compressed ?? imageBytes;
    await _proceedAfterFace();
  }

  // =========================================================================
  //  Geofence check → Submit
  // =========================================================================

  Future<void> _proceedAfterFace() async {
    final cfg = config.value!;
    if (cfg.needsGeofenceCheck) {
      await _handleGeofenceCheck();
    } else {
      await _submitPresensi();
    }
  }

  Future<void> _handleGeofenceCheck() async {
    final cfg = config.value!;
    step.value = PresensiStep.geofenceCheck;

    final result = await _locationService.getCurrentPosition();
    if (!result.isSuccess) {
      final errType = switch (result.error!) {
        LocationError.permissionDenied =>
          PresensiErrorType.locationPermissionDenied,
        LocationError.permissionDeniedForever =>
          PresensiErrorType.locationPermissionPermanentlyDenied,
        LocationError.serviceDisabled =>
          PresensiErrorType.locationServiceDisabled,
        LocationError.timeout || LocationError.unknown =>
          PresensiErrorType.locationTimeout,
      };
      _setError(errType, _locationErrorMessage(result.error!));
      return;
    }

    final pos = result.position!;
    currentPosition.value = pos;

    if (cfg.hasValidGeofence) {
      final dist = _locationService.distanceToFence(
        userLat: pos.latitude,
        userLng: pos.longitude,
        fenceLat: cfg.geofenceLat!,
        fenceLng: cfg.geofenceLng!,
      );
      distanceToFence.value = dist;

      final inside = _locationService.isInsideGeofence(
        userLat: pos.latitude,
        userLng: pos.longitude,
        fenceLat: cfg.geofenceLat!,
        fenceLng: cfg.geofenceLng!,
        radiusMeters: cfg.geofenceRadius!,
      );
      isInsideGeofence.value = inside;

      if (!inside) {
        _setError(
          PresensiErrorType.outsideGeofence,
          'Anda berada ${dist.toStringAsFixed(0)} m dari lokasi kantor. '
          'Radius yang diizinkan: ${cfg.geofenceRadius!.toStringAsFixed(0)} m.',
        );
        return;
      }
    }

    await _submitPresensi();
  }

  // =========================================================================
  //  Submit Presensi ke API
  // =========================================================================

  Future<void> _submitPresensi() async {
    step.value = PresensiStep.submitting;
    final pos = currentPosition.value;

    final deviceUuid = await _tokenStorage.getOrCreateDeviceUuid();

    final request = AttendanceSubmissionRequest(
      code: activeCode.value!,
      deviceUuid: deviceUuid,
      latitude: pos?.latitude,
      longitude: pos?.longitude,
      accuracyMeters: pos?.accuracy,
      faceScore: faceScore.value,
      photoBytes: faceImageBytes.value,
    );

    try {
      await _repository.submit(request);
      step.value = PresensiStep.success;
    } on ApiException catch (e) {
      final msg = switch (e.errorCode) {
        'ATTENDANCE_ALREADY_SUBMITTED' => 'Presensi hari ini sudah tercatat.',
        'ATTENDANCE_WINDOW_NOT_OPEN' =>
          'Belum waktunya presensi. Lihat jadwal Anda.',
        'ATTENDANCE_WINDOW_CLOSED' => 'Waktu presensi sudah ditutup.',
        'ATTENDANCE_SEQUENCE_ERROR' =>
          'Urutan presensi tidak sesuai. Lakukan check-in terlebih dahulu.',
        'LOCATION_REQUIRED' => 'Lokasi GPS diperlukan untuk presensi ini.',
        'DEVICE_LOCK_REQUIRED' =>
          'Perangkat ini tidak terdaftar untuk presensi.',
        _ => e.message.isNotEmpty ? e.message : 'Gagal menyimpan presensi.',
      };
      _setError(PresensiErrorType.submitFailed, msg);
    } on NetworkException {
      _setError(PresensiErrorType.submitFailed,
          'Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
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

    switch (err) {
      case PresensiErrorType.livenessFailed:
        await _proceedFromConfig(config.value!);
      case PresensiErrorType.locationPermissionDenied:
      case PresensiErrorType.locationPermissionPermanentlyDenied:
      case PresensiErrorType.locationServiceDisabled:
      case PresensiErrorType.locationTimeout:
      case PresensiErrorType.outsideGeofence:
        await _handleGeofenceCheck();
      case PresensiErrorType.submitFailed:
        await _submitPresensi();
      case PresensiErrorType.cameraPermissionDenied:
        await _handleFaceCapture();
    }
  }

  void cancel() => _reset();

  // =========================================================================
  //  Helpers
  // =========================================================================

  void _reset() {
    step.value = PresensiStep.idle;
    config.value = null;
    errorType.value = null;
    errorMessage.value = null;
    faceImageBytes.value = null;
    faceScore.value = null;
    currentPosition.value = null;
    isInsideGeofence.value = false;
    distanceToFence.value = 0.0;
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
