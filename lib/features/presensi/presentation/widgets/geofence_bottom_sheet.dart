import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/molecules/app_error_state.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/presensi_controller.dart';

/// Bottom sheet yang menampilkan status geofence secara real-time
/// dari [PresensiController].
class GeofenceBottomSheet extends StatelessWidget {
  const GeofenceBottomSheet({super.key});

  static Future<void> show() {
    return Get.bottomSheet<void>(
      const GeofenceBottomSheet(),
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final ctrl = Get.find<PresensiController>();

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s24.w,
        AppSpacing.s24.h,
        AppSpacing.s24.w,
        AppSpacing.s40.h,
      ),
      child: Obx(() => _buildContent(ctrl, colors, typography)),
    );
  }

  Widget _buildContent(
    PresensiController ctrl,
    AppColors colors,
    AppTypography typography,
  ) {
    final step = ctrl.step.value;

    return switch (step) {
      PresensiStep.geofenceCheck => _buildChecking(colors, typography),
      PresensiStep.error when ctrl.errorType.value == PresensiErrorType.outsideGeofence =>
        _buildOutside(ctrl, colors, typography),
      PresensiStep.error => _buildLocationError(ctrl, colors, typography),
      PresensiStep.submitting || PresensiStep.success => _buildSuccess(colors, typography),
      _ => _buildChecking(colors, typography),
    };
  }

  // ---------------------------------------------------------------------------
  //  Sedang memeriksa lokasi
  // ---------------------------------------------------------------------------
  Widget _buildChecking(AppColors colors, AppTypography typography) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.s16,
      children: [
        _SheetHandle(colors: colors),
        SizedBox(height: AppSpacing.s8.h),
        CircularProgressIndicator(color: colors.primary),
        Text(
          'Memeriksa lokasi Anda...',
          style: typography.titleMedium.copyWith(color: colors.onSurface),
          textAlign: TextAlign.center,
        ),
        Text(
          'Pastikan GPS aktif dan Anda berada di area yang diizinkan.',
          style: typography.bodySmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  //  Di dalam geofence / sedang submit
  // ---------------------------------------------------------------------------
  Widget _buildSuccess(AppColors colors, AppTypography typography) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.s12,
      children: [
        _SheetHandle(colors: colors),
        SizedBox(height: AppSpacing.s8.h),
        Container(
          width: 64.w,
          height: 64.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.success.withValues(alpha: 0.12),
          ),
          child: Icon(
            Icons.location_on_rounded,
            color: colors.success,
            size: 32.sp,
          ),
        ),
        Text(
          'Lokasi Terverifikasi',
          style: typography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Anda berada di dalam area yang diizinkan.',
          style: typography.bodySmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6)),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.s4.h),
        const CircularProgressIndicator(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  //  Di luar geofence
  // ---------------------------------------------------------------------------
  Widget _buildOutside(
    PresensiController ctrl,
    AppColors colors,
    AppTypography typography,
  ) {
    final distance = ctrl.distanceToFence.value;
    final radius = ctrl.config.value?.geofenceRadius ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.s16,
      children: [
        _SheetHandle(colors: colors),
        AppErrorState(
          title: 'Di Luar Area Presensi',
          message:
              'Jarak Anda: ${distance.toStringAsFixed(0)} m\n'
              'Radius yang diizinkan: ${radius.toStringAsFixed(0)} m',
        ),
        AppButton(
          label: 'Coba Lagi',
          fullWidth: true,
          icon: Icons.refresh_rounded,
          onPressed: () {
            Get.back();
            ctrl.retry();
          },
        ),
        AppButton(
          label: 'Batal',
          style: AppButtonStyle.ghost,
          fullWidth: true,
          onPressed: () {
            Get.back();
            ctrl.cancel();
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  //  Error lokasi (permission / timeout / GPS mati)
  // ---------------------------------------------------------------------------
  Widget _buildLocationError(
    PresensiController ctrl,
    AppColors colors,
    AppTypography typography,
  ) {
    final isPermPermanent = ctrl.errorType.value ==
        PresensiErrorType.locationPermissionPermanentlyDenied;

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: AppSpacing.s16,
      children: [
        _SheetHandle(colors: colors),
        AppErrorState(
          title: 'Gagal Mendapatkan Lokasi',
          message: ctrl.errorMessage.value ?? 'Terjadi kesalahan lokasi.',
        ),
        if (isPermPermanent)
          AppButton(
            label: 'Buka Pengaturan',
            fullWidth: true,
            icon: Icons.settings_rounded,
            onPressed: () {
              Get.back();
              // openAppSettings dipanggil dari luar jika diperlukan
            },
          )
        else
          AppButton(
            label: 'Coba Lagi',
            fullWidth: true,
            icon: Icons.refresh_rounded,
            onPressed: () {
              Get.back();
              ctrl.retry();
            },
          ),
        AppButton(
          label: 'Batal',
          style: AppButtonStyle.ghost,
          fullWidth: true,
          onPressed: () {
            Get.back();
            ctrl.cancel();
          },
        ),
      ],
    );
  }
}

// =============================================================================
//  Handle dekorasi
// =============================================================================
class _SheetHandle extends StatelessWidget {
  final AppColors colors;
  const _SheetHandle({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: colors.outline.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
    );
  }
}
