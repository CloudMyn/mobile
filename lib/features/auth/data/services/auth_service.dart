import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/token_storage.dart';
import '../models/user_model.dart';

class LoginResult {
  const LoginResult({required this.accessToken, required this.user});
  final String accessToken;
  final UserModel user;
}

/// Service autentikasi: login, me, logout.
class AuthService {
  AuthService(this._dio, this._tokenStorage);

  final Dio _dio;
  final TokenStorage _tokenStorage;

  /// Login dengan NIP/email dan password.
  ///
  /// Field [email] di API menerima NIP atau email — kirim nilai NIP dari
  /// form login ke field ini.
  Future<LoginResult> login({
    required String email,
    required String password,
    required String deviceUuid,
    String? deviceName,
    String platform = 'android',
    String appVersion = '1.0.0',
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'type': 'mobile',
          'device_uuid': deviceUuid,
          if (deviceName != null) 'device_name': deviceName,
          'platform': platform,
          'app_version': appVersion,
        },
      );
      final data = response.data!;
      final token = data['access_token'] as String;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      return LoginResult(accessToken: token, user: user);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Ambil data user yang sedang login.
  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/auth/me');
      final data = response.data!['data'] as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Cabut token aktif dan hapus dari storage.
  Future<void> logout() async {
    try {
      await _dio.delete('/auth/logout');
    } on DioException {
      // Tetap lanjut logout lokal meski request gagal
    } finally {
      await _tokenStorage.clearAll();
    }
  }

  Exception _mapDioError(DioException e) {
    final err = e.error;
    if (err is ApiException) return err;
    if (err is NetworkException) return err;
    return ApiException(
      statusCode: e.response?.statusCode ?? 0,
      message: e.message ?? 'Terjadi kesalahan',
    );
  }
}
