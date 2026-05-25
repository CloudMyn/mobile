import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../presensi/presentation/pages/attendance_history_page.dart';
import '../controllers/statistik_controller.dart';

class MonthlyStatsCard extends StatelessWidget {
  const MonthlyStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StatistikController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(() {
      final att = ctrl.data.value?.attendance;
      final period = ctrl.data.value?.period;

      if (att == null) return const SizedBox.shrink();

      final accounted = att.accounted;
      final total = att.totalWorkdays;

      return AppCard(
        outlined: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 0,
          children: [
            // ── Header ────────────────────────────────────────────────────────
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
                          period?.label ?? '',
                          style: typography.caption.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => Get.to(() => const AttendanceHistoryPage()),
                  style: TextButton.styleFrom(
                    shape: const StadiumBorder(),
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

            // ── Summary bar ───────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$accounted dari $total hari kerja',
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  '${att.percentage.toStringAsFixed(0)}%',
                  style: typography.titleSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s12.h),

            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.r4),
              child: LinearProgressIndicator(
                value: att.percentage / 100,
                backgroundColor: colors.outline.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                minHeight: 6.h,
              ),
            ),
            SizedBox(height: AppSpacing.s16.h),

            // ── Breakdown ─────────────────────────────────────────────────────
            _AttendanceRow(
              label: 'Hadir',
              count: att.present,
              total: total,
              color: colors.success,
              typography: typography,
            ),
            SizedBox(height: AppSpacing.s8.h),
            _AttendanceRow(
              label: 'Izin',
              count: att.permissionTotal, // permit + sick
              total: total,
              color: colors.warning,
              typography: typography,
            ),
            SizedBox(height: AppSpacing.s8.h),
            _AttendanceRow(
              label: 'Cuti',
              count: att.leave,
              total: total,
              color: colors.primary,
              typography: typography,
            ),
            SizedBox(height: AppSpacing.s8.h),
            _AttendanceRow(
              label: 'Alpha',
              count: att.absent,
              total: total,
              color: att.absent > 0 ? colors.error : colors.outline,
              typography: typography,
            ),

            // ── Menit keterlambatan (info tambahan) ───────────────────────────
            if (att.totalLateMinutes > 0) ...[
              SizedBox(height: AppSpacing.s12.h),
              Divider(
                height: 1,
                color: colors.outline.withValues(alpha: 0.12),
              ),
              SizedBox(height: AppSpacing.s12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Keterlambatan',
                    style: typography.bodySmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  Text(
                    _formatMinutes(att.totalLateMinutes),
                    style: typography.bodySmall.copyWith(
                      color: colors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) return '$minutes menit';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m > 0 ? '$h jam $m menit' : '$h jam';
  }
}

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.typography,
  });

  final String label;
  final int count;
  final int total;
  final Color color;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? count / total : 0.0;

    return Row(
      children: [
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
