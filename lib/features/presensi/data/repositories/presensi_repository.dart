import 'package:flutter/foundation.dart';
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
    debugPrint('[PresensiRepositoryImpl] submit: Starting presence request...');
    try {
      final Map<String, dynamic> dataMap = {
        'shift_no': request.shiftNo,
        if (request.latitude != null) 'latitude': request.latitude,
        if (request.longitude != null) 'longitude': request.longitude,
        if (request.accuracyMeters != null)
          'accuracy_meters': request.accuracyMeters,
        if (request.distanceMeters != null)
          'distance_meters': request.distanceMeters,
        'device_uuid': request.deviceUuid,
        if (request.faceScore != null) 'face_score': request.faceScore,
        if (request.note != null) 'note': request.note,
      };

      debugPrint('[PresensiRepositoryImpl] submit: Form fields data: $dataMap');

      if (request.photoBytes != null) {
        debugPrint('[PresensiRepositoryImpl] submit: Attaching photo of size ${request.photoBytes!.length} bytes');
      } else {
        debugPrint('[PresensiRepositoryImpl] submit: No photo attached');
      }

      final formData = FormData.fromMap({
        ...dataMap,
        if (request.photoBytes != null)
          'photo': MultipartFile.fromBytes(
            request.photoBytes!,
            filename:
                'attendance_${DateTime.now().millisecondsSinceEpoch}.jpg',
            contentType: DioMediaType('image', 'jpeg'),
          ),
      });

      final url = '/mobile/presensi/${request.code}';
      debugPrint('[PresensiRepositoryImpl] submit: Sending POST to $url');

      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: formData,
      );

      debugPrint('[PresensiRepositoryImpl] submit: Received response status: ${response.statusCode}');
      debugPrint('[PresensiRepositoryImpl] submit: Response data: ${response.data}');

      if (response.data == null) {
        throw ApiException(
          statusCode: response.statusCode ?? 0,
          message: 'Response data is empty',
        );
      }

      final parsedResponse = ApiResponse.fromJson(
        response.data!,
        (data) => AttendanceSubmissionResponse.fromJson(
            data as Map<String, dynamic>),
      ).data!;

      return parsedResponse;
    } on DioException catch (e) {
      debugPrint('[PresensiRepositoryImpl] submit: DioException encountered: ${e.message}');
      if (e.response != null) {
        debugPrint('[PresensiRepositoryImpl] submit: Error response: ${e.response?.statusCode} - ${e.response?.data}');
      }
      final err = e.error;
      if (err is ApiException) throw err;
      if (err is NetworkException) throw err;
      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Gagal submit presensi',
      );
    } catch (e) {
      debugPrint('[PresensiRepositoryImpl] submit: Unexpected error: $e');
      rethrow;
    }
  }
}
