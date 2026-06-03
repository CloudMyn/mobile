import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Hasil embedding beserta info kualitas wajah
class FaceEmbeddingResult {
  final List<double> embedding;
  final FaceQualityInfo quality;
  final Uint8List? processedImageBytes; // Added to return the image if needed

  FaceEmbeddingResult({required this.embedding, required this.quality, this.processedImageBytes});
}

/// Info kualitas wajah yang terdeteksi
class FaceQualityInfo {
  final double faceArea;
  final double headEulerAngleY; // Yaw: kiri/kanan
  final double headEulerAngleZ; // Roll: miring
  final double? smilingProbability;
  final double? leftEyeOpenProbability;
  final double? rightEyeOpenProbability;
  final bool isFaceLargeEnough;
  final bool isPoseFrontal;
  final bool isQualityGood;

  FaceQualityInfo({
    required this.faceArea,
    required this.headEulerAngleY,
    required this.headEulerAngleZ,
    required this.smilingProbability,
    required this.leftEyeOpenProbability,
    required this.rightEyeOpenProbability,
    required this.isFaceLargeEnough,
    required this.isPoseFrontal,
    required this.isQualityGood,
  });

  String get rejectionReason {
    if (!isFaceLargeEnough) return 'Wajah terlalu kecil, dekatkan ke kamera';
    if (!isPoseFrontal) return 'Hadapkan wajah lurus ke kamera';
    return '';
  }
}

class VerificationResult {
  final bool isMatch;
  final double euclideanDistance;
  final double cosineSimilarity;

  VerificationResult({
    required this.isMatch,
    required this.euclideanDistance,
    required this.cosineSimilarity,
  });
}

class FaceService {
  // Threshold verifikasi - Euclidean distance untuk L2-normalized vectors
  static const double verificationThreshold = 0.80;
  // Secondary check: minimum cosine similarity
  static const double minCosineSimilarity = 0.65;

  // Quality thresholds
  static const double minFaceAreaRatio = 0.025; // min 2.5% dari total area gambar
  static const double maxHeadAngleY = 25.0; // max yaw 25 derajat
  static const double maxHeadAngleZ = 20.0; // max roll 20 derajat

  static final options = FaceDetectorOptions(
    enableContours: false,
    enableLandmarks: true,
    enableClassification: true,
    performanceMode: FaceDetectorMode.accurate,
  );

  final FaceDetector _faceDetector = FaceDetector(options: options);
  Interpreter? _interpreter;

  // MobileFaceNet configuration
  final int inputSize = 112;
  final int embeddingSize = 192;
  final double imageMean = 128.0;
  final double imageStd = 128.0;

  Future<void> loadModel() async {
    if (_interpreter != null) return;
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/tflite/mobilefacenet.tflite',
      );
      debugPrint(
        'MobileFaceNet loaded, input tensors: ${_interpreter!.getInputTensors().first.shape}',
      );
      debugPrint(
        'MobileFaceNet loaded, output tensors: ${_interpreter!.getOutputTensors().first.shape}',
      );
    } catch (e) {
      debugPrint('Failed to load MobileFaceNet model: $e');
      rethrow;
    }
  }

  /// Crop gambar ke aspect ratio 1:1 (center crop) lalu compress ke ≤ maxBytes.
  /// (Dipertahankan dari versi lama)
  Future<Uint8List?> cropAndCompress(
    Uint8List originalBytes, {
    int maxBytes = 100000,
  }) async {
    final decoded = img.decodeImage(originalBytes);
    if (decoded == null) return null;

    final cropped = _centerCrop(decoded);
    return _compressToMaxBytes(cropped, maxBytes);
  }

  img.Image _centerCrop(img.Image source) {
    final size = source.width < source.height ? source.width : source.height;
    final x = (source.width - size) ~/ 2;
    final y = (source.height - size) ~/ 2;
    return img.copyCrop(source, x: x, y: y, width: size, height: size);
  }

  Uint8List _compressToMaxBytes(img.Image image, int maxBytes) {
    for (var quality = 90; quality >= 10; quality -= 10) {
      final encoded = img.encodeJpg(image, quality: quality);
      if (encoded.length <= maxBytes) return Uint8List.fromList(encoded);
    }
    final resized = img.copyResize(image, width: 256);
    for (var quality = 90; quality >= 10; quality -= 10) {
      final encoded = img.encodeJpg(resized, quality: quality);
      if (encoded.length <= maxBytes) return Uint8List.fromList(encoded);
    }
    return Uint8List.fromList(img.encodeJpg(resized, quality: 10));
  }

  /// Validasi kualitas wajah
  FaceQualityInfo validateFaceQuality(Face face, double imageArea) {
    final faceArea = face.boundingBox.width * face.boundingBox.height;
    final faceAreaRatio = faceArea / imageArea;
    final headAngleY = (face.headEulerAngleY ?? 0.0).abs();
    final headAngleZ = (face.headEulerAngleZ ?? 0.0).abs();

    final isFaceLargeEnough = faceAreaRatio >= minFaceAreaRatio;
    final isPoseFrontal =
        headAngleY <= maxHeadAngleY && headAngleZ <= maxHeadAngleZ;

    return FaceQualityInfo(
      faceArea: faceArea,
      headEulerAngleY: face.headEulerAngleY ?? 0.0,
      headEulerAngleZ: face.headEulerAngleZ ?? 0.0,
      smilingProbability: face.smilingProbability,
      leftEyeOpenProbability: face.leftEyeOpenProbability,
      rightEyeOpenProbability: face.rightEyeOpenProbability,
      isFaceLargeEnough: isFaceLargeEnough,
      isPoseFrontal: isPoseFrontal,
      isQualityGood: isFaceLargeEnough && isPoseFrontal,
    );
  }

  /// Mendapatkan embedding dengan validasi kualitas dari byte array
  Future<FaceEmbeddingResult?> extractEmbeddingFromBytes(Uint8List bytes) async {
    await loadModel();

    // Untuk ML Kit via bytes
    img.Image? ori = img.decodeImage(bytes);
    if (ori == null) return null;
    ori = img.bakeOrientation(ori); // Apply EXIF orientation

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(ori.width.toDouble(), ori.height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888, // Not used much here actually, will fallback to decode
        bytesPerRow: ori.width * 4,
      ),
    );
    
    // Actually for MLKit, if we already have Uint8List JPEG/PNG, it's safer on all platforms
    // to write to a temp file or use the raw path. 
    // Since ML Kit might complain about fromBytes if metadata isn't NV21 on Android.
    // Let's use a temp file to be absolutely safe across platforms.
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp_face_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(bytes);

    final safeInputImage = Platform.isIOS ? await _inputImageForMlKitFile(tempFile) : InputImage.fromFilePath(tempFile.path);
    if (safeInputImage == null) return null;
    
    final faces = await _faceDetector.processImage(safeInputImage);
    await tempFile.delete(); // cleanup

    if (faces.isEmpty) return null;

    // choose biggest face
    Face face = faces.reduce((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final areaB = b.boundingBox.width * b.boundingBox.height;
      return areaA > areaB ? a : b;
    });

    final imageArea = (ori.width * ori.height).toDouble();
    final quality = validateFaceQuality(face, imageArea);

    // ==========================================
    // SIMILARITY TRANSFORM / GEOMETRIC ALIGNMENT
    // ==========================================
    final leftEye = face.landmarks[FaceLandmarkType.leftEye];
    final rightEye = face.landmarks[FaceLandmarkType.rightEye];

    img.Image alignedFace;

    if (leftEye != null && rightEye != null) {
      const double targetLeftEyeX = 38.29;
      const double targetLeftEyeY = 51.69;
      const double targetRightEyeX = 73.53;
      const double targetRightEyeY = 51.50;

      final double srcLeftEyeX = leftEye.position.x.toDouble();
      final double srcLeftEyeY = leftEye.position.y.toDouble();
      final double srcRightEyeX = rightEye.position.x.toDouble();
      final double srcRightEyeY = rightEye.position.y.toDouble();

      final double dxSrc = srcRightEyeX - srcLeftEyeX;
      final double dySrc = srcRightEyeY - srcLeftEyeY;
      final double dxDst = targetRightEyeX - targetLeftEyeX;
      final double dyDst = targetRightEyeY - targetLeftEyeY;

      final double distSrc = math.sqrt(dxSrc * dxSrc + dySrc * dySrc);
      final double distDst = math.sqrt(dxDst * dxDst + dyDst * dyDst);
      final double scale = distDst / distSrc;

      final double angleSrc = math.atan2(dySrc, dxSrc);
      final double angleDst = math.atan2(dyDst, dxDst);
      final double angle = angleSrc - angleDst; 

      final double cosA = math.cos(angle) * scale;
      final double sinA = math.sin(angle) * scale;

      final double tx = targetLeftEyeX - (cosA * srcLeftEyeX + sinA * srcLeftEyeY);
      final double ty = targetLeftEyeY - (-sinA * srcLeftEyeX + cosA * srcLeftEyeY);

      alignedFace = img.Image(width: inputSize, height: inputSize);

      final double det = cosA * cosA + sinA * sinA;
      final double invCosA = cosA / det;
      final double invSinA = -sinA / det;

      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final double srcX = invCosA * (x - tx) + invSinA * (y - ty);
          final double srcY = -invSinA * (x - tx) + invCosA * (y - ty);

          if (srcX >= 0 && srcX < ori!.width - 1 && srcY >= 0 && srcY < ori.height - 1) {
            int x1 = srcX.floor();
            int y1 = srcY.floor();
            int x2 = x1 + 1;
            int y2 = y1 + 1;

            double dx = srcX - x1;
            double dy = srcY - y1;

            img.Pixel p00 = ori.getPixelSafe(x1, y1);
            img.Pixel p10 = ori.getPixelSafe(x2, y1);
            img.Pixel p01 = ori.getPixelSafe(x1, y2);
            img.Pixel p11 = ori.getPixelSafe(x2, y2);

            double r = p00.r * (1 - dx) * (1 - dy) + p10.r * dx * (1 - dy) + p01.r * (1 - dx) * dy + p11.r * dx * dy;
            double g = p00.g * (1 - dx) * (1 - dy) + p10.g * dx * (1 - dy) + p01.g * (1 - dx) * dy + p11.g * dx * dy;
            double b = p00.b * (1 - dx) * (1 - dy) + p10.b * dx * (1 - dy) + p01.b * (1 - dx) * dy + p11.b * dx * dy;

            alignedFace.setPixel(x, y, alignedFace.getColor(r.round(), g.round(), b.round()));
          } else {
            alignedFace.setPixel(x, y, alignedFace.getColor(0, 0, 0));
          }
        }
      }
    } else {
      final rect = face.boundingBox;
      final left = rect.left.clamp(0.0, ori!.width - 1.0).toInt();
      final top = rect.top.clamp(0.0, ori.height - 1.0).toInt();
      final right = rect.right.clamp(0.0, ori.width - 1.0).toInt();
      final bottom = rect.bottom.clamp(0.0, ori.height - 1.0).toInt();
      final w = (right - left).clamp(1, ori.width);
      final h = (bottom - top).clamp(1, ori.height);
      
      final marginX = (w * 0.15).toInt();
      final marginY = (h * 0.15).toInt();
      final cropLeft = (left - marginX).clamp(0, ori.width - 1);
      final cropTop = (top - marginY).clamp(0, ori.height - 1);
      final cropW = (w + marginX * 2).clamp(1, ori.width - cropLeft);
      final cropH = (h + marginY * 2).clamp(1, ori.height - cropTop);

      img.Image cropped = img.copyCrop(ori, x: cropLeft, y: cropTop, width: cropW, height: cropH);
      alignedFace = img.copyResizeCropSquare(cropped, size: inputSize);
    }

    final input = _imageToInputTensor(alignedFace, mean: imageMean, std: imageStd);
    var output = List.generate(1, (_) => List.filled(embeddingSize, 0.0));

    try {
      _interpreter!.run(input, output);
    } catch (e) {
      debugPrint('Error running MobileFaceNet inference: $e');
      rethrow;
    }

    final emb = List<double>.from(output[0]);
    
    // Compress ori image for upload so we don't need to return alignedFace specifically
    // but the cropped/compressed one as before.
    final compressedBytes = await cropAndCompress(bytes);
    
    return FaceEmbeddingResult(
      embedding: l2Normalize(emb), 
      quality: quality,
      processedImageBytes: compressedBytes,
    );
  }

  Future<InputImage?> _inputImageForMlKitFile(File imageFile) async {
    if (Platform.isIOS) {
      final bytes = await imageFile.readAsBytes();
      var decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      decoded = img.bakeOrientation(decoded);
      final bgra = _imageToBgra8888(decoded);
      return InputImage.fromBytes(
        bytes: bgra,
        metadata: InputImageMetadata(
          size: Size(decoded.width.toDouble(), decoded.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: decoded.width * 4,
        ),
      );
    }
    return InputImage.fromFilePath(imageFile.path);
  }

  Uint8List _imageToBgra8888(img.Image im) {
    final w = im.width;
    final h = im.height;
    final out = Uint8List(w * h * 4);
    var o = 0;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final c = im.getPixel(x, y);
        out[o++] = c.b.toInt();
        out[o++] = c.g.toInt();
        out[o++] = c.r.toInt();
        out[o++] = c.a.toInt();
      }
    }
    return out;
  }

  List<List<List<List<double>>>> _imageToInputTensor(
    img.Image image, {
    double mean = 128.0,
    double std = 128.0,
  }) {
    final h = image.height;
    final w = image.width;
    return [
      List.generate(h, (y) {
        return List.generate(w, (x) {
          final pixel = image.getPixel(x, y);
          return [
            (pixel.r - mean) / std,
            (pixel.g - mean) / std,
            (pixel.b - mean) / std,
          ];
        });
      }),
    ];
  }

  double euclideanDistance(List<double> a, List<double> b) {
    double sum = 0;
    for (int i = 0; i < a.length && i < b.length; i++) {
      sum += math.pow((a[i] - b[i]), 2);
    }
    return math.sqrt(sum);
  }

  List<double> l2Normalize(List<double> vec) {
    double sum = 0;
    for (var v in vec) sum += v * v;
    double norm = sum > 0 ? math.sqrt(sum) : 1.0;
    return vec.map((v) => v / norm).toList();
  }

  double cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0;
    for (int i = 0; i < a.length && i < b.length; i++) {
      dot += a[i] * b[i];
    }
    return dot;
  }

  VerificationResult verify(List<double> liveEmbedding, List<double> storedEmbedding) {
    final dist = euclideanDistance(liveEmbedding, storedEmbedding);
    final cosSim = cosineSimilarity(liveEmbedding, storedEmbedding);

    final isMatch = dist < verificationThreshold && cosSim > minCosineSimilarity;

    return VerificationResult(
      isMatch: isMatch,
      euclideanDistance: dist,
      cosineSimilarity: cosSim,
    );
  }

  String embeddingToBase64(List<double> embedding) {
    final floatList = Float32List.fromList(embedding);
    return base64Encode(floatList.buffer.asUint8List());
  }

  List<double> base64ToEmbedding(String base64Str) {
    final bytes = base64Decode(base64Str);
    final floatList = Float32List.view(bytes.buffer);
    return floatList.toList();
  }
}
