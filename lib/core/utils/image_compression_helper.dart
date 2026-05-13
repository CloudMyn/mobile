import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';

class ImageCompressionHelper {
  /// Kompres gambar dari [sourcePath]:
  /// 1. Resize agar fit dalam [maxWidth]×[maxHeight] — mempertahankan aspect ratio
  /// 2. Kompresi iteratif hingga ≤ [maxFileSizeKB] kilobyte
  /// 3. Simpan ke [outputPath] (default: sourcePath + '_compressed.jpg')
  ///
  /// Mengembalikan path file hasil kompresi, atau `null` jika gagal.
  static Future<String?> compress({
    required String sourcePath,
    String? outputPath,
    int maxWidth = AppConstants.maxImageDimension,
    int maxHeight = AppConstants.maxImageDimension,
    int maxFileSizeKB = AppConstants.maxUploadFileSizeKB,
  }) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return null;

      final maxFileSizeBytes = maxFileSizeKB * 1024;

      // ── Step 1: Resize — pertahankan aspect ratio ──────────
      final srcW = image.width;
      final srcH = image.height;

      // Hitung skala agar muat dalam maxWidth × maxHeight
      double scale = 1.0;
      if (srcW > maxWidth || srcH > maxHeight) {
        final scaleW = maxWidth / srcW;
        final scaleH = maxHeight / srcH;
        scale = min(scaleW, scaleH);
      }

      int targetW = (srcW * scale).round();
      int targetH = (srcH * scale).round();

      img.Image workingImage;
      if (scale < 1.0) {
        workingImage = img.copyResize(
          image,
          width: targetW,
          height: targetH,
        );
      } else {
        workingImage = image;
      }

      // ── Step 2: Kompresi iteratif ──────────────────────────
      int quality = 85;
      List<int> compressed = img.encodeJpg(workingImage, quality: quality);

      // Turunkan kualitas dulu
      while (compressed.length > maxFileSizeBytes && quality > 10) {
        quality -= 10;
        compressed = img.encodeJpg(workingImage, quality: quality);
      }

      // Jika masih besar, turunkan dimensi secara bertahap
      while (compressed.length > maxFileSizeBytes && targetW > 200 && targetH > 200) {
        // Reset quality dan turunkan dimensi 20%
        quality = 85;
        targetW = (targetW * 0.8).round();
        targetH = (targetH * 0.8).round();
        workingImage = img.copyResize(
          workingImage,
          width: targetW,
          height: targetH,
        );
        compressed = img.encodeJpg(workingImage, quality: quality);

        while (compressed.length > maxFileSizeBytes && quality > 10) {
          quality -= 10;
          compressed = img.encodeJpg(workingImage, quality: quality);
        }
      }

      // ── Step 3: Simpan file ────────────────────────────────
      final outPath = outputPath ??
          sourcePath.replaceFirst(
            RegExp(r'\.[^./]+$'),
            '_compressed.jpg',
          );

      await File(outPath).writeAsBytes(compressed);

      // Hapus file sumber jika berbeda dengan output
      if (outPath != sourcePath) {
        await file.delete();
      }

      return outPath;
    } catch (_) {
      return null;
    }
  }
}
