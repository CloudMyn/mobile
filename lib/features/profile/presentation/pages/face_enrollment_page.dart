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
      Get.back(result: true);
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Pendaftaran Wajah'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.face_retouching_natural_rounded,
                  size: 64,
                  color: colors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Daftarkan Wajah Anda',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Fitur pengenalan wajah digunakan untuk memverifikasi kehadiran Anda. Pastikan Anda berada di tempat yang terang dan wajah terlihat jelas.',
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
          ),
        ),
      ),
    );
  }
}
