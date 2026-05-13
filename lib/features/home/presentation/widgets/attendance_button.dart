import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_icon_size.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../presensi/data/models/attendance_submission.dart';
import '../../../presensi/presentation/controllers/presensi_controller.dart';
import '../controllers/home_controller.dart';

class AttendanceButton extends StatelessWidget {
  const AttendanceButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final presCtrl = Get.find<PresensiController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(
      () {
        final status = controller.attendanceStatus.value;
        final sched = controller.schedule.value;
        final isBusy = presCtrl.step.value != PresensiStep.idle &&
            presCtrl.step.value != PresensiStep.success &&
            presCtrl.step.value != PresensiStep.error;

        return AppCard(
          child: Column(
            children: [
              // === CHECK-IN ROW ===
              _AttendanceRow(
                icon: status == AttendanceStatus.checkIn
                    ? Icons.login_rounded
                    : Icons.check_circle_rounded,
                iconColor: colors.success,
                label: 'Presensi Masuk',
                time: controller.checkInTime.value != null
                    ? _formatTime(controller.checkInTime.value!)
                    : sched?.checkInTime ?? '--:--',
                subtitle: controller.checkInTime.value != null
                    ? 'Tercatat'
                    : 'Jadwal masuk',
                isActive: status == AttendanceStatus.checkIn && !isBusy,
                isCompleted: status != AttendanceStatus.checkIn,
                onTap: status == AttendanceStatus.checkIn && !isBusy
                    ? () => presCtrl.startPresensi(AttendanceType.checkIn)
                    : null,
                typography: typography,
                colors: colors,
              ),

              const Divider(height: 1),

              // === BREAK ROW ===
              if (status == AttendanceStatus.break_ ||
                  status == AttendanceStatus.breakReturn)
                _AttendanceRow(
                  icon: status == AttendanceStatus.break_
                      ? Icons.free_breakfast_rounded
                      : Icons.restart_alt_rounded,
                  iconColor: colors.warning,
                  label: status == AttendanceStatus.break_
                      ? 'Mulai Istirahat'
                      : 'Kembali dari Istirahat',
                  time: '--:--',
                  subtitle: 'Belum dilakukan',
                  isActive: true,
                  isCompleted: false,
                  onTap: controller.onBreakPressed,
                  typography: typography,
                  colors: colors,
                )
              else if (status == AttendanceStatus.completed)
                _AttendanceRow(
                  icon: Icons.free_breakfast_rounded,
                  iconColor: colors.outline,
                  label: 'Istirahat',
                  time: '--:--',
                  subtitle: 'Selesai',
                  isActive: false,
                  isCompleted: true,
                  onTap: null,
                  typography: typography,
                  colors: colors,
                ),

              if (status == AttendanceStatus.break_ ||
                  status == AttendanceStatus.breakReturn)
                const Divider(height: 1),

              // === CHECK-OUT ROW ===
              _AttendanceRow(
                icon: status == AttendanceStatus.completed
                    ? Icons.check_circle_rounded
                    : Icons.logout_rounded,
                iconColor: status == AttendanceStatus.checkOut
                    ? colors.error
                    : status == AttendanceStatus.completed
                        ? colors.outline
                        : colors.outline,
                label: 'Presensi Pulang',
                time: controller.checkOutTime.value != null
                    ? _formatTime(controller.checkOutTime.value!)
                    : sched?.checkOutTime ?? '--:--',
                subtitle: controller.checkOutTime.value != null
                    ? 'Tercatat'
                    : 'Jadwal pulang',
                isActive: status == AttendanceStatus.checkOut && !isBusy,
                isCompleted: status == AttendanceStatus.completed,
                onTap: status == AttendanceStatus.checkOut && !isBusy
                    ? () => presCtrl.startPresensi(AttendanceType.checkOut)
                    : null,
                typography: typography,
                colors: colors,
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute WITA';
  }
}

class _AttendanceRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String time;
  final String subtitle;
  final bool isActive;
  final bool isCompleted;
  final VoidCallback? onTap;
  final AppTypography typography;
  final AppColors colors;

  const _AttendanceRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.time,
    required this.subtitle,
    required this.isActive,
    required this.isCompleted,
    this.onTap,
    required this.typography,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s16.w,
          vertical: AppSpacing.s12.h,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? iconColor.withValues(alpha: 0.1)
                    : isActive
                        ? iconColor.withValues(alpha: 0.15)
                        : colors.outline.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: Icon(
                icon,
                color: isCompleted || !enabled
                    ? (isCompleted ? iconColor : colors.outline)
                    : iconColor,
                size: AppIconSize.lg,
              ),
            ),
            SizedBox(width: AppSpacing.s12.w),

            // Label & Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: typography.bodyMedium.copyWith(
                      color: isCompleted || !enabled
                          ? colors.onSurface.withValues(alpha: 0.5)
                          : colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppSpacing.s2.h),
                  Text(
                    time,
                    style: typography.caption.copyWith(
                      color: isCompleted
                          ? iconColor
                          : isActive
                              ? iconColor
                              : colors.onSurface.withValues(alpha: 0.3),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // Subtitle or chevron
            if (isActive && enabled)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8.w,
                  vertical: AppSpacing.s4.h,
                ),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r20),
                ),
                child: Text(
                  'Sekarang',
                  style: typography.caption.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (isCompleted)
              Icon(
                Icons.check_circle_rounded,
                color: iconColor,
                size: AppIconSize.md,
              )
            else
              Text(
                subtitle,
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
