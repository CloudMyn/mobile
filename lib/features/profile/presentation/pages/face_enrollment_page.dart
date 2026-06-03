import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../core/network/session_manager.dart';
import '../../../presensi/data/services/face_service.dart';
import '../../../presensi/presentation/pages/liveness_page.dart';
import '../../data/repositories/profile_repository.dart';

class FaceEnrollmentPage extends StatefulWidget {
  const FaceEnrollmentPage({super.key});

  @override
  State<FaceEnrollmentPage> createState() => _FaceEnrollmentPageState();
}

class _FaceEnrollmentPageState extends State<FaceEnrollmentPage> {
  bool _isLoading = false;

  Future<void> _startEnrollment() async {
    final resultBytes = await Get.to<Uint8List?>(() => const LivenessPage());
    if (resultBytes == null) return;

    setState(() => _isLoading = true);
    
    try {
      final faceService = Get.find<FaceService>();
      final result = await faceService.extractEmbeddingFromBytes(resultBytes);
      
      if (result == null) {
        throw 'Wajah tidak terdeteksi pada foto. Silakan coba lagi.';
      }
      
      final base64Data = faceService.embeddingToBase64(result.embedding);
      
      final repository = Get.find<ProfileRepository>();
      final updatedUser = await repository.enrollFace(base64Data);
      
      Get.find<SessionManager>().setUser(updatedUser);
      
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Data wajah Anda berhasil disimpan.',
      );
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal Mendaftarkan Wajah',
        message: e.toString(),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFace() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Wajah'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus data wajah Anda? Anda tidak dapat melakukan absensi dengan Face Recognition sampai Anda mendaftarkan wajah kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final repository = Get.find<ProfileRepository>();
      final updatedUser = await repository.deleteFace();
      
      Get.find<SessionManager>().setUser(updatedUser);
      
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Data wajah Anda berhasil dihapus.',
      );
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal Menghapus Wajah',
        message: e.toString(),
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final session = Get.find<SessionManager>();
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Pendaftaran Wajah'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Obx(() {
            final user = session.currentUser.value;
            final hasFace = user?.faceData != null && user!.faceData!.isNotEmpty;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: hasFace 
                        ? colors.success.withValues(alpha: 0.1)
                        : colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasFace ? Icons.face_rounded : Icons.face_retouching_natural_rounded,
                    size: 64,
                    color: hasFace ? colors.success : colors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  hasFace ? 'Wajah Terdaftar' : 'Daftarkan Wajah Anda',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  hasFace
                      ? 'Wajah Anda sudah terdaftar di sistem. Anda dapat menggunakan fitur absensi Face Recognition. Lakukan pendaftaran ulang jika Anda merasa akurasi verifikasi kurang baik.'
                      : 'Fitur pengenalan wajah digunakan untuk memverifikasi kehadiran Anda. Pastikan Anda berada di tempat yang terang dan wajah terlihat jelas.',
                  style: TextStyle(
                    fontSize: 16,
                    color: colors.onSurface.withValues(alpha: 0.7),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                if (_isLoading)
                  const CircularProgressIndicator()
                else if (hasFace)
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: AppButton(
                          label: 'Daftar Ulang Wajah',
                          icon: Icons.camera_alt_rounded,
                          onPressed: _startEnrollment,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _deleteFace,
                          icon: Icon(Icons.delete_outline_rounded, color: colors.error),
                          label: Text(
                            'Hapus Data Wajah',
                            style: TextStyle(
                              color: colors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colors.error),
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: 'Mulai Pendaftaran',
                      icon: Icons.camera_alt_rounded,
                      onPressed: _startEnrollment,
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
