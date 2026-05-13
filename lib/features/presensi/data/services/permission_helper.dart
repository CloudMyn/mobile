import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:permission_handler/permission_handler.dart';

/// True hanya di Android dan iOS — platform yang mengenal permission model
/// berbasis `permission_handler`. Di desktop (Windows/macOS/Linux) dan web,
/// permission dikelola oleh sistem operasi tanpa plugin ini.
bool get _isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

class PermissionHelper {
  /// Minta permission kamera. Mengembalikan true jika diizinkan atau
  /// jika platform tidak memerlukan permission eksplisit.
  static Future<bool> requestCamera() => _request(Permission.camera);

  /// Minta permission lokasi.
  static Future<bool> requestLocation() => _request(Permission.location);

  /// Status permission kamera saat ini.
  static Future<PermissionStatus> cameraStatus() => _status(Permission.camera);

  /// Status permission lokasi saat ini.
  static Future<PermissionStatus> locationStatus() =>
      _status(Permission.location);

  static Future<bool> _request(Permission permission) async {
    if (!_isMobile) return true;
    try {
      final status = await permission.request();
      return status.isGranted;
    } on MissingPluginException {
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<PermissionStatus> _status(Permission permission) async {
    if (!_isMobile) return PermissionStatus.granted;
    try {
      return await permission.status;
    } on MissingPluginException {
      return PermissionStatus.granted;
    } catch (_) {
      return PermissionStatus.denied;
    }
  }
}
