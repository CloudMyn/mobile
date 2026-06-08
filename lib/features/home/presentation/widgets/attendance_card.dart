import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_avatar_badge.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/feedback/app_dialog.dart';
import '../../../../design_system/components/molecules/app_loading_overlay.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_icon_size.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../presensi/presentation/controllers/presensi_controller.dart';

import '../../../presensi/presentation/widgets/presensi_step_indicator.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../data/models/dashboard_model.dart';
import '../controllers/home_controller.dart';

/// Card gabungan: profil pengguna, jadwal hari ini, dan tombol presensi.
/// Slot presensi dirender secara dinamis dari [TodaySchedule.records].
class AttendanceCard extends StatefulWidget {
  const AttendanceCard({super.key});

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  late final PresensiController _presCtrl;
  late final HomeController _homeCtrl;
  late final ProfileController _profileCtrl;
  final List<Worker> _workers = [];

  @override
  void initState() {
    super.initState();
    _presCtrl = Get.find<PresensiController>();
    _homeCtrl = Get.find<HomeController>();
    _profileCtrl = Get.find<ProfileController>();
    _setupWorkers();
  }

  void _setupWorkers() {
    // Loading overlay
    _workers.add(ever(_presCtrl.step, (PresensiStep step) {
      final loadingSteps = {PresensiStep.submitting, PresensiStep.geofenceCheck};
      if (loadingSteps.contains(step)) {
        AppLoadingOverlay.show(_presCtrl.stepLabel);
      } else {
        AppLoadingOverlay.hide();
      }
    }));



    // Success → refresh dashboard
    _workers.add(ever(_presCtrl.step, (PresensiStep step) {
      if (step != PresensiStep.success) return;
      final code = _presCtrl.activeCode.value;
      if (code == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Presensi Berhasil',
          'Presensi telah berhasil dicatat.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.extension<AppColors>()!.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );
        _homeCtrl.onPresensiSuccess();
        _presCtrl.cancel();
        Get.until((route) => route.isFirst);
      });
    }));

    // Error dialog (non-location errors)
    _workers.add(ever(_presCtrl.step, (PresensiStep step) {
      if (step != PresensiStep.error) return;
      final err = _presCtrl.errorType.value;
      if (err == null) return;

      final isLocationError = err == PresensiErrorType.outsideGeofence ||
          err == PresensiErrorType.locationPermissionDenied ||
          err == PresensiErrorType.locationPermissionPermanentlyDenied ||
          err == PresensiErrorType.locationServiceDisabled ||
          err == PresensiErrorType.locationTimeout;

      if (!isLocationError) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final retry = await AppDialog.confirm(
            title: 'Presensi Gagal',
            message: _presCtrl.errorMessage.value ?? 'Terjadi kesalahan.',
            confirmLabel: 'Coba Lagi',
            cancelLabel: 'Batal',
          );
          if (retry == true) {
            _presCtrl.retry();
          } else {
            _presCtrl.step.value = PresensiStep.idle;
          }
        });
      }
    }));
  }

  @override
  void dispose() {
    for (final w in _workers) {
      w.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(() {
      final schedule = _homeCtrl.todaySchedule.value;
      final presStep = _presCtrl.step.value;
      final presConfig = _presCtrl.config.value;

      return AppCard(
        padding: const EdgeInsets.all(0),
        outlined: true,
        child: Column(
          children: [
            _buildUserHeader(schedule, colors, typography),

            Divider(
              height: 1,
              thickness: 1,
              color: colors.outline.withValues(alpha: 0.12),
            ),

            if (presStep != PresensiStep.idle &&
                presStep != PresensiStep.success &&
                presConfig != null)
              PresensiStepIndicator(
                currentStep: presStep,
                hasFaceRecognition: presConfig.faceRecognition,
                hasFaceCapture: presConfig.faceCapture,
                hasGeofence: presConfig.needsGeofenceCheck,
              ),

            _buildAttendanceSection(schedule, colors, typography, presStep),
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  User header
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildUserHeader(
    TodaySchedule? schedule,
    AppColors colors,
    AppTypography typography,
  ) {
    return Obx(() {
      final user = _homeCtrl.dashboardData.value?.user;
      final employee = _profileCtrl.employee.value;

      final name = user?.name ?? employee?.name ?? '–';
      final nip = user?.nip ?? employee?.nip ?? '–';
      final initials = user?.initials ?? _profileCtrl.initials;
      final photoUrl = user?.profilePictureUrl ?? employee?.photoUrl;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s16.w,
          vertical: AppSpacing.s20.h,
        ),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/images/kantor_bupati_barru.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              colors.primary.withValues(alpha: 0.75),
              BlendMode.srcOver,
            ),
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.r12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 2.r,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AppAvatar(
                imageUrl: photoUrl,
                initials: initials,
                size: 64.r,
              ),
            ),
            SizedBox(height: AppSpacing.s12.h),
            Text(
              name,
              style: typography.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: AppSpacing.s4.h),
            Text(
              nip,
              style: typography.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            if (schedule != null) ...[
              SizedBox(height: AppSpacing.s12.h),
              _buildScheduleChip(schedule, colors, typography),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildScheduleChip(
    TodaySchedule schedule,
    AppColors colors,
    AppTypography typography,
  ) {
    final isWorkday = schedule.isWorkday;
    final Color chipBg;
    final Color chipText;
    final Color chipBorder;

    if (isWorkday) {
      chipBg = Colors.white.withValues(alpha: 0.15);
      chipText = Colors.white;
      chipBorder = Colors.white.withValues(alpha: 0.25);
    } else {
      chipBg = colors.warning.withValues(alpha: 0.2);
      chipText = colors.warning;
      chipBorder = colors.warning.withValues(alpha: 0.35);
    }

    final label = isWorkday
        ? '${schedule.schedule?.name ?? 'Shift'}  •  '
            '${_fmtTime(schedule.scheduledStartAt)} – ${_fmtTime(schedule.scheduledEndAt)}'
        : schedule.dayStatusLabel;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(AppRadius.r20),
        border: Border.all(color: chipBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 10.sp, color: chipText),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: typography.caption.copyWith(
                color: chipText,
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Attendance section — slots from API
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildAttendanceSection(
    TodaySchedule? schedule,
    AppColors colors,
    AppTypography typography,
    PresensiStep presStep,
  ) {
    final isBusy = presStep != PresensiStep.idle &&
        presStep != PresensiStep.success &&
        presStep != PresensiStep.error;

    if (schedule == null || !schedule.isWorkday) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.s16.w),
        child: Text(
          'Tidak ada jadwal presensi hari ini.',
          style: typography.bodyMedium.copyWith(
            color: colors.onSurface.withValues(alpha: 0.4),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final records = schedule.records;
    if (records.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(AppSpacing.s16.w),
        child: Text(
          'Tidak ada slot presensi hari ini.',
          style: typography.bodyMedium.copyWith(
            color: colors.onSurface.withValues(alpha: 0.4),
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(AppSpacing.s12.w),
      child: Column(
        children: [
          if (schedule.allCompleted) ...[
             Container(
               padding: EdgeInsets.all(AppSpacing.s12.w),
               decoration: BoxDecoration(
                 color: colors.success.withValues(alpha: 0.1),
                 borderRadius: BorderRadius.circular(AppRadius.r8),
                 border: Border.all(color: colors.success.withValues(alpha: 0.3)),
               ),
               child: Row(
                 children: [
                   Icon(Icons.verified_rounded, color: colors.success),
                   SizedBox(width: AppSpacing.s12.w),
                   Expanded(
                     child: Text(
                       'Semua Presensi Hari Ini Selesai',
                       style: typography.bodyMedium.copyWith(
                         color: colors.success,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ),
                 ],
               ),
             ),
             SizedBox(height: AppSpacing.s12.h),
          ],
          for (var i = 0; i < records.length; i++) ...[
            if (i > 0) SizedBox(height: AppSpacing.s8.h),
            _buildRecordRow(records[i], isBusy, colors, typography),
          ],
        ],
      ),
    );
  }

  Widget _buildRecordRow(
    TodayRecord record,
    bool isBusy,
    AppColors colors,
    AppTypography typography,
  ) {
    final isCompleted = record.isCompleted;
    final isPending = record.isPending;
    final canTap = isPending && record.isWindowOpen && !isBusy;

    final IconData icon;
    final Color iconColor;

    final direction = record.attendanceType.direction.toLowerCase();
    if (isCompleted) {
      icon = Icons.check_circle_rounded;
      iconColor = colors.success;
    } else if (direction == 'in') {
      icon = Icons.login_rounded;
      iconColor = canTap ? colors.success : colors.outline;
    } else if (direction == 'out') {
      icon = Icons.logout_rounded;
      iconColor = canTap ? colors.error : colors.outline;
    } else {
      icon = Icons.swap_horiz_rounded;
      iconColor = canTap ? colors.primary : colors.outline;
    }

    return _CompactRow(
      icon: icon,
      iconColor: iconColor,
      label: record.attendanceType.name,
      time: record.attendedAt != null ? _fmtTime(record.attendedAt) : null,
      scheduledTime: _fmtTime(record.expectedAt),
      isActive: canTap,
      isCompleted: isCompleted,
      status: record.status,
      isPending: isPending,
      windowOpenTime: record.windowOpenDateTime,
      windowCloseTime: record.windowCloseDateTime,
      onTap: canTap
          ? () => _homeCtrl.validateAndStartPresensi(record)
          : null,
      lateToleranceMinutes: record.attendanceType.lateToleranceMinutes,
      colors: colors,
      typography: typography,
    );
  }

  String _fmtTime(String? iso) {
    if (iso == null) return '--:--';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

// =============================================================================
//  Compact attendance row widget
// =============================================================================
class _CompactRow extends StatelessWidget {
  const _CompactRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.time,
    this.scheduledTime,
    required this.isActive,
    required this.isCompleted,
    required this.status,
    required this.isPending,
    this.windowOpenTime,
    this.windowCloseTime,
    this.onTap,
    this.lateToleranceMinutes,
    required this.colors,
    required this.typography,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String? time;
  final String? scheduledTime;
  final bool isActive;
  final bool isCompleted;
  final String status;
  final bool isPending;
  final DateTime? windowOpenTime;
  final DateTime? windowCloseTime;
  final VoidCallback? onTap;
  final int? lateToleranceMinutes;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final bool nowBeforeOpen = windowOpenTime != null && DateTime.now().toUtc().isBefore(windowOpenTime!);
    final bool nowAfterClose = windowCloseTime != null && DateTime.now().toUtc().isAfter(windowCloseTime!);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s12.w,
          vertical: AppSpacing.s8.h,
        ),
        decoration: BoxDecoration(
          color: isActive && enabled
              ? iconColor.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.r12),
          border: isActive && enabled
              ? Border.all(color: iconColor.withValues(alpha: 0.2), width: 1)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? iconColor.withValues(alpha: 0.12)
                    : colors.outline.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
              child: Icon(
                icon,
                color: isCompleted || enabled ? iconColor : colors.outline,
                size: AppIconSize.md,
              ),
            ),
            SizedBox(width: AppSpacing.s12.w),
            Expanded(
              child: Text(
                label,
                style: typography.bodyMedium.copyWith(
                  color: isCompleted || !enabled
                      ? colors.onSurface.withValues(alpha: 0.5)
                      : colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: AppSpacing.s8.w),
            if (isActive && enabled)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8.w,
                      vertical: AppSpacing.s4.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [iconColor, iconColor.withValues(alpha: 0.75)],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.r20),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app_rounded,
                            size: 12.sp, color: Colors.white),
                        SizedBox(width: 4.w),
                        Text(
                          'Sekarang',
                          style: typography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (lateToleranceMinutes != null && lateToleranceMinutes! > 0) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Toleransi: $lateToleranceMinutes menit',
                      style: typography.caption.copyWith(
                        color: colors.warning,
                        fontWeight: FontWeight.bold,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ],
              )
            else if (time != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12.sp,
                    color: isCompleted
                        ? iconColor
                        : colors.onSurface.withValues(alpha: 0.35),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    time!,
                    style: typography.bodySmall.copyWith(
                      color: isCompleted
                          ? iconColor
                          : colors.onSurface.withValues(alpha: 0.5),
                      fontWeight:
                          isCompleted ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              )
            else if (isCompleted)
              _StatusChip(status: status, colors: colors, typography: typography)
            else if (isPending && nowBeforeOpen)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8.w,
                  vertical: AppSpacing.s4.h,
                ),
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.r20),
                  border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
                ),
                child: Text(
                  'Belum Buka (${scheduledTime ?? '--:--'})',
                  style: typography.caption.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.45),
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              )
            else if (isPending && nowAfterClose)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8.w,
                  vertical: AppSpacing.s4.h,
                ),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.r20),
                  border: Border.all(color: colors.error.withValues(alpha: 0.15)),
                ),
                child: Text(
                  'Terlewat',
                  style: typography.caption.copyWith(
                    color: colors.error.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              )
            else
              Text(
                scheduledTime ?? '--:--',
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.status,
    required this.colors,
    required this.typography,
  });

  final String status;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = status.toLowerCase().replaceAll('_', '');
    final (label, color) = switch (normalizedStatus) {
      'ontime' => ('Tepat Waktu', colors.success),
      'late' => ('Terlambat', colors.warning),
      'earlyleave' => ('Pulang Cepat', colors.warning),
      'invalidlocation' => ('Diluar Lokasi', colors.error),
      'absent' => ('Absen', colors.error),
      _ => ('Tercatat', colors.success),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s2.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.r20),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10.sp,
        ),
      ),
    );
  }
}
