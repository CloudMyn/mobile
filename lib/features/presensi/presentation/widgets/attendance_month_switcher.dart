import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';

class AttendanceMonthSwitcher extends StatelessWidget {
  final String label;
  final bool canGoPrev;
  final bool canGoNext;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const AttendanceMonthSwitcher({
    super.key,
    required this.label,
    required this.canGoPrev,
    required this.canGoNext,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return AppCard(
      child: Row(
        children: [
          _MonthNavButton(
            icon: Icons.chevron_left_rounded,
            enabled: canGoPrev,
            onTap: onPrev,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Periode Presensi',
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  label,
                  style: typography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _MonthNavButton(
            icon: Icons.chevron_right_rounded,
            enabled: canGoNext,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _MonthNavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    return Material(
      color: enabled
          ? colors.primary.withValues(alpha: 0.10)
          : colors.outline.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppRadius.r12),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.r12),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(
            icon,
            color: enabled
                ? colors.primary
                : colors.onSurface.withValues(alpha: 0.28),
          ),
        ),
      ),
    );
  }
}
