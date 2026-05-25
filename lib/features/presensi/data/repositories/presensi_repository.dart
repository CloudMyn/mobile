import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/attendance_submission.dart';

abstract class PresensiRepository {
  Future<AttendanceSubmissionResponse> submit(AttendanceSubmissionRequest request);
}

class PresensiRepositoryImpl implements PresensiRepository {
  PresensiRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<AttendanceSubmissionResponse> submit(
      AttendanceSubmissionRequest request) async {
    try {
      final formData = FormData.fromMap({
        'shift_no': request.shiftNo,
        if (request.latitude != null) 'latitude': request.latitude,
        if (request.longitude != null) 'longitude': request.longitude,
        if (request.accuracyMeters != null)
          'accuracy_meters': request.accuracyMeters,
        'device_uuid': request.deviceUuid,
        if (request.faceScore != null) 'face_score': request.faceScore,
        if (request.photoBytes != null)
          'photo': MultipartFile.fromBytes(
            request.photoBytes!,
            filename:
                'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg',
            contentType: DioMediaType('image', 'jpeg'),
          ),
        if (request.note != null) 'note': request.note,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/mobile/presensi/${request.code}',
        data: formData,
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => AttendanceSubmissionResponse.fromJson(
            data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      final err = e.error;
      if (err is ApiException) throw err;
      if (err is NetworkException) throw err;
      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Gagal submit presensi',
      );
    }
  }
}
