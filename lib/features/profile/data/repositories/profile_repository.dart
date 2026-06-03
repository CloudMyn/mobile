import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRepository {
  Future<UserModel> enrollFace(String faceDataBase64);
}

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dio);

  final Dio _dio;

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
      final err = e.error;
      if (err is ApiException) throw err;
      if (err is NetworkException) throw err;
      throw ApiException(
        statusCode: e.response?.statusCode ?? 0,
        message: e.message ?? 'Gagal mendaftar wajah',
      );
    }
  }
}
