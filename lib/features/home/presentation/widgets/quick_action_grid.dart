import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../submission/presentation/pages/submission_page.dart';
import '../pages/statistik_page.dart';
import 'work_calendar_bottom_sheet.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return AppCard(
      outlined: true,
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          _ActionButton(
            icon: Icons.calendar_month_rounded,
            label: 'Kalender',
            color: colors.primary,
            typography: typography,
            onTap: () => WorkCalendarBottomSheet.show(context),
          ),
          _Divider(colors: colors),
          _ActionButton(
            icon: Icons.upload_file_rounded,
            label: 'Pengajuan',
            color: colors.warning,
            typography: typography,
            onTap: () => Get.to(
              () => const SubmissionPage(),
              transition: Transition.rightToLeft,
            ),
          ),
          _Divider(colors: colors),
          _ActionButton(
            icon: Icons.bar_chart_rounded,
            label: 'Statistik',
            color: colors.primary,
            typography: typography,
            onTap: () => Get.to(
              () => const StatistikPage(),
              transition: Transition.rightToLeft,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final AppColors colors;
  const _Divider({required this.colors});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56.h,
      child: VerticalDivider(
        width: 1,
        thickness: 1,
        color: colors.outline.withValues(alpha: 0.15),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final AppTypography typography;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.typography,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.s16.h,
            horizontal: AppSpacing.s8.w,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Icon(icon, color: color, size: 22.sp),
              ),
              SizedBox(height: AppSpacing.s8.h),
              Text(
                label,
                style: typography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
