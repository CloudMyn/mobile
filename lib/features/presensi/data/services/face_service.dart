import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:dio/dio.dart';

class FaceService {
  final Dio _dio;

  FaceService(this._dio);

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
    // Mulai dari quality 90, turunkan 10 per iterasi
    for (var quality = 90; quality >= 10; quality -= 10) {
      final encoded = img.encodeJpg(image, quality: quality);
      if (encoded.length <= maxBytes) return Uint8List.fromList(encoded);
    }
    // Jika masih terlalu besar, resize dimensi lalu coba lagi
    final resized = img.copyResize(image, width: 256);
    for (var quality = 90; quality >= 10; quality -= 10) {
      final encoded = img.encodeJpg(resized, quality: quality);
      if (encoded.length <= maxBytes) return Uint8List.fromList(encoded);
    }
    // Fallback: kembalikan hasil terkecil
    return Uint8List.fromList(img.encodeJpg(resized, quality: 10));
  }

  /// Upload foto wajah ke server. Return URL foto yang tersimpan.
  Future<String> uploadFaceImage(
    Uint8List imageBytes,
    String filename,
  ) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        imageBytes,
        filename: filename,
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      '/presensi/upload-face',
      data: formData,
    );

    final data = response.data;
    if (data == null || data['url'] == null) {
      throw Exception('Upload berhasil tapi URL tidak diterima');
    }
    return data['url'] as String;
  }

  /// Kirim embedding dari server. Return vector embedding.
  Future<List<double>> extractEmbedding(
    Uint8List imageBytes,
    String filename,
  ) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        imageBytes,
        filename: filename,
        contentType: DioMediaType('image', 'jpeg'),
      ),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      '/presensi/face-embedding',
      data: formData,
    );

    final data = response.data;
    if (data == null || data['embedding'] == null) {
      throw Exception('Gagal mendapatkan embedding wajah');
    }
    final raw = data['embedding'] as List<dynamic>;
    return raw.map((e) => (e as num).toDouble()).toList();
  }
}
