import 'package:flutter/foundation.dart';
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
  String? _cachedToken;

  // ── Token ───────────────────────────────────────────────────────────────────

  Future<String?> getToken() async {
    if (_cachedToken != null) {
      return _cachedToken;
    }
    try {
      _cachedToken = await _storage.read(key: AppConstants.secureKeyAccessToken);
      return _cachedToken;
    } catch (e, stack) {
      debugPrint('TokenStorage: Error reading token: $e\n$stack');
      return null;
    }
  }

  Future<void> saveToken(String token) async {
    try {
      _cachedToken = token;
      await _storage.write(key: AppConstants.secureKeyAccessToken, value: token);
    } catch (e, stack) {
      debugPrint('TokenStorage: Error saving token: $e\n$stack');
    }
  }

  Future<void> clearToken() async {
    try {
      _cachedToken = null;
      await _storage.delete(key: AppConstants.secureKeyAccessToken);
    } catch (e, stack) {
      debugPrint('TokenStorage: Error clearing token: $e\n$stack');
    }
  }

  // ── Device UUID ─────────────────────────────────────────────────────────────

  /// Mengembalikan device UUID. Jika belum ada, buat UUID v4 baru dan simpan.
  /// UUID sama digunakan di setiap login request agar perangkat dikenali.
  Future<String> getOrCreateDeviceUuid() async {
    try {
      final existing = await _storage.read(key: AppConstants.secureKeyDeviceUuid);
      if (existing != null && existing.isNotEmpty) return existing;
    } catch (e, stack) {
      debugPrint('TokenStorage: Error reading device UUID: $e\n$stack');
      try {
        await _storage.deleteAll();
      } catch (_) {}
    }

    final newUuid = const Uuid().v4();
    try {
      await _storage.write(key: AppConstants.secureKeyDeviceUuid, value: newUuid);
    } catch (e, stack) {
      debugPrint('TokenStorage: Error saving device UUID: $e\n$stack');
    }
    return newUuid;
  }

  Future<void> clearAll() async {
    try {
      _cachedToken = null;
      await _storage.delete(key: AppConstants.secureKeyAccessToken);
    } catch (e, stack) {
      debugPrint('TokenStorage: Error clearAll: $e\n$stack');
    }
    // UUID tidak di-clear agar perangkat tetap dikenali setelah logout
  }
}
