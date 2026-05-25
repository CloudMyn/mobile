import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';

/// Wrapper di atas [FlutterSecureStorage] untuk menyimpan token dan device UUID.
///
/// Di-register permanent di AppBindings. Disuntikkan ke AuthInterceptor
/// dan AuthService via constructor (bukan Get.find di dalam interceptor).
class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  // ── Token ───────────────────────────────────────────────────────────────────

  Future<String?> getToken() =>
      _storage.read(key: AppConstants.secureKeyAccessToken);

  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.secureKeyAccessToken, value: token);

  Future<void> clearToken() =>
      _storage.delete(key: AppConstants.secureKeyAccessToken);

  // ── Device UUID ─────────────────────────────────────────────────────────────

  /// Mengembalikan device UUID. Jika belum ada, buat UUID v4 baru dan simpan.
  /// UUID sama digunakan di setiap login request agar perangkat dikenali.
  Future<String> getOrCreateDeviceUuid() async {
    final existing = await _storage.read(key: AppConstants.secureKeyDeviceUuid);
    if (existing != null && existing.isNotEmpty) return existing;
    final newUuid = const Uuid().v4();
    await _storage.write(key: AppConstants.secureKeyDeviceUuid, value: newUuid);
    return newUuid;
  }

  Future<void> clearAll() async {
    await _storage.delete(key: AppConstants.secureKeyAccessToken);
    // UUID tidak di-clear agar perangkat tetap dikenali setelah logout
  }
}
