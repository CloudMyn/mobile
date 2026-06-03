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
enum _LivenessStep { align, blink, smile, done }

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
  Size? _screenSize;
  CameraImage? _lastFrame;

  _LivenessStep _step = _LivenessStep.align;
  int _failCount = 0;
  static const int _maxFails = 3;

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
    _camCtrl?.stopImageStream();
    _camCtrl?.dispose();
    _camCtrl = null;
    _detector?.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _camCtrl?.stopImageStream();
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

  Future<void> _initAll() async {
    // Dispose controller lama jika masih ada (misal dari lifecycle inactive)
    _camCtrl?.stopImageStream();
    _camCtrl?.dispose();
    _camCtrl = null;

    setState(() {
      _isInitialized = false;
      _initError = null;
    });

    final granted = await PermissionHelper.requestCamera();
    if (!granted) {
      if (mounted) {
        setState(() => _initError = 'Izin kamera diperlukan. Aktifkan di Pengaturan.');
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
      // Jika wajah tidak terdeteksi, reset progres kembali ke langkah awal (align)
      if (_step != _LivenessStep.align && _step != _LivenessStep.done) {
        _advanceTo(_LivenessStep.align);
      }
      return;
    }

    final face = faces.first;

    // Pastikan wajah berada di dalam area lingkaran panduan
    final isInside = _isFaceInCircle(face, image);
    if (!isInside) {
      // Jika wajah keluar dari lingkaran, reset progres kembali ke langkah awal (align)
      if (_step != _LivenessStep.align && _step != _LivenessStep.done) {
        _advanceTo(_LivenessStep.align);
      }
      return;
    }

    final now = DateTime.now();
    if (now.difference(_lastStepChange) < _stepCooldown) return;

    switch (_step) {
      case _LivenessStep.align:
        // Wajah terdeteksi di dalam circle → lanjut ke blink
        _advanceTo(_LivenessStep.blink);
      case _LivenessStep.blink:
        final leftEye = face.leftEyeOpenProbability ?? 1.0;
        final rightEye = face.rightEyeOpenProbability ?? 1.0;
        if (leftEye < 0.2 && rightEye < 0.2) {
          _advanceTo(_LivenessStep.smile);
        }
      case _LivenessStep.smile:
        final smile = face.smilingProbability ?? 0.0;
        if (smile > 0.7) {
          _advanceTo(_LivenessStep.done);
          await _onLivenessPassed();
        }
      case _LivenessStep.done:
        break;
    }
  }

  bool _isFaceInCircle(Face face, CameraImage image) {
    if (_screenSize == null || _camCtrl == null) return false;

    final camera = _camCtrl!.description;
    final rotation = InputImageRotationValue.fromRawValue(
          camera.sensorOrientation,
        ) ??
        InputImageRotation.rotation0deg;

    final isRotated = rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg;

    final double imageWidth = (isRotated ? image.height : image.width).toDouble();
    final double imageHeight = (isRotated ? image.width : image.height).toDouble();

    final double scaleX = _screenSize!.width / imageWidth;
    final double scaleY = _screenSize!.height / imageHeight;
    final double scale = scaleX > scaleY ? scaleX : scaleY;

    final double dx = (_screenSize!.width - imageWidth * scale) / 2;
    final double dy = (_screenSize!.height - imageHeight * scale) / 2;

    final double faceScreenX = face.boundingBox.center.dx * scale + dx;
    final double faceScreenY = face.boundingBox.center.dy * scale + dy;
    final double faceScreenWidth = face.boundingBox.width * scale;

    final faceCenter = Offset(faceScreenX, faceScreenY);
    final circleCenter = Offset(_screenSize!.width / 2, _screenSize!.height * 0.42);
    final circleRadius = _screenSize!.width * 0.4;

    final dist = (faceCenter - circleCenter).distance;

    // Deteksi valid jika pusat wajah dekat dengan pusat lingkaran
    // dan ukuran wajah proporsional terhadap ukuran lingkaran
    final isCentered = dist < circleRadius * 0.4;
    final isRightSize = faceScreenWidth >= circleRadius * 0.8 &&
        faceScreenWidth <= circleRadius * 1.8;

    return isCentered && isRightSize;
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

  void _advanceTo(_LivenessStep next) {
    _lastStepChange = DateTime.now();
    if (mounted) setState(() => _step = next);
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
        await _camCtrl?.stopImageStream();
        await Future.delayed(const Duration(milliseconds: 200));
        if (_camCtrl != null && _camCtrl!.value.isInitialized) {
          final xFile = await _camCtrl!.takePicture();
          capturedBytes = await xFile.readAsBytes();
        }
      } catch (e) {
        debugPrint('Error taking picture after liveness: $e');
      }
    } else {
      try {
        await _camCtrl?.stopImageStream();
      } catch (e) {
        debugPrint('Error stopping image stream: $e');
      }
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
      setState(() => _step = _LivenessStep.align);
      _lastStepChange = DateTime.now();
    }
  }

  // =========================================================================
  //  Build
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
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

        // Overlay
        _LivenessOverlay(step: _step, colors: colors),

        // Instruksi + progress di bawah
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
          _StepIndicatorRow(currentStep: _step, colors: colors),
          SizedBox(height: AppSpacing.s16.h),

          // Instruksi teks
          Text(
            _stepInstruction(_step),
            textAlign: TextAlign.center,
            style: typography.titleMedium.copyWith(
              color: Colors.white,
              shadows: [const Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
          SizedBox(height: AppSpacing.s8.h),
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

  String _stepInstruction(_LivenessStep s) => switch (s) {
        _LivenessStep.align => 'Arahkan wajah ke kamera',
        _LivenessStep.blink => 'Kedipkan kedua mata Anda',
        _LivenessStep.smile => 'Tersenyum ke kamera',
        _LivenessStep.done => 'Verifikasi berhasil!',
      };
}

// =============================================================================
//  Liveness overlay — lingkaran + status icon per langkah
// =============================================================================
class _LivenessOverlay extends StatelessWidget {
  final _LivenessStep step;
  final AppColors colors;
  const _LivenessOverlay({required this.step, required this.colors});

  @override
  Widget build(BuildContext context) {
    final ringColor = step == _LivenessStep.done ? colors.success : colors.primary;
    return CustomPaint(
      painter: _LivenessOverlayPainter(ringColor: ringColor),
    );
  }
}

class _LivenessOverlayPainter extends CustomPainter {
  final Color ringColor;
  const _LivenessOverlayPainter({required this.ringColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);
    final radius = size.width * 0.4;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(Rect.fromCircle(center: center, radius: radius))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.5));

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = ringColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_LivenessOverlayPainter old) =>
      old.ringColor != ringColor;
}

// =============================================================================
//  Step indicator row (tiga lingkaran kecil)
// =============================================================================
class _StepIndicatorRow extends StatelessWidget {
  final _LivenessStep currentStep;
  final AppColors colors;
  const _StepIndicatorRow(
      {required this.currentStep, required this.colors});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (_LivenessStep.align, Icons.face_rounded, 'Posisi'),
      (_LivenessStep.blink, Icons.remove_red_eye_rounded, 'Kedip'),
      (_LivenessStep.smile, Icons.sentiment_satisfied_rounded, 'Senyum'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: AppSpacing.s16,
      children: steps.map((entry) {
        final (step, icon, label) = entry;
        final stepIndex = _LivenessStep.values.indexOf(step);
        final currentIndex = _LivenessStep.values.indexOf(currentStep);
        final isDone = currentIndex > stepIndex;
        final isActive = currentIndex == stepIndex;

        return _StepDot(
          icon: icon,
          label: label,
          isDone: isDone,
          isActive: isActive,
          colors: colors,
        );
      }).toList(),
    );
  }
}

class _StepDot extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = isDone
        ? colors.success
        : isActive
            ? colors.primary
            : Colors.white30;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.s4,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(
            isDone ? Icons.check_rounded : icon,
            color: color,
            size: 20.sp,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
