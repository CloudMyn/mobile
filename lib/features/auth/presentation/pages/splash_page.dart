import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/session_manager.dart';
import '../../../../core/network/token_storage.dart';
import '../../../../design_system/theme/app_theme.dart';
import '../../data/services/auth_service.dart';
import '../../../home/presentation/pages/home_page.dart';
import 'login_page.dart';

/// Halaman pertama yang ditampilkan saat app dibuka (Startup Splash Screen).
/// Menampilkan Logo Presensi dan teks animasi "Memuat..."
/// Mengecek token dan validasi sesi sebelum routing ke Home atau Login.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _loadingController;

  late Animation<double> _bgAnimation;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _logoSlide;
  late Animation<double> _loadingOpacity;

  @override
  void initState() {
    super.initState();

    // Background and Logo Entrance Controller
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Looping Pulsing Controller for the "Memuat..." text
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _bgAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bgController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _bgController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _logoSlide =
        Tween<Offset>(
          begin: const Offset(0.0, -15.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _bgController,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
          ),
        );

    _loadingOpacity = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );

    _bgController.forward();
    _loadingController.repeat(reverse: true);

    _checkSession();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    // Tampilkan splash utama minimal 1.8 detik agar animasi terlihat stabil
    final futures = await Future.wait([
      _resolveDestination(),
      Future.delayed(const Duration(milliseconds: 1800)),
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
      // Offline mode atau network error: jika token ada, langsung arahkan ke Home
      return () => const HomePage();
    }
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: const Color(0xFFF7FAF6)),
        Positioned(
          top: -30.h,
          left: -30.w,
          child: AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_bgAnimation.value * 0.08),
                child: child,
              );
            },
            child: Container(
              width: 220.w,
              height: 220.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF006D3B).withValues(alpha: 0.04),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -40.h,
          right: -40.w,
          child: AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.08 - (_bgAnimation.value * 0.08),
                child: child,
              );
            },
            child: Container(
              width: 280.w,
              height: 280.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF98F7B5).withValues(alpha: 0.05),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FAF6),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
          child: Stack(
            children: [
              // Background ambient glows
              Positioned.fill(child: _buildBackground()),

              // Center Logo & Animated Text
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Centered Logo Card
                      AnimatedBuilder(
                        animation: _bgController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: _logoSlide.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 18.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF006D3B,
                                ).withValues(alpha: 0.06),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(
                              color: const Color(
                                0xFF006D3B,
                              ).withValues(alpha: 0.05),
                              width: 1.w,
                            ),
                          ),
                          child: Image.asset(
                            'assets/images/logo_presensi.png',
                            height: 64.h,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.domain,
                                  size: 48,
                                  color: Color(0xFF006D3B),
                                ),
                          ),
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Animated "Memuat..." text
                      AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, child) {
                          return Opacity(
                            opacity: _loadingOpacity.value,
                            child: child,
                          );
                        },
                        child: Text(
                          'Memuat...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF006D3B),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
