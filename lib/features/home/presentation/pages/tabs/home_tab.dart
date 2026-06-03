import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_radius.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/date_time_widget.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/quick_action_grid.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return RefreshIndicator(
      onRefresh: () => homeController.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s12.w,
          vertical: AppSpacing.s12.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const NotificationBell(),
                const DateTimeWidget(),
              ],
            ),
            SizedBox(height: AppSpacing.s8.h),
            const AttendanceCard(),
            SizedBox(height: AppSpacing.s16.h),
            const QuickActionGrid(),
            SizedBox(height: AppSpacing.s24.h),
            // ── Ads Placeholder ────────────────────────────────
            const _AdsPlaceholder(),
            SizedBox(height: AppSpacing.s32.h),
          ],
        ),
      ),
    );
  }
}

// ── Ads Placeholder ──────────────────────────────────────────────

class _AdsPlaceholder extends StatelessWidget {
  const _AdsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.s32.h,
        horizontal: AppSpacing.s16.w,
      ),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.2),
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.ad_units_rounded,
            size: 32,
            color: colors.onSurface.withValues(alpha: 0.25),
          ),
          SizedBox(height: AppSpacing.s8.h),
          Text(
            'Iklan',
            style: typography.labelMedium.copyWith(
              color: colors.onSurface.withValues(alpha: 0.25),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.s4.h),
          Text(
            'Lorem ipsum dolor sit amet',
            style: typography.caption.copyWith(
              color: colors.onSurface.withValues(alpha: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
