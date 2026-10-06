import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';

class ImageCompressionHelper {
  /// Kompres gambar dari [sourcePath]:
  /// 1. Dijalankan di background [Isolate] agar UI tetap responsif.
  /// 2. Resize agar fit dalam [maxWidth]×[maxHeight] — mempertahankan aspect ratio.
  /// 3. Kompresi JPEG dengan kualitas awal 85%.
  /// 4. Turunkan kualitas secara halus hingga ≤ [maxFileSizeKB], dengan batas aman [minQuality].
  /// 5. Jika masih melebihi batas dan kualitas sudah mencapai [minQuality],
  ///    perkecil resolusi secara bertahap namun tidak boleh di bawah 720px.
  /// 6. Simpan ke [outputPath] (default: sourcePath + '_compressed.jpg').
  ///
  /// Mengembalikan path file hasil kompresi, atau `null` jika gagal.
  static Future<String?> compress({
    required String sourcePath,
    String? outputPath,
    int maxWidth = AppConstants.maxImageDimension,
    int maxHeight = AppConstants.maxImageDimension,
    int maxFileSizeKB = AppConstants.maxUploadFileSizeKB,
    int minQuality = AppConstants.minImageQuality,
  }) async {
    try {
      final file = File(sourcePath);
      if (!await file.exists()) return null;

      final outPath = outputPath ??
          sourcePath.replaceFirst(
            RegExp(r'\.[^./]+$'),
            '_compressed.jpg',
          );

      // Jalankan proses kompresi intensif di background isolate
      final compressedBytes = await Isolate.run<List<int>?>(() async {
        final bytes = await File(sourcePath).readAsBytes();
        final image = img.decodeImage(bytes);
        if (image == null) return null;

        final maxFileSizeBytes = maxFileSizeKB * 1024;
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
            interpolation: img.Interpolation.linear,
          );
        } else {
          workingImage = image;
        }

        // Kualitas awal 85% untuk menjaga kejernihan foto dan teks
        int quality = 85;
        List<int> compressed = img.encodeJpg(workingImage, quality: quality);

        // Tahap 1: Turunkan kualitas bertahap per 5% sampai minQuality (60%)
        while (compressed.length > maxFileSizeBytes && quality > minQuality) {
          quality -= 5;
          if (quality < minQuality) quality = minQuality;
          compressed = img.encodeJpg(workingImage, quality: quality);
        }

        // Tahap 2: Jika masih besar setelah kualitas mencapai minQuality,
        // turunkan dimensi secara bertahap namun tidak boleh lebih kecil dari 720px
        while (compressed.length > maxFileSizeBytes && targetW > 720 && targetH > 720) {
          targetW = (targetW * 0.85).round();
          targetH = (targetH * 0.85).round();
          workingImage = img.copyResize(
            workingImage,
            width: targetW,
            height: targetH,
            interpolation: img.Interpolation.linear,
          );
          compressed = img.encodeJpg(workingImage, quality: quality);
        }

        return compressed;
      });

      if (compressedBytes == null) return null;

      await File(outPath).writeAsBytes(compressedBytes);

      // Hapus file sumber jika berbeda dengan output
      if (outPath != sourcePath && await file.exists()) {
        await file.delete();
      }

      return outPath;
    } catch (_) {
      return null;
    }
  }
}
