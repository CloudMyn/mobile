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

    return AppCard(
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
    );
  }
}
