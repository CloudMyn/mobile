import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/session_manager.dart';
import '../../../../core/network/token_storage.dart';
import '../../data/services/auth_service.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../home/presentation/controllers/home_controller.dart';

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
        appVersion: '1.0.0',
      );

      await tokenStorage.saveToken(result.accessToken);
      sessionManager.setUser(result.user);

      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().refreshData();
      }

      FocusManager.instance.primaryFocus?.unfocus();
      Get.offAll(() => const HomePage());
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
}
