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
import '../../../presensi/data/models/attendance_config.dart';
import '../../../presensi/presentation/controllers/presensi_controller.dart';
import '../../../presensi/presentation/widgets/geofence_bottom_sheet.dart';
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
        if (Get.isDialogOpen == true) Get.back();
      }
    }));

    // Geofence bottom sheet
    _workers.add(ever(_presCtrl.step, (PresensiStep step) {
      final isGeofenceStep = step == PresensiStep.geofenceCheck;
      final isLocationError = step == PresensiStep.error &&
          (_presCtrl.errorType.value == PresensiErrorType.outsideGeofence ||
              _presCtrl.errorType.value ==
                  PresensiErrorType.locationPermissionDenied ||
              _presCtrl.errorType.value ==
                  PresensiErrorType.locationPermissionPermanentlyDenied ||
              _presCtrl.errorType.value ==
                  PresensiErrorType.locationServiceDisabled ||
              _presCtrl.errorType.value ==
                  PresensiErrorType.locationTimeout);

      if (isGeofenceStep || isLocationError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.isBottomSheetOpen != true) GeofenceBottomSheet.show();
        });
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
            _presCtrl.cancel();
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
          color: colors.primary.withValues(alpha: 0.1),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.r12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppAvatar(
              imageUrl: photoUrl,
              initials: initials,
              size: 64.r,
            ),
            SizedBox(height: AppSpacing.s12.h),
            Text(
              name,
              style: typography.titleMedium.copyWith(
                color: colors.onSurface,
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
                color: colors.onSurface.withValues(alpha: 0.55),
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
    final color = isWorkday ? colors.primary : colors.warning;
    final label = isWorkday
        ? '${schedule.schedule?.name ?? 'Shift'}  •  '
            '${_fmtTime(schedule.scheduledStartAt)} – ${_fmtTime(schedule.scheduledEndAt)}'
        : schedule.dayStatus == 'Holiday' ? 'Hari Libur' : 'Hari Libur';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.r20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 10.sp, color: color),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              style: typography.caption.copyWith(
                color: color,
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

    if (isCompleted) {
      icon = Icons.check_circle_rounded;
      iconColor = colors.success;
    } else if (record.attendanceType.direction == 'In') {
      icon = Icons.login_rounded;
      iconColor = canTap ? colors.success : colors.outline;
    } else if (record.attendanceType.direction == 'Out') {
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
      onTap: canTap
          ? () => _presCtrl.startPresensi(
                record.attendanceType.code,
                AttendanceConfig.fromRecord(record),
              )
          : null,
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
    this.onTap,
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
  final VoidCallback? onTap;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

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
                    : isActive && enabled
                        ? iconColor.withValues(alpha: 0.15)
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
    final (label, color) = switch (status) {
      'OnTime' => ('Tepat Waktu', colors.success),
      'Late' => ('Terlambat', colors.warning),
      'EarlyLeave' => ('Pulang Cepat', colors.warning),
      'InvalidLocation' => ('Diluar Lokasi', colors.error),
      'Absent' => ('Absen', colors.error),
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
