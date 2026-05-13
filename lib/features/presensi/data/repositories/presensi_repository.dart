import 'package:dio/dio.dart';
import '../models/attendance_config.dart';
import '../models/attendance_submission.dart';

abstract class PresensiRepository {
  Future<AttendanceConfig> fetchConfig();
  Future<AttendanceSubmissionResponse> submit(
      AttendanceSubmissionRequest request);
}

class PresensiRepositoryImpl implements PresensiRepository {
  final Dio _dio;

  PresensiRepositoryImpl(this._dio);

  @override
  Future<AttendanceConfig> fetchConfig() async {
    final response =
        await _dio.get<Map<String, dynamic>>('/presensi/config');
    final data = response.data;
    if (data == null) throw Exception('Konfigurasi presensi tidak ditemukan');
    return AttendanceConfig.fromJson(data);
  }

  @override
  Future<AttendanceSubmissionResponse> submit(
      AttendanceSubmissionRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/presensi/submit',
      data: request.toJson(),
    );
    final data = response.data;
    if (data == null) throw Exception('Response tidak valid');
    return AttendanceSubmissionResponse.fromJson(data);
  }
}

/// Implementasi mock untuk development dan testing
class MockPresensiRepository implements PresensiRepository {
  /// Ubah nilai ini untuk mensimulasikan skenario berbeda
  final AttendanceConfig mockConfig;
  final bool shouldFail;
  final Duration delay;

  MockPresensiRepository({
    this.mockConfig = const AttendanceConfig(
      faceRecognition: false,
      faceCapture: true,
      geofenceEnabled: true,
      requiredLocation: true,
      geofenceLat: -4.604483,
      geofenceLng: 119.873190,
      geofenceRadius: 200,
    ),
    this.shouldFail = false,
    this.delay = const Duration(milliseconds: 800),
  });

  @override
  Future<AttendanceConfig> fetchConfig() async {
    await Future.delayed(delay);
    if (shouldFail) throw Exception('Gagal memuat konfigurasi (mock)');
    return mockConfig;
  }

  @override
  Future<AttendanceSubmissionResponse> submit(
      AttendanceSubmissionRequest request) async {
    await Future.delayed(delay);
    if (shouldFail) throw Exception('Gagal submit presensi (mock)');
    return AttendanceSubmissionResponse(
      success: true,
      message: '${request.type.label} berhasil dicatat',
      recordedAt: DateTime.now().toIso8601String(),
    );
  }
}
