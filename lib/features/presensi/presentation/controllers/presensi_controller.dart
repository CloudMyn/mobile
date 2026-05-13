import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/attendance_config.dart';
import '../../data/models/attendance_submission.dart';
import '../../data/repositories/presensi_repository.dart';
import '../../data/services/face_service.dart';
import '../../data/services/location_service.dart';
import '../pages/face_capture_page.dart';
import '../pages/liveness_page.dart';

enum PresensiStep {
  idle,
  loadingConfig,
  liveness,
  faceEmbedding,
  faceCapture,
  uploading,
  geofenceCheck,
  submitting,
  success,
  error,
}

enum PresensiErrorType {
  configFailed,
  cameraPermissionDenied,
  livenessFailed,
  embeddingFailed,
  uploadFailed,
  locationPermissionDenied,
  locationPermissionPermanentlyDenied,
  locationServiceDisabled,
  locationTimeout,
  outsideGeofence,
  submitFailed,
}

class PresensiController extends GetxController {
  final PresensiRepository _repository;
  final FaceService _faceService;
  final LocationService _locationService;

  PresensiController({
    required PresensiRepository repository,
    required FaceService faceService,
    required LocationService locationService,
  })  : _repository = repository,
        _faceService = faceService,
        _locationService = locationService;

  // =========================================================================
  //  Reactive State
  // =========================================================================

  final step = PresensiStep.idle.obs;
  final config = Rx<AttendanceConfig?>(null);
  final errorType = Rx<PresensiErrorType?>(null);
  final errorMessage = Rx<String?>(null);

  /// Tipe presensi aktif (check-in / check-out)
  final activeType = Rx<AttendanceType?>(null);

  /// Bytes foto wajah hasil crop + compress
  final faceImageBytes = Rx<Uint8List?>(null);

  /// Embedding wajah dari server
  final faceEmbedding = Rx<List<double>?>(null);

  /// URL foto yang sudah diupload
  final uploadedFaceUrl = Rx<String?>(null);

  /// Posisi GPS saat ini
  final currentPosition = Rx<Position?>(null);

  /// Status berada di dalam / luar geofence
  final isInsideGeofence = false.obs;

  /// Jarak ke pusat geofence (meter)
  final distanceToFence = 0.0.obs;

  // =========================================================================
  //  Entry Point
  // =========================================================================

  /// Dipanggil saat user menekan tombol presensi masuk atau pulang.
  Future<void> startPresensi(AttendanceType type) async {
    if (step.value != PresensiStep.idle &&
        step.value != PresensiStep.success &&
        step.value != PresensiStep.error) {
      return; // guard double-tap
    }

    _reset();
    activeType.value = type;
    step.value = PresensiStep.loadingConfig;

    try {
      final cfg = await _repository.fetchConfig();
      config.value = cfg;
      await _proceedFromConfig(cfg);
    } catch (e) {
      _setError(PresensiErrorType.configFailed, 'Gagal memuat konfigurasi: $e');
    }
  }

  // =========================================================================
  //  Routing berdasarkan Config
  // =========================================================================

  Future<void> _proceedFromConfig(AttendanceConfig cfg) async {
    if (cfg.faceRecognition) {
      step.value = PresensiStep.liveness;
      final result = await Get.to<bool?>(() => LivenessPage());
      if (result != true) {
        _setError(
          PresensiErrorType.livenessFailed,
          'Liveness detection tidak berhasil. Silakan coba lagi.',
        );
        return;
      }
      await _handleFaceEmbedding();
    } else if (cfg.faceCapture) {
      step.value = PresensiStep.faceCapture;
      final imageBytes = await Get.to<Uint8List?>(() => FaceCapturePage());
      if (imageBytes == null) {
        step.value = PresensiStep.idle;
        return;
      }
      faceImageBytes.value = imageBytes;
      await _handleFaceUpload();
    } else {
      await _proceedAfterFace();
    }
  }

  // =========================================================================
  //  Face Embedding (face_recognition = true)
  // =========================================================================

  Future<void> _handleFaceEmbedding() async {
    // Setelah liveness, perlu foto untuk embedding
    step.value = PresensiStep.faceCapture;
    final imageBytes = await Get.to<Uint8List?>(() => FaceCapturePage());
    if (imageBytes == null) {
      step.value = PresensiStep.idle;
      return;
    }
    faceImageBytes.value = imageBytes;

    step.value = PresensiStep.faceEmbedding;
    try {
      final embedding = await _faceService.extractEmbedding(
        imageBytes,
        'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      faceEmbedding.value = embedding;
    } catch (e) {
      _setError(
          PresensiErrorType.embeddingFailed, 'Gagal memproses wajah: $e');
      return;
    }

    // Upload jika face_capture juga true
    if (config.value?.faceCapture == true) {
      await _handleFaceUpload();
    } else {
      await _proceedAfterFace();
    }
  }

  // =========================================================================
  //  Face Upload
  // =========================================================================

  Future<void> _handleFaceUpload() async {
    final bytes = faceImageBytes.value;
    if (bytes == null) {
      _setError(PresensiErrorType.uploadFailed, 'Data foto tidak tersedia');
      return;
    }

    step.value = PresensiStep.uploading;
    try {
      final url = await _faceService.uploadFaceImage(
        bytes,
        'face_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      uploadedFaceUrl.value = url;
    } catch (e) {
      _setError(PresensiErrorType.uploadFailed, 'Gagal upload foto: $e');
      return;
    }

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
  //  Submit Presensi
  // =========================================================================

  Future<void> _submitPresensi() async {
    step.value = PresensiStep.submitting;
    final pos = currentPosition.value;

    final request = AttendanceSubmissionRequest(
      type: activeType.value!,
      faceImageUrl: uploadedFaceUrl.value,
      faceEmbedding: faceEmbedding.value,
      latitude: pos?.latitude,
      longitude: pos?.longitude,
      accuracy: pos?.accuracy,
    );

    try {
      await _repository.submit(request);
      step.value = PresensiStep.success;
    } catch (e) {
      _setError(PresensiErrorType.submitFailed, 'Gagal submit presensi: $e');
    }
  }

  // =========================================================================
  //  Retry — lanjutkan dari step yang gagal
  // =========================================================================

  Future<void> retry() async {
    final err = errorType.value;
    if (err == null) return;
    errorType.value = null;
    errorMessage.value = null;

    switch (err) {
      case PresensiErrorType.configFailed:
        await startPresensi(activeType.value!);
      case PresensiErrorType.livenessFailed:
        await _proceedFromConfig(config.value!);
      case PresensiErrorType.embeddingFailed:
        await _handleFaceEmbedding();
      case PresensiErrorType.uploadFailed:
        await _handleFaceUpload();
      case PresensiErrorType.locationPermissionDenied:
      case PresensiErrorType.locationPermissionPermanentlyDenied:
      case PresensiErrorType.locationServiceDisabled:
      case PresensiErrorType.locationTimeout:
        await _handleGeofenceCheck();
      case PresensiErrorType.outsideGeofence:
        await _handleGeofenceCheck();
      case PresensiErrorType.submitFailed:
        await _submitPresensi();
      case PresensiErrorType.cameraPermissionDenied:
        await _proceedFromConfig(config.value!);
    }
  }

  /// Batalkan proses dan kembali ke idle
  void cancel() {
    _reset();
  }

  // =========================================================================
  //  Helpers
  // =========================================================================

  void _reset() {
    step.value = PresensiStep.idle;
    config.value = null;
    errorType.value = null;
    errorMessage.value = null;
    faceImageBytes.value = null;
    faceEmbedding.value = null;
    uploadedFaceUrl.value = null;
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
      step.value == PresensiStep.loadingConfig ||
      step.value == PresensiStep.faceEmbedding ||
      step.value == PresensiStep.uploading ||
      step.value == PresensiStep.submitting;

  String get stepLabel => switch (step.value) {
        PresensiStep.idle => '',
        PresensiStep.loadingConfig => 'Memuat konfigurasi...',
        PresensiStep.liveness => 'Liveness detection',
        PresensiStep.faceEmbedding => 'Memproses wajah...',
        PresensiStep.faceCapture => 'Ambil foto wajah',
        PresensiStep.uploading => 'Mengupload foto...',
        PresensiStep.geofenceCheck => 'Memeriksa lokasi...',
        PresensiStep.submitting => 'Menyimpan presensi...',
        PresensiStep.success => 'Presensi berhasil!',
        PresensiStep.error => 'Terjadi kesalahan',
      };
}
