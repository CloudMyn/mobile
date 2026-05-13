import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../design_system/tokens/app_colors.dart';

/// [RippleGradientBackground] — Full-screen ripple effect dengan tiga pusat
/// ripple yang tidak sinkron: top-right, bottom-left (sedikit di atas),
/// dan bottom-right (center di luar layar). Lingkaran mengembang kontinu
/// seperti riak air, semakin besar semakin transparan hingga hilang.
///
/// Menggunakan [AppColors] dari theme untuk warna yang konsisten.
class RippleGradientBackground extends StatefulWidget {
  /// Jumlah ripple simultan per pusat (default: 3).
  final int rippleCount;

  /// Durasi satu siklus penuh ripple (default: 6 detik).
  final Duration animationDuration;

  const RippleGradientBackground({
    super.key,
    this.rippleCount = 3,
    this.animationDuration = const Duration(seconds: 6),
  });

  @override
  State<RippleGradientBackground> createState() =>
      _RippleGradientBackgroundState();
}

class _RippleGradientBackgroundState extends State<RippleGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _RipplePainter(
            animationValue: _controller.value,
            primaryColor: colors.primary,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _RipplePainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;

  _RipplePainter({
    required this.animationValue,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final diagonal = math.sqrt(size.width * size.width + size.height * size.height);

    // Tiga set ripple dengan fase offset berbeda agar tidak sinkron
    // Set 1: fase offset 0.0 (default)
    // Set 2: fase offset 0.37 (tidak kelipatan 1/3 agar tidak sinkron)
    // Set 3: fase offset 0.71 (angka prima acak)

    // === PUSAT 1: Top-Right ===
    _drawRippleSet(
      canvas: canvas,
      size: size,
      originX: size.width * 0.85,
      originY: size.height * 0.15,
      maxRadius: diagonal * 0.7,
      maxOpacity: 0.06,
      phaseOffset: 0.0,
    );

    // === PUSAT 2: Bottom-Left (sedikit di atas) ===
    _drawRippleSet(
      canvas: canvas,
      size: size,
      originX: size.width * 0.15,
      originY: size.height * 0.72,
      maxRadius: diagonal * 0.6,
      maxOpacity: 0.04,
      phaseOffset: 0.37,
    );

    // === PUSAT 3: Bottom-Right (center DI LUAR layar) ===
    // Hanya efek pinggir ripple yang terlihat masuk dari pojok kanan bawah
    _drawRippleSet(
      canvas: canvas,
      size: size,
      originX: size.width * 1.4,
      originY: size.height * 1.3,
      maxRadius: diagonal * 1.2,
      maxOpacity: 0.05,
      phaseOffset: 0.71,
    );
  }

  void _drawRippleSet({
    required Canvas canvas,
    required Size size,
    required double originX,
    required double originY,
    required double maxRadius,
    required double maxOpacity,
    required double phaseOffset,
  }) {
    for (int i = 0; i < 3; i++) {
      // Setiap ripple dalam set memiliki jarak tidak seragam
      // agar dalam satu set pun tidak sepenuhnya sinkron
      final stagger = i / 3 + i * 0.07;
      final ripplePhase = (animationValue + stagger + phaseOffset) % 1.0;

      // Ease-out: ripple cepat di awal, melambat natural
      final t = _easeOutCubic(ripplePhase);

      // Radius: membesar secara progresif
      final radius = maxRadius * t;

      // Opacity: maksimum di awal, memudar ke 0 semakin besar radius
      final opacity = maxOpacity * (1.0 - _easeInQuad(t));
      if (opacity <= 0.0005) continue;

      // Gradient radial — center lebih terang, pinggir transparan
      final gradient = RadialGradient(
        center: Alignment(0.0, 0.0),
        radius: 1.0,
        colors: [
          primaryColor.withValues(alpha: opacity),
          primaryColor.withValues(alpha: opacity * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.4, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCircle(
            center: Offset(originX, originY),
            radius: radius,
          ),
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(originX, originY), radius, paint);
    }
  }

  double _easeOutCubic(double t) => 1.0 - math.pow(1.0 - t, 3);
  double _easeInQuad(double t) => t * t;

  @override
  bool shouldRepaint(covariant _RipplePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
