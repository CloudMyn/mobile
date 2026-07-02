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
import '../../data/models/attendance_config.dart';

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
  void dispose() {
    ctrl.cancel();
    super.dispose();
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
                                Container(
                                  padding: EdgeInsets.all(AppSpacing.s16.w),
                                  decoration: BoxDecoration(
                                    color: colors.error.withValues(alpha: 0.05),
                                    border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                                    borderRadius: BorderRadius.circular(AppRadius.r16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.gpp_bad_rounded,
                                            color: colors.error,
                                            size: 24.w,
                                          ),
                                          SizedBox(width: AppSpacing.s8.w),
                                          Expanded(
                                            child: Text(
                                              'Presensi Diblokir',
                                              style: typography.titleMedium.copyWith(
                                                color: colors.error,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: AppSpacing.s12.h),
                                      Text(
                                        ctrl.errorMessage.value ?? 'Terjadi kesalahan keamanan.',
                                        style: typography.bodyMedium.copyWith(
                                          color: colors.onSurface,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.s16.h),
                      AppButton(
                        label: 'Lanjutkan Presensi',
                        onPressed: (ctrl.isInsideGeofence.value && step != PresensiStep.error) ? ctrl.proceedPresensi : null,
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

    if (cfg == null) {
      return const AppSkeleton();
    }

    if (pos == null) {
      if (!cfg.needsGeofenceCheck) {
        return Container(
          color: colors.primary.withValues(alpha: 0.05),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_off_rounded,
                  size: 48.w,
                  color: colors.primary.withValues(alpha: 0.5),
                ),
                SizedBox(height: AppSpacing.s8.h),
                Text(
                  'Lokasi tidak diperlukan untuk presensi ini',
                  style: typography.bodyMedium.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        );
      }
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
            final isEvent = loc.isEvent;
            final circleColor = isEvent ? Colors.amber : colors.primary;
            return CircleMarker(
              point: LatLng(loc.latitude, loc.longitude),
              color: circleColor.withValues(alpha: 0.2),
              borderColor: circleColor,
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
              final isEvent = loc.isEvent;
              return Marker(
                point: LatLng(loc.latitude, loc.longitude),
                width: 40,
                height: 40,
                child: Icon(
                  isEvent ? Icons.event_rounded : Icons.location_on,
                  color: isEvent ? Colors.amber.shade800 : colors.error,
                  size: 40,
                ),
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
                'Verifikasi Wajah',
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
    final record = ctrl.activeRecord.value;
    final isChecking = ctrl.step.value == PresensiStep.geofenceCheck;

    // Hanya sembunyikan jika tipe presensi dasarnya memang tidak butuh lokasi
    if (record != null && !record.attendanceType.requiresLocation) {
      return const SizedBox.shrink();
    }

    final isInside = ctrl.isInsideGeofence.value;
    final dist = ctrl.distanceToFence.value;
    final locName = ctrl.closestLocationName.value;
    final hasEvent = cfg.locationEventName != null;
    final isExempt = !cfg.needsGeofenceCheck;

    final statusColor = isChecking
        ? colors.primary
        : (isExempt
            ? colors.primary
            : (isInside ? colors.success : colors.error));

    final statusIcon = isChecking
        ? Icons.sync_rounded
        : (isExempt
            ? Icons.info_outline_rounded
            : (isInside ? Icons.check_circle_rounded : Icons.cancel_rounded));

    final statusText = isChecking
        ? 'Memeriksa lokasi...'
        : (isExempt
            ? 'Bebas Validasi Lokasi'
            : (isInside ? 'Di dalam area presensi' : 'Di luar area presensi'));

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
                      onPressed: () => ctrl.refreshLocationConfig(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (hasEvent) ...[
                  SizedBox(height: AppSpacing.s8.h),
                  _buildEventBadge(colors, typography, cfg),
                ],
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
                if (ctrl.currentPosition.value != null) ...[
                  SizedBox(height: AppSpacing.s4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Akurasi GPS:', style: typography.bodyMedium),
                      Text(
                        '±${ctrl.currentPosition.value!.accuracy.toStringAsFixed(0)} meter',
                        style: typography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: ctrl.currentPosition.value!.accuracy > 100 ? Colors.amber.shade800 : null,
                        ),
                      ),
                    ],
                  ),
                ],
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
                if (ctrl.currentPosition.value != null && ctrl.currentPosition.value!.accuracy > 100) ...[
                  SizedBox(height: AppSpacing.s8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s10.w,
                      vertical: AppSpacing.s8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                      border: Border.all(
                        color: Colors.amber.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber.shade800,
                          size: 18.w,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Akurasi GPS rendah. Disarankan untuk keluar ke area terbuka atau mengaktifkan Wi-Fi agar koordinat lebih akurat.',
                            style: typography.bodySmall.copyWith(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _buildEventBadge(AppColors colors, AppTypography typography, AttendanceConfig cfg) {
    final isOverride = cfg.geofenceMode == 'override';
    final modeLabel = isOverride ? 'Override' : 'Tambahan';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.r8),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.event_rounded,
            color: Colors.amber.shade800,
            size: 16.w,
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              'Event: ${cfg.locationEventName} ($modeLabel)',
              style: typography.bodySmall.copyWith(
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
