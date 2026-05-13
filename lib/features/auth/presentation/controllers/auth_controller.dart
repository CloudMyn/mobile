import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../home/presentation/pages/home_page.dart';

class AuthController extends GetxController {
  final nipController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  @override
  void onClose() {
    nipController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  String? validateNip(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'NIP tidak boleh kosong';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kata sandi tidak boleh kosong';
    }
    return null;
  }

  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;

    try {
      // Simulasi proses login
      await Future.delayed(const Duration(seconds: 2));

      final nip = nipController.text.trim();
      final password = passwordController.text.trim();
      debugPrint('Login attempt — NIP: $nip | Password length: ${password.length}');

      // Navigasi ke halaman home, hapus semua route sebelumnya
      Get.offAll(() => const HomePage());
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
