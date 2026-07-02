import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Menampilkan gambar secara full-screen dengan dukungan pinch-to-zoom.
/// Mendukung gambar dari URL network maupun path file lokal.
///
/// Penggunaan:
/// ```dart
/// AppImageViewer.show(context, imageUrl: 'https://...');
/// AppImageViewer.show(context, imageUrl: '/local/path/image.jpg');
/// ```
class AppImageViewer extends StatefulWidget {
  final String imageUrl;
  final String? heroTag;

  const AppImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  /// Buka full-screen image viewer dari mana saja.
  static void show(
    BuildContext context, {
    required String imageUrl,
    String? heroTag,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        barrierDismissible: true,
        pageBuilder: (ctx, anim, secAnim) => AppImageViewer(
          imageUrl: imageUrl,
          heroTag: heroTag,
        ),
        transitionsBuilder: (ctx, animation, secAnim, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  State<AppImageViewer> createState() => _AppImageViewerState();
}

class _AppImageViewerState extends State<AppImageViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformCtrl = TransformationController();
  late AnimationController _animCtrl;
  Animation<Matrix4>? _resetAnimation;

  bool get _isNetwork => widget.imageUrl.startsWith('http');

  @override
  void initState() {
    super.initState();
    // Sembunyikan status bar saat viewer terbuka
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_resetAnimation != null) {
          _transformCtrl.value = _resetAnimation!.value;
        }
      });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _transformCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _resetAnimation = Matrix4Tween(
      begin: _transformCtrl.value,
      end: Matrix4.identity(),
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final Widget imageWidget = _isNetwork
        ? Image.network(
            widget.imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (ctx, child, progress) => progress == null
                ? child
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
            errorBuilder: (ctx, err, stack) => const _ImageErrorWidget(),
          )
        : Image.file(
            File(widget.imageUrl),
            fit: BoxFit.contain,
            errorBuilder: (ctx, err, stack) => const _ImageErrorWidget(),
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ── Background hitam ──────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(color: Colors.black),
          ),

          // ── Image + zoom ──────────────────────────────────────
          Center(
            child: GestureDetector(
              onDoubleTap: () {
                // Double-tap: zoom in ke 2.5x, atau reset jika sudah zoom
                if (_transformCtrl.value != Matrix4.identity()) {
                  _resetZoom();
                } else {
                  _transformCtrl.value = Matrix4.identity()
                    ..scaleByDouble(2.5, 2.5, 1.0, 1.0)
                    ..translateByDouble(-100.0, -200.0, 0.0, 0.0);
                }
              },
              child: InteractiveViewer(
                transformationController: _transformCtrl,
                panEnabled: true,
                scaleEnabled: true,
                minScale: 0.5,
                maxScale: 6.0,
                clipBehavior: Clip.none,
                onInteractionEnd: (details) {
                  // Jika scale < 1, reset kembali ke normal
                  final scale = _transformCtrl.value.getMaxScaleOnAxis();
                  if (scale < 1.0) _resetZoom();
                },
                child: widget.heroTag != null
                    ? Hero(tag: widget.heroTag!, child: imageWidget)
                    : imageWidget,
              ),
            ),
          ),

          // ── Tombol tutup (kiri atas) ──────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.close_rounded,
                    onTap: () => Navigator.of(context).pop(),
                    tooltip: 'Tutup',
                  ),
                  _CircleButton(
                    icon: Icons.zoom_out_map_rounded,
                    onTap: _resetZoom,
                    tooltip: 'Reset zoom',
                  ),
                ],
              ),
            ),
          ),

          // ── Hint teks di bawah ────────────────────────────────
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Center(
              child: const Text(
                'Cubit untuk zoom • Ketuk dua kali untuk zoom in/out',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.5),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _ImageErrorWidget extends StatelessWidget {
  const _ImageErrorWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.broken_image_outlined, color: Colors.white38, size: 60),
            SizedBox(height: 12),
            Text(
              'Gambar tidak dapat dimuat',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
