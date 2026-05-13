import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../presensi/presentation/pages/attendance_history_page.dart';
import '../controllers/home_controller.dart';

class MonthlyStatsCard extends StatelessWidget {
  const MonthlyStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(() {
      final stats = controller.monthlyAttendance.value;
      if (stats == null) return const SizedBox.shrink();

      return AppCard(
        outlined: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 0,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                      ),
                      child: Icon(
                        Icons.calendar_month_rounded,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kehadiran Bulanan',
                          style: typography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          stats.month,
                          style: typography.caption.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () =>
                      Get.to(() => const AttendanceHistoryPage()),
                  style: TextButton.styleFrom(
                    shape: StadiumBorder(),
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s12,
                      vertical: 0,
                    ),
                  ),
                  child: Text(
                    'lihat',
                    style: typography.labelLarge.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.s16.h),

            // Ringkasan bar (achieved / total)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stats.accounted} dari ${stats.total} hari kerja',
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  '${stats.percentage.toStringAsFixed(0)}%',
                  style: typography.titleSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s12.h),

            // Progress bar overall
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.r4),
              child: LinearProgressIndicator(
                value: stats.percentage / 100,
                backgroundColor: colors.outline.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                minHeight: 6.h,
              ),
            ),
            SizedBox(height: AppSpacing.s16.h),

            // Detail per kategori
            _AttendanceRow(
              label: 'Hadir',
              count: stats.present,
              total: stats.total,
              color: colors.success,
              typography: typography,
            ),
            const SizedBox(height: 8),
            _AttendanceRow(
              label: 'Izin',
              count: stats.permission,
              total: stats.total,
              color: colors.warning,
              typography: typography,
            ),
            const SizedBox(height: 8),
            _AttendanceRow(
              label: 'Cuti',
              count: stats.leave,
              total: stats.total,
              color: colors.primary,
              typography: typography,
            ),
            const SizedBox(height: 8),
            _AttendanceRow(
              label: 'Alpha',
              count: stats.absent,
              total: stats.total,
              color: stats.absent > 0 ? colors.error : colors.outline,
              typography: typography,
            ),
          ],
        ),
      );
    });
  }
}

class _AttendanceRow extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;
  final AppTypography typography;

  const _AttendanceRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        // Label
        SizedBox(
          width: 52.w,
          child: Text(
            label,
            style: typography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8.h,
            ),
          ),
        ),
        SizedBox(width: AppSpacing.s12.w),

        // Value
        SizedBox(
          width: 40.w,
          child: Text(
            '$count',
            style: typography.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
