import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/presensi_controller.dart';

class PresencePage extends StatefulWidget {
  const PresencePage({super.key});

  @override
  State<PresencePage> createState() => _PresencePageState();
}

class _PresencePageState extends State<PresencePage> {
  late final PresensiController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.find<PresensiController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.checkLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('Presensi'),
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            ctrl.cancel();
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        final step = ctrl.step.value;
        final config = ctrl.config.value;

        if (config == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.s24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  config.faceRecognition || config.faceCapture
                      ? 'Autentikasi Wajah & Lokasi'
                      : 'Verifikasi Lokasi',
                  style: typography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.s24.h),
                _buildRequirementsCard(colors, typography),
                SizedBox(height: AppSpacing.s24.h),
                _buildLocationStatusCard(colors, typography),
                const Spacer(),
                if (step == PresensiStep.geofenceCheck ||
                    step == PresensiStep.submitting)
                  Center(child: CircularProgressIndicator(color: colors.primary))
                else if (step == PresensiStep.error)
                  Text(
                    ctrl.errorMessage.value ?? 'Terjadi kesalahan',
                    style: typography.bodyMedium.copyWith(color: colors.error),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: AppSpacing.s16.h),
                AppButton(
                  label: 'Lanjutkan Presensi',
                  onPressed: ctrl.isInsideGeofence.value ? ctrl.proceedPresensi : null,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRequirementsCard(AppColors colors, AppTypography typography) {
    final cfg = ctrl.config.value!;

    return Container(
      padding: EdgeInsets.all(AppSpacing.s16.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Syarat Presensi:',
            style: typography.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.s12.h),
          _RequirementRow(
            colors: colors,
            typography: typography,
            icon: Icons.location_on_rounded,
            title: 'Lokasi (GPS)',
            isMet: cfg.requiredLocation,
          ),
          SizedBox(height: AppSpacing.s8.h),
          _RequirementRow(
            colors: colors,
            typography: typography,
            icon: Icons.camera_alt_rounded,
            title: 'Foto / Selfie',
            isMet: cfg.faceCapture,
          ),
          SizedBox(height: AppSpacing.s8.h),
          _RequirementRow(
            colors: colors,
            typography: typography,
            icon: Icons.face_retouching_natural_rounded,
            title: 'Verifikasi Wajah (Liveness)',
            isMet: cfg.faceRecognition,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatusCard(AppColors colors, AppTypography typography) {
    final cfg = ctrl.config.value!;
    final isChecking = ctrl.step.value == PresensiStep.geofenceCheck;

    if (!cfg.needsGeofenceCheck) {
      return Container();
    }

    final isInside = ctrl.isInsideGeofence.value;
    final dist = ctrl.distanceToFence.value;
    final locName = ctrl.closestLocationName.value;

    final statusColor = isChecking
        ? colors.primary
        : (isInside ? colors.success : colors.error);

    final statusIcon = isChecking
        ? Icons.sync_rounded
        : (isInside ? Icons.check_circle_rounded : Icons.cancel_rounded);

    final statusText = isChecking
        ? 'Memeriksa lokasi...'
        : (isInside ? 'Di dalam area presensi' : 'Di luar area presensi');

    return Container(
      padding: EdgeInsets.all(AppSpacing.s16.w),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.r16),
        color: statusColor.withValues(alpha: 0.05),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 28.w),
              SizedBox(width: AppSpacing.s12.w),
              Expanded(
                child: Text(
                  statusText,
                  style: typography.titleMedium.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (!isChecking)
                 IconButton(
                    icon: Icon(Icons.refresh_rounded, color: colors.primary),
                    onPressed: () => ctrl.checkLocation(),
                 ),
            ],
          ),
          if (!isChecking) ...[
            SizedBox(height: AppSpacing.s12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jarak:',
                  style: typography.bodyMedium,
                ),
                Text(
                  '${dist.toStringAsFixed(0)} meter',
                  style: typography.bodyMedium
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            if (locName != null) ...[
              SizedBox(height: AppSpacing.s4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Titik Terdekat:',
                    style: typography.bodyMedium,
                  ),
                  Expanded(
                    child: Text(
                      locName,
                      style: typography.bodyMedium
                          .copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final AppColors colors;
  final AppTypography typography;
  final IconData icon;
  final String title;
  final bool isMet;

  const _RequirementRow({
    required this.colors,
    required this.typography,
    required this.icon,
    required this.title,
    required this.isMet,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isMet
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: isMet ? colors.success : colors.onSurface.withValues(alpha: 0.3),
          size: 20.w,
        ),
        SizedBox(width: AppSpacing.s12.w),
        Icon(icon, color: colors.onSurface, size: 20.w),
        SizedBox(width: AppSpacing.s8.w),
        Expanded(
          child: Text(
            title,
            style: typography.bodyMedium.copyWith(
              color: isMet ? colors.onSurface : colors.onSurface.withValues(alpha: 0.5),
              decoration: isMet ? null : TextDecoration.lineThrough,
            ),
          ),
        ),
      ],
    );
  }
}
