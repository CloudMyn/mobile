import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../error/app_exception.dart';
import 'token_storage.dart';

/// Dio interceptor yang:
/// 1. Menyuntikkan Bearer token ke setiap request.
/// 2. Menangani 401 → clear token + redirect ke LoginPage.
/// 3. Mengubah error response menjadi [ApiException] yang typed.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenStorage);

  final TokenStorage _tokenStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    // Tidak ada response → masalah koneksi
    if (response == null) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const NetworkException(),
          type: err.type,
        ),
      );
    }

    final statusCode = response.statusCode ?? 0;

    // 401 Unauthorized — token expired atau tidak valid
    if (statusCode == 401) {
      _tokenStorage.clearToken().then((_) {
        // Hindari navigate ganda jika sudah di LoginPage
        if (Get.currentRoute != '/LoginPage') {
          Get.offAll(() => const LoginPage());
        }
      });
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          response: response,
          error: const UnauthorizedException(),
          type: err.type,
        ),
      );
    }

    // Parse error body dari backend
    final data = response.data;
    String message = 'Terjadi kesalahan';
    String? errorCode;
    Map<String, List<String>> validationErrors = {};

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ?? message;
      errorCode = data['error_code'] as String?;

      // 422 Validation errors
      if (statusCode == 422 && data['errors'] is Map) {
        final raw = data['errors'] as Map<String, dynamic>;
        validationErrors = raw.map(
          (key, value) => MapEntry(
            key,
            (value as List<dynamic>).map((e) => e.toString()).toList(),
          ),
        );
      }
    }

    final exception = statusCode == 422
        ? ValidationException(message: message, errors: validationErrors)
        : ApiException(
            statusCode: statusCode,
            message: message,
            errorCode: errorCode,
          );

    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: response,
        error: exception,
        type: err.type,
      ),
    );
  }
}
