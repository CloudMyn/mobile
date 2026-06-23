import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/session_manager.dart';
import '../../../../core/network/token_storage.dart';
import '../../data/services/auth_service.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../pages/leader_splash_page.dart';

class AuthController extends GetxController {
  final nipController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() => isPasswordVisible.toggle();

  String? validateNip(String? value) {
    if (value == null || value.trim().isEmpty) return 'NIP tidak boleh kosong';
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) return 'Kata sandi tidak boleh kosong';
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final authService = Get.find<AuthService>();
      final tokenStorage = Get.find<TokenStorage>();
      final sessionManager = Get.find<SessionManager>();

      final deviceUuid = await tokenStorage.getOrCreateDeviceUuid();

      final result = await authService.login(
        email: nipController.text.trim(),
        password: passwordController.text.trim(),
        deviceUuid: deviceUuid,
        platform: _detectPlatform(),
        appVersion: AppConstants.versionName,
      );

      await tokenStorage.saveToken(result.accessToken);
      sessionManager.setUser(result.user);

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshData();
      }

      FocusManager.instance.primaryFocus?.unfocus();

      if (result.updateInfo != null) {
        // Optional update
        _showUpdateBottomSheet(
          result.updateInfo!.url, 
          result.updateInfo!.changelog, 
          isForced: false,
          onContinue: () => Get.offAll(() => const LeaderSplashPage()),
        );
      } else {
        Get.offAll(() => const LeaderSplashPage());
      }
    } on UpdateRequiredException catch (e) {
      _showUpdateBottomSheet(e.updateUrl, e.changelog, isForced: true);
    } on ApiException catch (e) {
      _showError(_mapApiErrorMessage(e));
    } on NetworkException {
      _showError('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } catch (e) {
      _showError('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      isLoading.value = false;
    }
  }

  String _detectPlatform() {
    if (GetPlatform.isAndroid) return 'android';
    if (GetPlatform.isIOS) return 'ios';
    return 'android';
  }

  String _mapApiErrorMessage(ApiException e) {
    return switch (e.statusCode) {
      401 => 'NIP atau kata sandi salah.',
      422 => e.message.isNotEmpty ? e.message : 'Data login tidak valid.',
      429 => 'Terlalu banyak percobaan. Coba lagi nanti.',
      >= 500 => 'Server sedang bermasalah. Coba lagi nanti.',
      _ => e.message.isNotEmpty ? e.message : 'Terjadi kesalahan.',
    };
  }

  void _showError(String message) {
    Get.snackbar(
      'Login Gagal',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Get.theme.colorScheme.error,
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 4),
    );
  }

  void _showUpdateBottomSheet(String url, String changelog, {required bool isForced, VoidCallback? onContinue}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.system_update, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Pembaruan Tersedia',
              style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isForced
                  ? 'Versi aplikasi Anda sudah usang dan tidak didukung lagi. Silakan perbarui aplikasi untuk melanjutkan.'
                  : 'Versi baru aplikasi tersedia. Perbarui sekarang untuk mendapatkan fitur terbaru.',
              style: Get.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (changelog.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Get.theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  changelog,
                  style: Get.textTheme.bodySmall,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.colorScheme.primary,
                foregroundColor: Get.theme.colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              child: const Text('Update Sekarang', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (!isForced) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Get.back(); // Tutup bottom sheet
                  if (onContinue != null) onContinue();
                },
                child: const Text('Nanti Saja'),
              ),
            ],
          ],
        ),
      ),
      isDismissible: !isForced,
      enableDrag: !isForced,
    );
  }
}
