/// Typed exception hierarchy untuk semua error dari API dan network.
///
/// Controller menangkap [ApiException] dan switch pada [errorCode]
/// untuk menampilkan pesan yang sesuai ke user.

class ApiException implements Exception {
  const ApiException({
    required this.statusCode,
    required this.message,
    this.errorCode,
  });

  final int statusCode;
  final String message;

  /// Error code dari backend — contoh: "ATTENDANCE_ALREADY_SUBMITTED".
  final String? errorCode;

  @override
  String toString() => 'ApiException($statusCode, $errorCode): $message';
}

class NetworkException implements Exception {
  const NetworkException([this.message = 'Tidak ada koneksi internet']);
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({String message = 'Sesi Anda telah berakhir'})
      : super(statusCode: 401, message: message);
}

class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
    required this.errors,
  }) : super(statusCode: 422);

  /// Map field → list pesan error, contoh: {"email": ["Email tidak valid"]}.
  final Map<String, List<String>> errors;

  String? fieldError(String field) => errors[field]?.firstOrNull;
}
