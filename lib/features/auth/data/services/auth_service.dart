import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/token_storage.dart';
import '../models/user_model.dart';

class UpdateInfo {
  const UpdateInfo({required this.version, required this.url, required this.changelog});
  final String version;
  final String url;
  final String changelog;
}

class LoginResult {
  const LoginResult({required this.accessToken, required this.user, this.updateInfo});
  final String accessToken;
  final UserModel user;
  final UpdateInfo? updateInfo;
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
      
      UpdateInfo? updateInfo;
      if (data['update_info'] != null) {
        final info = data['update_info'] as Map<String, dynamic>;
        updateInfo = UpdateInfo(
          version: info['version'] as String? ?? '',
          url: info['url'] as String? ?? '',
          changelog: info['changelog'] as String? ?? '',
        );
      }
      
      return LoginResult(accessToken: token, user: user, updateInfo: updateInfo);
    } on DioException catch (e) {
      if (e.response?.statusCode == 426) {
        final data = e.response?.data;
        if (data is Map<String, dynamic> && data['update_info'] != null) {
           final info = data['update_info'] as Map<String, dynamic>;
           throw UpdateRequiredException(
             message: data['message'] ?? 'Versi aplikasi Anda sudah usang. Silakan perbarui.',
             updateUrl: info['url'] as String? ?? '',
             changelog: info['changelog'] as String? ?? '',
           );
        }
      }
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

  /// Cek apakah versi aplikasi yang terpasang memerlukan pembaruan.
  Future<Map<String, dynamic>?> checkVersion({
    required String version,
    required String platform,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/system/mobile-versions/check',
        queryParameters: {
          'version': version,
          'platform': platform,
        },
      );
      return response.data;
    } on DioException {
      // Biarkan null agar tidak memblokir user saat offline atau server down.
      return null;
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
