import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Utility untuk pengolahan gambar wajah sebelum dikirim ke API.
/// Face upload tidak dilakukan terpisah — foto dikirim langsung sebagai
/// multipart field "photo" di dalam request presensi.
class FaceService {
  FaceService();

  /// Crop gambar ke aspect ratio 1:1 (center crop) lalu compress ke ≤ maxBytes.
  /// Return null jika gambar tidak valid.
  Future<Uint8List?> cropAndCompress(
    Uint8List originalBytes, {
    int maxBytes = 50000,
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
}
