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
import '../../../presensi/data/models/attendance_submission.dart';
import '../../../presensi/presentation/controllers/presensi_controller.dart';
import '../../../presensi/presentation/widgets/geofence_bottom_sheet.dart';
import '../../../presensi/presentation/widgets/presensi_step_indicator.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../data/models/attendance_schedule.dart';
import '../controllers/home_controller.dart';

/// Card gabungan: profil pengguna, jadwal hari ini, dan tombol presensi.
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
    _workers.add(ever(_presCtrl.step, (PresensiStep step) {
      final loadingSteps = {
        PresensiStep.loadingConfig,
        PresensiStep.faceEmbedding,
        PresensiStep.uploading,
        PresensiStep.submitting,
      };

      if (loadingSteps.contains(step)) {
        AppLoadingOverlay.show(_presCtrl.stepLabel);
      } else {
        if (Get.isDialogOpen == true) Get.back();
      }
    }));

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

    _workers.add(ever(_presCtrl.step, (PresensiStep step) {
      if (step != PresensiStep.success) return;
      final type = _presCtrl.activeType.value;
      if (type == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          'Presensi Berhasil',
          '${type.label} telah berhasil dicatat.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Get.theme.extension<AppColors>()!.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
        );

        _homeCtrl.onPresensiSuccess(type);
        _presCtrl.cancel();
      });
    }));

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
      final sched = _homeCtrl.schedule.value;
      final status = _homeCtrl.attendanceStatus.value;
      final presStep = _presCtrl.step.value;
      final presConfig = _presCtrl.config.value;

      return AppCard(
        padding: const EdgeInsets.all(0),
        outlined: true,
        child: Column(
          children: [
            _buildUserHeader(sched, colors, typography),

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

            _buildAttendanceSection(colors, typography, status, presStep),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------------------
  //  User header: foto, nama, NIP, chip jadwal
  // ---------------------------------------------------------------------------
  Widget _buildUserHeader(
    AttendanceSchedule? sched,
    AppColors colors,
    AppTypography typography,
  ) {
    return Obx(() {
      final employee = _profileCtrl.employee.value;
      if (employee == null) return const SizedBox.shrink();

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
              imageUrl: employee.photoUrl,
              initials: _profileCtrl.initials,
              size: 64.r,
            ),
            SizedBox(height: AppSpacing.s12.h),
            Text(
              employee.name,
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
              employee.nip,
              style: typography.bodySmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
            if (sched != null) ...[
              SizedBox(height: AppSpacing.s12.h),
              _buildScheduleChip(sched, colors, typography),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildScheduleChip(
    AttendanceSchedule sched,
    AppColors colors,
    AppTypography typography,
  ) {
    final color = _scheduleColor(sched.status, colors);
    final label = sched.isActive
        ? '${sched.shiftName ?? 'Shift'}  •  ${sched.checkInTime ?? '--:--'} – ${sched.checkOutTime ?? '--:--'}'
        : _statusTitle(sched.status);

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

  // ---------------------------------------------------------------------------
  //  Attendance buttons section
  // ---------------------------------------------------------------------------
  Widget _buildAttendanceSection(
    AppColors colors,
    AppTypography typography,
    AttendanceStatus status,
    PresensiStep presStep,
  ) {
    final isBusy = presStep != PresensiStep.idle &&
        presStep != PresensiStep.success &&
        presStep != PresensiStep.error;

    return Padding(
      padding: EdgeInsets.all(AppSpacing.s12.w),
      child: Column(
        children: [
          _CompactRow(
            icon: status == AttendanceStatus.checkIn
                ? Icons.login_rounded
                : Icons.check_circle_rounded,
            iconColor: colors.success,
            label: 'Presensi Masuk',
            time: _homeCtrl.checkInTime.value != null
                ? _formatTime(_homeCtrl.checkInTime.value!)
                : null,
            scheduledTime: _homeCtrl.schedule.value?.checkInTime,
            isActive: status == AttendanceStatus.checkIn && !isBusy,
            isCompleted: status != AttendanceStatus.checkIn,
            onTap: status == AttendanceStatus.checkIn && !isBusy
                ? () => _presCtrl.startPresensi(AttendanceType.checkIn)
                : null,
            colors: colors,
            typography: typography,
          ),

          SizedBox(height: AppSpacing.s8.h),

          if (status == AttendanceStatus.break_ ||
              status == AttendanceStatus.breakReturn)
            _CompactRow(
              icon: status == AttendanceStatus.break_
                  ? Icons.free_breakfast_rounded
                  : Icons.restart_alt_rounded,
              iconColor: colors.warning,
              label: status == AttendanceStatus.break_
                  ? 'Mulai Istirahat'
                  : 'Kembali Istirahat',
              time: null,
              scheduledTime: null,
              isActive: true,
              isCompleted: false,
              onTap: isBusy ? null : _homeCtrl.onBreakPressed,
              colors: colors,
              typography: typography,
            ),

          if (status == AttendanceStatus.break_ ||
              status == AttendanceStatus.breakReturn)
            SizedBox(height: AppSpacing.s8.h),

          _CompactRow(
            icon: status == AttendanceStatus.completed
                ? Icons.check_circle_rounded
                : Icons.logout_rounded,
            iconColor: status == AttendanceStatus.checkOut
                ? colors.error
                : status == AttendanceStatus.completed
                    ? colors.success
                    : colors.outline,
            label: 'Presensi Pulang',
            time: _homeCtrl.checkOutTime.value != null
                ? _formatTime(_homeCtrl.checkOutTime.value!)
                : null,
            scheduledTime: _homeCtrl.schedule.value?.checkOutTime,
            isActive: status == AttendanceStatus.checkOut && !isBusy,
            isCompleted: status == AttendanceStatus.completed,
            onTap: status == AttendanceStatus.checkOut && !isBusy
                ? () => _presCtrl.startPresensi(AttendanceType.checkOut)
                : null,
            colors: colors,
            typography: typography,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Color _scheduleColor(ScheduleStatus schedStatus, AppColors colors) {
    return switch (schedStatus) {
      ScheduleStatus.active => colors.primary,
      ScheduleStatus.dayOff => colors.warning,
      ScheduleStatus.submitted => colors.success,
      ScheduleStatus.noSchedule => colors.outline,
    };
  }

  String _statusTitle(ScheduleStatus status) {
    return switch (status) {
      ScheduleStatus.active => '',
      ScheduleStatus.dayOff => 'Hari Libur',
      ScheduleStatus.submitted => 'Sudah Pengajuan',
      ScheduleStatus.noSchedule => 'Tidak Ada Jadwal',
    };
  }
}

// =============================================================================
//  Compact attendance row widget
// =============================================================================
class _CompactRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? time;
  final String? scheduledTime;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;
  final AppColors colors;
  final AppTypography typography;

  const _CompactRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    this.time,
    this.scheduledTime,
    required this.isActive,
    required this.isCompleted,
    this.onTap,
    required this.colors,
    required this.typography,
  });

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
                  Icon(Icons.access_time_rounded,
                      size: 12.sp,
                      color: isCompleted
                          ? iconColor
                          : colors.onSurface.withValues(alpha: 0.35)),
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
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8.w,
                  vertical: AppSpacing.s2.h,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 12.sp, color: iconColor),
                    SizedBox(width: 4.w),
                    Text(
                      'Tercatat',
                      style: typography.caption.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
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
