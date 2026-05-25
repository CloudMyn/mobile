import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_icon_size.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../presensi/data/models/attendance_config.dart';
import '../../../presensi/presentation/controllers/presensi_controller.dart';
import '../../data/models/dashboard_model.dart';
import '../controllers/home_controller.dart';

/// Alternatif card tampilan slot presensi (belum dipakai di home screen utama).
/// Menggunakan data dari [TodaySchedule.records].
class AttendanceButton extends StatelessWidget {
  const AttendanceButton({super.key});

  @override
  Widget build(BuildContext context) {
    final homeCtrl = Get.find<HomeController>();
    final presCtrl = Get.find<PresensiController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(() {
      final schedule = homeCtrl.todaySchedule.value;
      final isBusy = presCtrl.step.value != PresensiStep.idle &&
          presCtrl.step.value != PresensiStep.success &&
          presCtrl.step.value != PresensiStep.error;

      if (schedule == null || schedule.records.isEmpty) {
        return const SizedBox.shrink();
      }

      return AppCard(
        child: Column(
          children: [
            for (var i = 0; i < schedule.records.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              _buildRow(
                schedule.records[i],
                isBusy,
                colors,
                typography,
                presCtrl,
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildRow(
    TodayRecord record,
    bool isBusy,
    AppColors colors,
    AppTypography typography,
    PresensiController presCtrl,
  ) {
    final isCompleted = record.isCompleted;
    final canTap = record.isPending && record.isWindowOpen && !isBusy;
    final iconColor = record.attendanceType.direction == 'In'
        ? colors.success
        : record.attendanceType.direction == 'Out'
            ? colors.error
            : colors.primary;

    return InkWell(
      onTap: canTap
          ? () => presCtrl.startPresensi(
                record.attendanceType.code,
                AttendanceConfig.fromRecord(record),
              )
          : null,
      borderRadius: BorderRadius.circular(AppRadius.r12),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s16.w,
          vertical: AppSpacing.s12.h,
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: (isCompleted || canTap)
                    ? iconColor.withValues(alpha: 0.12)
                    : colors.outline.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_circle_rounded
                    : record.attendanceType.direction == 'In'
                        ? Icons.login_rounded
                        : Icons.logout_rounded,
                color: (isCompleted || canTap) ? iconColor : colors.outline,
                size: AppIconSize.lg,
              ),
            ),
            SizedBox(width: AppSpacing.s12.w),
            Expanded(
              child: Text(
                record.attendanceType.name,
                style: typography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: (isCompleted || canTap)
                      ? colors.onSurface
                      : colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            if (canTap)
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
              Icon(Icons.check_circle_rounded,
                  color: iconColor, size: AppIconSize.md),
          ],
        ),
      ),
    );
  }
}
