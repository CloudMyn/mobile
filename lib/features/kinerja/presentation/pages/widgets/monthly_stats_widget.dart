import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../design_system/components/app_card.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_radius.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import 'package:get/get.dart';
import '../../../data/models/monthly_activity_stats.dart';
import '../kinerja_statistik_page.dart';

class MonthlyStatsWidget extends StatelessWidget {
  final MonthlyActivityStats stats;

  const MonthlyStatsWidget({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Card Total Kinerja ───────────────────────────────
        AppCard(
          outlined: true,
          onTap: () => Get.to(() => const KinerjaStatistikPage()),
          padding: EdgeInsets.all(AppSpacing.s16.w),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Icon(
                  Icons.assignment_turned_in_rounded,
                  color: colors.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpacing.s12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Kinerja',
                      style: typography.bodySmall.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      '${stats.totalActivities} Kegiatan',
                      style: typography.titleMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 10.h),
        // ── Card Target Aktivitas ────────────────────────────
        AppCard(
          outlined: true,
          padding: EdgeInsets.all(AppSpacing.s16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.track_changes_rounded,
                    size: 16,
                    color: colors.warning,
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  Text(
                    'Target Bulanan',
                    style: typography.labelLarge.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${stats.totalActivities} / ${stats.target} Kegiatan',
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(stats.progressPercent * 100).round()}%',
                    style: typography.labelLarge.copyWith(
                      color: stats.progressPercent >= 1.0
                          ? colors.success
                          : colors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s8.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.r4),
                child: LinearProgressIndicator(
                  value: stats.progressPercent,
                  minHeight: 6.h,
                  backgroundColor: colors.outline.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    stats.progressPercent >= 1.0
                        ? colors.success
                        : colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
