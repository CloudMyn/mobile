import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/theme/app_theme.dart';
import '../../../home/presentation/pages/home_page.dart';

/// Halaman Splash Screen Pimpinan Daerah (Bupati, Wakil Bupati, Sekda).
/// Ditampilkan setelah user berhasil login dari halaman LoginPage.
class LeaderSplashPage extends StatefulWidget {
  final bool autoClose;
  const LeaderSplashPage({super.key, this.autoClose = true});

  @override
  State<LeaderSplashPage> createState() => _LeaderSplashPageState();
}

class _LeaderSplashPageState extends State<LeaderSplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bgAnimation;

  late Animation<double> _topLogoOpacity;
  late Animation<Offset> _topLogoSlide;

  late Animation<double> _bupatiOpacity;
  late Animation<Offset> _bupatiSlide;

  late Animation<double> _wakilBupatiOpacity;
  late Animation<Offset> _wakilBupatiSlide;

  late Animation<double> _sekdaOpacity;
  late Animation<double> _sekdaScale;

  late Animation<double> _bottomLogoOpacity;
  late Animation<Offset> _bottomLogoSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Background pulse/scale loop
    _bgAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Top Logo: 0.0 to 0.4
    _topLogoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _topLogoSlide =
        Tween<Offset>(
          begin: const Offset(0.0, -30.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
          ),
        );

    // Bupati & Wakil Bupati: 0.2 to 0.6
    _bupatiOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    _bupatiSlide =
        Tween<Offset>(
          begin: const Offset(-40.0, 15.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
          ),
        );

    _wakilBupatiOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    _wakilBupatiSlide =
        Tween<Offset>(
          begin: const Offset(40.0, 15.0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
          ),
        );

    // Sekda: 0.45 to 0.8
    _sekdaOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.8, curve: Curves.easeOut),
      ),
    );
    _sekdaScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // Bottom Logo: 0.7 to 1.0
    _bottomLogoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );
    _bottomLogoSlide =
        Tween<Offset>(begin: const Offset(0.0, 20.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
          ),
        );

    _controller.forward();
    if (widget.autoClose) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    // Navigasi ke HomePage setelah 3.5 detik (menyesuaikan durasi animasi splash)
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        Get.offAll(() => const HomePage());
      }
    });
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(color: const Color(0xFFF7FAF6)),
        Positioned(
          top: -40.h,
          left: -40.w,
          child: AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_bgAnimation.value * 0.1),
                child: child,
              );
            },
            child: Container(
              width: 260.w,
              height: 260.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF006D3B).withValues(alpha: 0.04),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 120.h,
          right: -60.w,
          child: AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.1 - (_bgAnimation.value * 0.1),
                child: child,
              );
            },
            child: Container(
              width: 320.w,
              height: 320.w,
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

  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF006D3B).withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF006D3B).withValues(alpha: 0.05),
          width: 1.w,
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo_presensi.png',
          height: 45.h,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.domain, size: 36, color: Color(0xFF006D3B)),
        ),
      ),
    );
  }

  Widget _buildLeaderCard({
    required String imagePath,
    required String role,
    required String name,
    required double width,
    required double aspectRatio,
    required Animation<double> opacityAnim,
    required Animation<Offset> slideAnim,
    required Animation<double> scaleAnim,
    BoxFit imageFit = BoxFit.cover,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: slideAnim.value,
          child: Opacity(
            opacity: opacityAnim.value,
            child: Transform.scale(scale: scaleAnim.value, child: child),
          ),
        );
      },
      child: SizedBox(
        width: width,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF006D3B).withValues(alpha: 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: const Color(0xFF006D3B).withValues(alpha: 0.12),
                width: 1.2.w,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15.r),
              child: Stack(
                children: [
                  // Photo background container
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFFF0F4F1),
                      child: Image.asset(
                        imagePath,
                        fit: imageFit,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Icon(
                            Icons.person,
                            size: 48.r,
                            color: const Color(
                              0xFF006D3B,
                            ).withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Glassmorphic Info Banner Overlay at the bottom
                  Positioned(
                    bottom: 8.h,
                    left: 8.w,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF004D25).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: const Color(
                            0xFFFFD700,
                          ).withValues(alpha: 0.35),
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            role,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFFD700),
                              letterSpacing: 0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderSection() {
    const cardAspectRatio =
        0.58; // 30-40% taller layout aspect ratio to enlarge the card containers

    return LayoutBuilder(
      builder: (context, constraints) {
        // Total horizontal padding inside Row is 8.w * 2 = 16.w
        // Width of the row is constraints.maxWidth - 16.w
        // Row has 2 children and a spacing of 12.w
        final availableRowWidth = constraints.maxWidth - 16.w;
        final bupatiWidth = (availableRowWidth - 12.w) / 2;
        final sekdaWidth =
            bupatiWidth / 1.3; // Sekda is exactly 30% smaller than Bupati/Wakil

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bupati & Wakil Bupati Row (Wrapped in Expanded to fit screen width dynamically)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                children: [
                  Expanded(
                    child: _buildLeaderCard(
                      imagePath: 'assets/images/bupati.png',
                      role: 'BUPATI BARRU',
                      name: 'Andi Ina Kartika Sari, S.H., M.Si.',
                      width: double.infinity,
                      aspectRatio: cardAspectRatio,
                      opacityAnim: _bupatiOpacity,
                      slideAnim: _bupatiSlide,
                      scaleAnim: const AlwaysStoppedAnimation(1.0),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildLeaderCard(
                      imagePath: 'assets/images/wakil bupati.png',
                      role: 'WAKIL BUPATI BARRU',
                      name: 'Dr. Ir. Abustan A. Bintang, M.Si.',
                      width: double.infinity,
                      aspectRatio: cardAspectRatio,
                      opacityAnim: _wakilBupatiOpacity,
                      slideAnim: _wakilBupatiSlide,
                      scaleAnim: const AlwaysStoppedAnimation(1.0),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Sekda (Centered, dynamically 30% smaller, ratio is identical)
            _buildLeaderCard(
              imagePath: 'assets/images/sekda.png',
              role: 'SEKDA BARRU',
              name: 'Andi Syarifuddin, S.IP., M.Si.',
              width: sekdaWidth,
              aspectRatio: cardAspectRatio,
              opacityAnim: _sekdaOpacity,
              slideAnim: const AlwaysStoppedAnimation(Offset.zero),
              scaleAnim: _sekdaScale,
              imageFit: BoxFit.contain,
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 19.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: const Color.fromARGB(
          255,
          1,
          56,
          30,
        ).withValues(alpha: 0.75), // Dark slate with 75% opacity
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Image.asset(
        'assets/images/logo_singgah.png',
        height: 32.h,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const SizedBox(),
      ),
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
              Positioned.fill(child: _buildBackground()),
              if (!widget.autoClose)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 12.h,
                  right: 16.w,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 4,
                    shadowColor: const Color(0xFF006D3B).withValues(alpha: 0.2),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Color(0xFF006D3B),
                      ),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 38.h),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: _topLogoSlide.value,
                            child: Opacity(
                              opacity: _topLogoOpacity.value,
                              child: child,
                            ),
                          );
                        },
                        child: _buildTopSection(),
                      ),
                      const Spacer(),
                      _buildLeaderSection(),
                      const Spacer(flex: 2),
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: _bottomLogoSlide.value,
                            child: Opacity(
                              opacity: _bottomLogoOpacity.value,
                              child: child,
                            ),
                          );
                        },
                        child: _buildBottomSection(),
                      ),
                      SizedBox(height: 24.h),
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
