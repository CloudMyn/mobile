import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_skeleton.dart';
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
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Expanded(
                  flex: 6,
                  child: AppSkeleton(),
                ),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AppSkeleton(
                                  height: 90.h,
                                  borderRadius: AppRadius.r16,
                                ),
                                SizedBox(height: AppSpacing.s16.h),
                                AppSkeleton(
                                  height: 80.h,
                                  borderRadius: AppRadius.r16,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.s16.h),
                        AppSkeleton(
                          height: 50.h,
                          borderRadius: AppRadius.r8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 6,
                child: _buildMap(colors, typography),
              ),
              Expanded(
                flex: 6,
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.s20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildLocationStatusCard(colors, typography),
                              SizedBox(height: AppSpacing.s16.h),
                              _buildCompactRequirements(colors, typography),
                              if (step == PresensiStep.error) ...[
                                SizedBox(height: AppSpacing.s16.h),
                                Text(
                                  ctrl.errorMessage.value ?? 'Terjadi kesalahan',
                                  style: typography.bodyMedium.copyWith(color: colors.error),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.s16.h),
                      AppButton(
                        label: 'Lanjutkan Presensi',
                        onPressed: ctrl.isInsideGeofence.value ? ctrl.proceedPresensi : null,
                        isLoading: step == PresensiStep.submitting,
                        fullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMap(AppColors colors, AppTypography typography) {
    final pos = ctrl.currentPosition.value;
    final cfg = ctrl.config.value;

    if (pos == null || cfg == null) {
      return const AppSkeleton();
    }

    final userLatLng = LatLng(pos.latitude, pos.longitude);
    final validLocations = cfg.validLocations;

    return FlutterMap(
      options: MapOptions(
        initialCenter: userLatLng,
        initialZoom: 16.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.barru_kab.presensi',
        ),
        CircleLayer(
          circles: validLocations.map((loc) {
            return CircleMarker(
              point: LatLng(loc.latitude, loc.longitude),
              color: colors.primary.withValues(alpha: 0.2),
              borderColor: colors.primary,
              borderStrokeWidth: 2,
              useRadiusInMeter: true,
              radius: (loc.radiusMeters ?? cfg.defaultRadius).toDouble(),
            );
          }).toList(),
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: userLatLng,
              width: 40,
              height: 40,
              child: const Icon(Icons.person_pin_circle, color: Colors.blue, size: 40),
            ),
            ...validLocations.map((loc) {
              return Marker(
                point: LatLng(loc.latitude, loc.longitude),
                width: 40,
                height: 40,
                child: Icon(Icons.location_on, color: colors.error, size: 40),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildCompactRequirements(AppColors colors, AppTypography typography) {
    final cfg = ctrl.config.value!;

    return Container(
      padding: EdgeInsets.all(AppSpacing.s12.w),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.r16),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Syarat Presensi',
            style: typography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.s8.h),
          Wrap(
            spacing: AppSpacing.s8.w,
            runSpacing: AppSpacing.s8.h,
            children: [
              _buildCompactChip(
                colors,
                typography,
                Icons.location_on_rounded,
                'Lokasi',
                cfg.requiredLocation,
              ),
              _buildCompactChip(
                colors,
                typography,
                Icons.camera_alt_rounded,
                'Foto',
                cfg.faceCapture,
              ),
              _buildCompactChip(
                colors,
                typography,
                Icons.face_retouching_natural_rounded,
                'Liveness',
                cfg.faceRecognition,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactChip(
    AppColors colors,
    AppTypography typography,
    IconData icon,
    String label,
    bool isRequired,
  ) {
    if (!isRequired) return const SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.r8),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: colors.primary,
            size: 16.w,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: typography.bodySmall.copyWith(
              color: colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatusCard(AppColors colors, AppTypography typography) {
    final cfg = ctrl.config.value!;
    final isChecking = ctrl.step.value == PresensiStep.geofenceCheck;

    if (!cfg.needsGeofenceCheck) {
      return const SizedBox.shrink();
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
      padding: EdgeInsets.all(AppSpacing.s12.w),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.r16),
        color: statusColor.withValues(alpha: 0.05),
      ),
      child: isChecking
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    AppSkeleton.circle(size: 24.w),
                    SizedBox(width: AppSpacing.s12.w),
                    Expanded(
                      child: AppSkeleton(height: 20.h),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.s12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppSkeleton(height: 16.h, width: 60.w),
                    AppSkeleton(height: 16.h, width: 80.w),
                  ],
                ),
                SizedBox(height: AppSpacing.s8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppSkeleton(height: 16.h, width: 100.w),
                    AppSkeleton(height: 16.h, width: 120.w),
                  ],
                ),
              ],
            )
          : Column(
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 24.w),
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
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: colors.primary),
                      onPressed: () => ctrl.checkLocation(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.s8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Jarak:', style: typography.bodyMedium),
                    Text(
                      '${dist.toStringAsFixed(0)} meter',
                      style: typography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (locName != null) ...[
                  SizedBox(height: AppSpacing.s4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Titik Terdekat:', style: typography.bodyMedium),
                      Expanded(
                        child: Text(
                          locName,
                          style: typography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}
