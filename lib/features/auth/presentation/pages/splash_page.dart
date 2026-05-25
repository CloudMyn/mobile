import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/session_manager.dart';
import '../../../../core/network/token_storage.dart';
import '../../data/services/auth_service.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'login_page.dart';

/// Halaman pertama yang ditampilkan saat app dibuka.
/// Mengecek token dan validasi sesi sebelum routing ke home atau login.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Tampilkan splash minimal 1 detik agar branding terlihat
    final futures = await Future.wait([
      _resolveDestination(),
      Future.delayed(const Duration(seconds: 1)),
    ]);
    final destination = futures[0] as Widget Function();
    Get.offAll(destination);
  }

  Future<Widget Function()> _resolveDestination() async {
    final tokenStorage = Get.find<TokenStorage>();
    final token = await tokenStorage.getToken();

    if (token == null) return () => const LoginPage();

    try {
      final authService = Get.find<AuthService>();
      final user = await authService.getMe();
      Get.find<SessionManager>().setUser(user);
      return () => const HomePage();
    } on UnauthorizedException {
      await tokenStorage.clearToken();
      return () => const LoginPage();
    } catch (_) {
      // Network error atau error lain — tetap ke home jika token ada
      // (offline mode: tampilkan data yang tersimpan)
      return () => const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Masseddi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 48),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
