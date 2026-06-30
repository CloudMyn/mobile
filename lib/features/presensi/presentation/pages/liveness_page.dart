import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart' show openAppSettings;
import 'package:image/image.dart' as img;
import '../../../../design_system/components/app_button.dart';
import '../../data/services/permission_helper.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';

/// Urutan langkah liveness
enum _LivenessStep { blink, smile, done }

/// Halaman liveness detection berbasis ML Kit.
/// Mengembalikan [Uint8List] jika semua langkah berhasil (foto ditangkap otomatis), [null] jika dibatalkan.
/// Setelah 3 kegagalan berturut-turut, mengembalikan [false].
class LivenessPage extends StatefulWidget {
  const LivenessPage({super.key});

  @override
  State<LivenessPage> createState() => _LivenessPageState();
}

class _LivenessPageState extends State<LivenessPage>
    with WidgetsBindingObserver {
  CameraController? _camCtrl;
  FaceDetector? _detector;
  bool _isInitialized = false;
  bool _isDetecting = false;
  String? _initError;
  CameraImage? _lastFrame;

  _LivenessStep _step = _LivenessStep.blink;
  int _failCount = 0;
  static const int _maxFails = 3;

  // Liveness step tracking states
  bool _blinkSuccess = false;
  bool _smileSuccess = false;
  bool _isStepAnimating = false;
  bool _isPermissionChecking = false;

  // Cooldown agar state tidak berubah terlalu cepat
  DateTime _lastStepChange = DateTime.now();
  static const _stepCooldown = Duration(milliseconds: 1200);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _safeStopImageStream();
    _camCtrl?.dispose();
    _camCtrl = null;
    _detector?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _safeStopImageStream();
      _camCtrl?.dispose();
      _camCtrl = null;
      _isInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      _initAll();
    }
  }

  // =========================================================================
  //  Init
  // =========================================================================

  Future<void> _safeStopImageStream() async {
    final controller = _camCtrl;
    if (controller != null &&
        controller.value.isInitialized &&
        controller.value.isStreamingImages) {
      try {
        await controller.stopImageStream();
      } catch (e) {
        debugPrint('Error stopping image stream: $e');
      }
    }
  }

  Future<void> _initAll() async {
    if (_isPermissionChecking) return;
    _isPermissionChecking = true;

    // Dispose controller lama jika masih ada (misal dari lifecycle inactive)
    await _safeStopImageStream();
    _camCtrl?.dispose();
    _camCtrl = null;

    if (mounted) {
      setState(() {
        _isInitialized = false;
        _initError = null;
      });
    }

    final granted = await PermissionHelper.requestCamera();
    _isPermissionChecking = false;

    if (!granted) {
      if (mounted) {
        Get.snackbar(
          'Izin Kamera Diperlukan',
          'Akses kamera diperlukan untuk verifikasi wajah.',
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) _initAll();
        });
      }
      return;
    }

    _detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        minFaceSize: 0.2,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _initError = 'Kamera tidak tersedia');
        return;
      }
      final front = cameras.firstWhereOrNull(
            (c) => c.lensDirection == CameraLensDirection.front,
          ) ??
          cameras.first;

      _camCtrl = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
      );
      await _camCtrl!.initialize();

      if (mounted && _camCtrl != null && _camCtrl!.value.isInitialized) {
        setState(() => _isInitialized = true);
        _startStream();
      }
    } catch (e) {
      if (mounted) setState(() => _initError = 'Gagal membuka kamera: $e');
    }
  }

  // =========================================================================
  //  Image Stream
  // =========================================================================

  void _startStream() {
    if (_camCtrl == null || !_camCtrl!.value.isInitialized) return;
    
    _camCtrl?.startImageStream((CameraImage image) async {
      if (_isDetecting || !mounted) return;
      _isDetecting = true;
      try {
        await _processFrame(image);
      } finally {
        _isDetecting = false;
      }
    });
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_detector == null || _step == _LivenessStep.done) return;
    _lastFrame = image;

    final inputImage = _toInputImage(image);
    if (inputImage == null) return;

    final faces = await _detector!.processImage(inputImage);
    if (faces.isEmpty || !mounted) {
      // Jika wajah tidak terdeteksi dan tidak sedang animasi, reset progres kembali ke langkah awal (blink)
      if (!_isStepAnimating && _step != _LivenessStep.blink && _step != _LivenessStep.done) {
        setState(() {
          _blinkSuccess = false;
          _smileSuccess = false;
          _step = _LivenessStep.blink;
          _lastStepChange = DateTime.now();
        });
      }
      return;
    }

    final face = faces.first;

    final now = DateTime.now();
    if (now.difference(_lastStepChange) < _stepCooldown) return;
    if (_isStepAnimating) return;

    switch (_step) {
      case _LivenessStep.blink:
        final leftEye = face.leftEyeOpenProbability ?? 1.0;
        final rightEye = face.rightEyeOpenProbability ?? 1.0;
        if (leftEye < 0.2 && rightEye < 0.2) {
          _triggerStepSuccess(_LivenessStep.blink);
        }
        break;
      case _LivenessStep.smile:
        final smile = face.smilingProbability ?? 0.0;
        if (smile > 0.7) {
          _triggerStepSuccess(_LivenessStep.smile);
        }
        break;
      case _LivenessStep.done:
        break;
    }
  }

  void _triggerStepSuccess(_LivenessStep completedStep) async {
    if (completedStep == _LivenessStep.blink) {
      setState(() {
        _blinkSuccess = true;
        _isStepAnimating = true;
      });
      // Tampilkan animasi sukses untuk blink selama 1.5 detik
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _step = _LivenessStep.smile;
          _isStepAnimating = false;
          _lastStepChange = DateTime.now();
        });
      }
    } else if (completedStep == _LivenessStep.smile) {
      setState(() {
        _smileSuccess = true;
        _isStepAnimating = true;
      });
      // Tampilkan animasi sukses untuk smile selama 1.5 detik
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        setState(() {
          _step = _LivenessStep.done;
          _isStepAnimating = false;
          _lastStepChange = DateTime.now();
        });
        await _onLivenessPassed();
      }
    }
  }

  InputImage? _toInputImage(CameraImage image) {
    if (_camCtrl == null) return null;
    final camera = _camCtrl!.description;
    final rotation = InputImageRotationValue.fromRawValue(
          camera.sensorOrientation,
        ) ??
        InputImageRotation.rotation0deg;

    if (image.format.group != ImageFormatGroup.nv21 || image.planes.isEmpty) {
      return null;
    }

    return InputImage.fromBytes(
      bytes: image.planes.first.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  Uint8List _convertNv21ToJpg(CameraImage image) {
    final width = image.width;
    final height = image.height;
    
    final yPlane = image.planes[0];
    final vuPlane = image.planes[1];
    
    final yBytes = yPlane.bytes;
    final vuBytes = vuPlane.bytes;
    
    final yRowStride = yPlane.bytesPerRow;
    final vuRowStride = vuPlane.bytesPerRow;
    final vuPixelStride = vuPlane.bytesPerPixel ?? 2;
    
    final rgbImage = img.Image(width: width, height: height);
    
    for (int y = 0; y < height; y++) {
      final int yRowOffset = y * yRowStride;
      final int uvRowOffset = (y >> 1) * vuRowStride;
      
      for (int x = 0; x < width; x++) {
        final int yIndex = yRowOffset + x;
        if (yIndex < yBytes.length) {
          final int yVal = yBytes[yIndex] & 0xFF;
          final int uvIndex = uvRowOffset + (x >> 1) * vuPixelStride;
          
          if (uvIndex < vuBytes.length && uvIndex + 1 < vuBytes.length) {
            final int vVal = vuBytes[uvIndex] & 0xFF;
            final int uVal = vuBytes[uvIndex + 1] & 0xFF;
            
            final int c = yVal;
            final int d = uVal - 128;
            final int e = vVal - 128;
            
            final int r = (c + 1.402 * e).round().clamp(0, 255);
            final int g = (c - 0.344136 * d - 0.714136 * e).round().clamp(0, 255);
            final int b = (c + 1.772 * d).round().clamp(0, 255);
            
            rgbImage.setPixel(x, y, rgbImage.getColor(r, g, b));
          } else {
            rgbImage.setPixel(x, y, rgbImage.getColor(yVal, yVal, yVal));
          }
        }
      }
    }
    
    img.Image orientedImage = rgbImage;
    if (_camCtrl != null) {
      final sensorOrientation = _camCtrl!.description.sensorOrientation;
      if (sensorOrientation == 90) {
        orientedImage = img.copyRotate(rgbImage, angle: 90);
      } else if (sensorOrientation == 180) {
        orientedImage = img.copyRotate(rgbImage, angle: 180);
      } else if (sensorOrientation == 270) {
        orientedImage = img.copyRotate(rgbImage, angle: 270);
      }
      
      if (_camCtrl!.description.lensDirection == CameraLensDirection.front) {
        orientedImage = img.copyFlip(orientedImage, direction: img.FlipDirection.horizontal);
      }
    }
    
    return Uint8List.fromList(img.encodeJpg(orientedImage));
  }

  Future<void> _onLivenessPassed() async {
    Uint8List? capturedBytes;
    if (_lastFrame != null) {
      try {
        capturedBytes = _convertNv21ToJpg(_lastFrame!);
      } catch (e) {
        debugPrint('Error converting nv21 frame to jpg: $e');
      }
    }

    // Fallback to takePicture if conversion is null
    if (capturedBytes == null) {
      try {
        await _safeStopImageStream();
        await Future.delayed(const Duration(milliseconds: 200));
        if (_camCtrl != null && _camCtrl!.value.isInitialized) {
          final xFile = await _camCtrl!.takePicture();
          capturedBytes = await xFile.readAsBytes();
        }
      } catch (e) {
        debugPrint('Error taking picture after liveness: $e');
      }
    } else {
      await _safeStopImageStream();
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) Get.back(result: capturedBytes);
  }

  // =========================================================================
  //  Kegagalan
  // =========================================================================

  void _recordFail() {
    _failCount++;
    if (_failCount >= _maxFails) {
      Get.back(result: null); // Return null instead of false to prevent TypeError
    } else {
      setState(() {
        _step = _LivenessStep.blink;
        _blinkSuccess = false;
        _smileSuccess = false;
        _isStepAnimating = false;
      });
      _lastStepChange = DateTime.now();
    }
  }

  // =========================================================================
  //  Build
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppTopAppBar(
        title: 'Verifikasi Wajah',
        variant: AppTopAppBarVariant.withBack,
        onBack: () => Get.back(result: null),
      ),
      body: _initError != null
          ? _buildError(colors, typography)
          : !_isInitialized
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
              : _buildLiveness(colors, typography),
    );
  }

  Widget _buildLiveness(AppColors colors, AppTypography typography) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Kamera preview
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _camCtrl!.value.previewSize!.height,
            height: _camCtrl!.value.previewSize!.width,
            child: CameraPreview(_camCtrl!),
          ),
        ),

        // HUD overlay di tengah layar
        _LivenessHudOverlay(
          step: _step,
          blinkSuccess: _blinkSuccess,
          smileSuccess: _smileSuccess,
          isStepAnimating: _isStepAnimating,
        ),

        // Progress dan Stepper di bawah
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildInstructions(colors, typography),
        ),
      ],
    );
  }

  Widget _buildInstructions(AppColors colors, AppTypography typography) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s24.w,
        AppSpacing.s20.h,
        AppSpacing.s24.w,
        AppSpacing.s40.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step indicators
          _StepIndicatorRow(
            currentStep: _step,
            blinkSuccess: _blinkSuccess,
            smileSuccess: _smileSuccess,
            colors: colors,
          ),
          SizedBox(height: AppSpacing.s16.h),

          // Percobaan info
          Text(
            'Percobaan: ${_failCount + 1} / $_maxFails',
            style: typography.bodySmall.copyWith(color: Colors.white54),
          ),

          // Tombol gagal manual (untuk testing / jika deteksi tidak bekerja)
          if (_failCount < _maxFails - 1) ...[
            SizedBox(height: AppSpacing.s12.h),
            AppButton(
              label: 'Liveness Gagal',
              style: AppButtonStyle.ghost,
              onPressed: _recordFail,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError(AppColors colors, AppTypography typography) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: AppSpacing.s16,
            children: [
              Icon(Icons.face_retouching_off_rounded,
                  color: Colors.white54, size: 64.sp),
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
      ),
    );
  }
}

// =============================================================================
//  HUD Style Central Overlay
// =============================================================================
class _LivenessHudOverlay extends StatefulWidget {
  final _LivenessStep step;
  final bool blinkSuccess;
  final bool smileSuccess;
  final bool isStepAnimating;

  const _LivenessHudOverlay({
    required this.step,
    required this.blinkSuccess,
    required this.smileSuccess,
    required this.isStepAnimating,
  });

  @override
  State<_LivenessHudOverlay> createState() => _LivenessHudOverlayState();
}

class _LivenessHudOverlayState extends State<_LivenessHudOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _successCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _successScale;
  late Animation<double> _successRotate;
  late Animation<double> _successFade;

  @override
  void initState() {
    super.initState();
    // Animasi denyut (pulse) untuk teks instruksi HUD
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    // Animasi checklist sukses (scale, rotate, fade)
    _successCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _successScale = CurvedAnimation(
      parent: _successCtrl,
      curve: Curves.elasticOut,
    );

    _successRotate = Tween<double>(begin: -0.15, end: 0.0).animate(
      CurvedAnimation(parent: _successCtrl, curve: Curves.easeOutBack),
    );

    _successFade = CurvedAnimation(
      parent: _successCtrl,
      curve: Curves.easeIn,
    );
  }

  @override
  void didUpdateWidget(covariant _LivenessHudOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    final justFinishedBlink = widget.blinkSuccess && !oldWidget.blinkSuccess;
    final justFinishedSmile = widget.smileSuccess && !oldWidget.smileSuccess;
    
    if (justFinishedBlink || justFinishedSmile) {
      _successCtrl.forward(from: 0.0);
    } else if (!widget.blinkSuccess && !widget.smileSuccess) {
      _successCtrl.reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String text = '';
    IconData? icon;
    bool isStepSuccess = false;

    if (widget.blinkSuccess && widget.step == _LivenessStep.blink) {
      text = 'KEDIP BERHASIL!';
      icon = Icons.check_circle_rounded;
      isStepSuccess = true;
    } else if (widget.smileSuccess && widget.step == _LivenessStep.smile) {
      text = 'SENYUM BERHASIL!';
      icon = Icons.check_circle_rounded;
      isStepSuccess = true;
    } else {
      switch (widget.step) {
        case _LivenessStep.blink:
          text = 'KEDIPKAN KEDUA MATA';
          icon = Icons.remove_red_eye_rounded;
          break;
        case _LivenessStep.smile:
          text = 'TERSENYUMLAH';
          icon = Icons.sentiment_satisfied_rounded;
          break;
        case _LivenessStep.done:
          text = 'SELESAI!';
          icon = Icons.verified_rounded;
          isStepSuccess = true;
          break;
      }
    }

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Graphic HUD Lingkaran Tengah
          Stack(
            alignment: Alignment.center,
            children: [
              // Ring HUD Luar
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 150.w,
                height: 150.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isStepSuccess 
                      ? Colors.green.withValues(alpha: 0.1) 
                      : Colors.blue.withValues(alpha: 0.05),
                  border: Border.all(
                    color: isStepSuccess ? Colors.greenAccent : Colors.blueAccent.withValues(alpha: 0.6),
                    width: 3.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isStepSuccess 
                          ? Colors.greenAccent.withValues(alpha: 0.4) 
                          : Colors.blueAccent.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),

              // Garis denyut aktif (pulsing)
              if (!isStepSuccess)
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) {
                    return Container(
                      width: 120.w,
                      height: 120.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.blueAccent.withValues(alpha: 0.3 * _pulseAnim.value),
                          width: 2.w,
                        ),
                      ),
                    );
                  },
                ),

              // Icon Sukses atau Icon Langkah Aktif
              if (isStepSuccess)
                FadeTransition(
                  opacity: _successFade,
                  child: ScaleTransition(
                    scale: _successScale,
                    child: RotationTransition(
                      turns: _successRotate,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.greenAccent,
                        size: 80.w,
                      ),
                    ),
                  ),
                )
              else
                Icon(
                  icon,
                  color: Colors.white.withValues(alpha: 0.85),
                  size: 60.w,
                ),
            ],
          ),
          
          SizedBox(height: 36.h),

          // Teks HUD Utama yang Berkedip
          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (context, child) {
              return Opacity(
                opacity: isStepSuccess ? 1.0 : _pulseAnim.value,
                child: Transform.scale(
                  scale: isStepSuccess ? 1.0 : 0.96 + 0.04 * _pulseAnim.value,
                  child: child,
                ),
              );
            },
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isStepSuccess ? Colors.greenAccent : Colors.white,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    color: isStepSuccess 
                        ? Colors.greenAccent.withValues(alpha: 0.5) 
                        : Colors.black54,
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  Step indicator row (dua lingkaran terhubung)
// =============================================================================
class _StepIndicatorRow extends StatelessWidget {
  final _LivenessStep currentStep;
  final bool blinkSuccess;
  final bool smileSuccess;
  final AppColors colors;
  
  const _StepIndicatorRow({
    required this.currentStep,
    required this.blinkSuccess,
    required this.smileSuccess,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      (_LivenessStep.blink, Icons.remove_red_eye_rounded, 'Kedip', blinkSuccess),
      (_LivenessStep.smile, Icons.sentiment_satisfied_rounded, 'Senyum', smileSuccess),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          if (i > 0)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 50.w,
              height: 3.h,
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: currentStep == _LivenessStep.smile || currentStep == _LivenessStep.done
                    ? colors.success
                    : Colors.white24,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          _StepDot(
            icon: steps[i].$2,
            label: steps[i].$3,
            isDone: steps[i].$4,
            isActive: currentStep == steps[i].$1,
            colors: colors,
          ),
        ]
      ],
    );
  }
}

class _StepDot extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isDone;
  final bool isActive;
  final AppColors colors;

  const _StepDot({
    required this.icon,
    required this.label,
    required this.isDone,
    required this.isActive,
    required this.colors,
  });

  @override
  State<_StepDot> createState() => _StepDotState();
}

class _StepDotState extends State<_StepDot> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.isActive) {
      _glowController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _StepDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _glowController.repeat(reverse: true);
    } else if (!widget.isActive) {
      _glowController.stop();
      _glowController.reset();
    }
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isDone
        ? widget.colors.success
        : widget.isActive
            ? widget.colors.primary
            : Colors.white30;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            final glowValue = widget.isActive ? _glowController.value : 0.0;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: widget.isActive ? 46.w : 40.w,
              height: widget.isActive ? 46.w : 40.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: widget.isActive ? 0.25 : 0.15),
                border: Border.all(
                  color: color, 
                  width: widget.isActive ? 3 : 2
                ),
                boxShadow: widget.isActive 
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4 * glowValue),
                          blurRadius: 8 + 4 * glowValue,
                          spreadRadius: 1 + glowValue,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  widget.isDone ? Icons.check_rounded : widget.icon,
                  color: color,
                  size: (widget.isActive ? 22 : 20).sp,
                ),
              ),
            );
          },
        ),
        SizedBox(height: AppSpacing.s8.h),
        Text(
          widget.label,
          style: TextStyle(
            color: color,
            fontSize: 11.sp,
            fontWeight: widget.isActive ? FontWeight.bold : widget.normalOrBold(),
          ),
        ),
      ],
    );
  }
}

extension _FontWeightHelper on _StepDot {
  FontWeight normalOrBold() => isActive ? FontWeight.bold : FontWeight.normal;
}
