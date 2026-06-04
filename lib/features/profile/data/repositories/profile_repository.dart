import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> enrollFace(String faceDataBase64);
  Future<UserModel> deleteFace();
  Future<UserModel> updateProfilePhoto(File file);
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });
}

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dio);

  final Dio _dio;

  Exception _mapDioError(DioException e, String fallbackMessage) {
    final err = e.error;
    if (err is ApiException) return err;
    if (err is NetworkException) return err;
    return ApiException(
      statusCode: e.response?.statusCode ?? 0,
      message: e.message ?? fallbackMessage,
    );
  }

  @override
  Future<UserModel> enrollFace(String faceDataBase64) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/mobile/profile/face',
        data: {'face_data': faceDataBase64},
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal mendaftar wajah');
    }
  }

  @override
  Future<UserModel> deleteFace() async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        '/mobile/profile/face',
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menghapus data wajah');
    }
  }

  @override
  Future<UserModel> updateProfilePhoto(File file) async {
    try {
      final formData = FormData.fromMap({
        'profile_picture': await MultipartFile.fromFile(file.path),
      });
      final response = await _dio.put<Map<String, dynamic>>(
        '/mobile/profile',
        data: formData,
      );

      return ApiResponse.fromJson(
        response.data!,
        (data) => UserModel.fromJson(data as Map<String, dynamic>),
      ).data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memperbarui foto profil');
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final formData = FormData.fromMap({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      });
      await _dio.put<Map<String, dynamic>>(
        '/mobile/profile/password',
        data: formData,
      );
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memperbarui password');
    }
  }
}
