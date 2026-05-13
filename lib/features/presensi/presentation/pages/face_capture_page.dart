import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import '../../../../design_system/components/app_button.dart';
import '../../data/services/permission_helper.dart';
import '../../../../design_system/components/feedback/app_dialog.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/services/face_service.dart';

/// Halaman kamera untuk mengambil foto wajah.
/// Mengembalikan [Uint8List] foto yang sudah di-crop 1:1 dan di-compress ≤ 50KB,
/// atau null jika user membatalkan.
class FaceCapturePage extends StatefulWidget {
  const FaceCapturePage({super.key});

  @override
  State<FaceCapturePage> createState() => _FaceCapturePageState();
}

class _FaceCapturePageState extends State<FaceCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isTakingPicture = false;
  bool _isProcessing = false;
  String? _initError;
  Uint8List? _capturedBytes; // bytes setelah crop + compress

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
      _controller = null;
      _isInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    // Dispose controller lama jika masih ada (misal dari lifecycle inactive)
    _controller?.dispose();
    _controller = null;

    setState(() {
      _isInitialized = false;
      _initError = null;
    });

    // Cek permission kamera
    final granted = await PermissionHelper.requestCamera();
    if (!granted) {
      if (mounted) {
        setState(() =>
            _initError = 'Izin kamera diperlukan. Aktifkan di Pengaturan.');
      }
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _initError = 'Kamera tidak tersedia');
        return;
      }

      // Utamakan kamera depan
      final frontCamera = cameras.firstWhereOrNull(
            (c) => c.lensDirection == CameraLensDirection.front,
          ) ??
          cameras.first;

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      if (mounted) setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) setState(() => _initError = 'Gagal membuka kamera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null ||
        !_controller!.value.isInitialized ||
        _isTakingPicture) {
      return;
    }

    setState(() => _isTakingPicture = true);
    try {
      final xfile = await _controller!.takePicture();
      final rawBytes = await xfile.readAsBytes();

      setState(() => _isProcessing = true);
      final faceService = Get.find<FaceService>();
      final processed = await faceService.cropAndCompress(rawBytes);

      if (processed == null) {
        if (mounted) {
          await AppDialog.info(
            title: 'Foto Tidak Valid',
            message: 'Gagal memproses foto. Coba lagi.',
            icon: Icons.broken_image_rounded,
          );
        }
        return;
      }

      if (mounted) {
        setState(() {
          _capturedBytes = processed;
          _isProcessing = false;
          _isTakingPicture = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTakingPicture = false;
          _isProcessing = false;
        });
        await AppDialog.info(
          title: 'Gagal',
          message: 'Gagal mengambil foto: $e',
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  void _retake() => setState(() => _capturedBytes = null);

  void _confirm() => Get.back(result: _capturedBytes);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppTopAppBar(
        title: 'Foto Wajah',
        variant: AppTopAppBarVariant.withBack,
        onBack: () => Get.back(result: null),
      ),
      body: _capturedBytes != null
          ? _buildPreview(colors, typography)
          : _buildCamera(colors, typography),
    );
  }

  // ---------------------------------------------------------------------------
  //  Layar kamera
  // ---------------------------------------------------------------------------
  Widget _buildCamera(AppColors colors, AppTypography typography) {
    if (_initError != null) {
      return _buildError(colors, typography);
    }
    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        // Preview kamera
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _controller!.value.previewSize!.height,
            height: _controller!.value.previewSize!.width,
            child: CameraPreview(_controller!),
          ),
        ),

        // Overlay: vignette + panduan lingkaran
        _CameraOverlay(colors: colors),

        // Teks instruksi
        Positioned(
          top: AppSpacing.s24.h,
          left: AppSpacing.s24.w,
          right: AppSpacing.s24.w,
          child: Text(
            'Posisikan wajah di dalam lingkaran',
            textAlign: TextAlign.center,
            style: typography.bodyMedium.copyWith(
              color: Colors.white,
              shadows: [
                const Shadow(color: Colors.black54, blurRadius: 8),
              ],
            ),
          ),
        ),

        // Tombol capture
        Positioned(
          bottom: AppSpacing.s40.h,
          left: 0,
          right: 0,
          child: Center(
            child: _CaptureButton(
              isLoading: _isTakingPicture || _isProcessing,
              onTap: _takePicture,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  //  Layar preview hasil foto
  // ---------------------------------------------------------------------------
  Widget _buildPreview(AppColors colors, AppTypography typography) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s32.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.r16),
                child: Image.memory(
                  _capturedBytes!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.s24.w,
            0,
            AppSpacing.s24.w,
            AppSpacing.s32.h,
          ),
          child: Column(
            spacing: AppSpacing.s12,
            children: [
              AppButton(
                label: 'Gunakan Foto',
                fullWidth: true,
                icon: Icons.check_rounded,
                onPressed: _confirm,
              ),
              AppButton(
                label: 'Ambil Ulang',
                style: AppButtonStyle.outlined,
                fullWidth: true,
                icon: Icons.refresh_rounded,
                onPressed: _retake,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  //  Error state
  // ---------------------------------------------------------------------------
  Widget _buildError(AppColors colors, AppTypography typography) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s16,
          children: [
            Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 64.sp),
            Text(
              _initError!,
              textAlign: TextAlign.center,
              style: typography.bodyMedium.copyWith(color: Colors.white70),
            ),
            AppButton(
              label: 'Buka Pengaturan',
              onPressed: openAppSettings,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  Camera overlay — vignette + lingkaran panduan
// =============================================================================
class _CameraOverlay extends StatelessWidget {
  final AppColors colors;
  const _CameraOverlay({required this.colors});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _OverlayPainter(primaryColor: colors.primary));
  }
}

class _OverlayPainter extends CustomPainter {
  final Color primaryColor;
  const _OverlayPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.38;

    // Vignette gelap di luar lingkaran
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withValues(alpha: 0.55),
    );

    // Lingkaran panduan
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(_OverlayPainter old) => old.primaryColor != primaryColor;
}

// =============================================================================
//  Tombol capture bulat
// =============================================================================
class _CaptureButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;
  const _CaptureButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.white38, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.black54,
                ),
              )
            : const Icon(Icons.camera_alt_rounded,
                color: Colors.black87, size: 32),
      ),
    );
  }
}
