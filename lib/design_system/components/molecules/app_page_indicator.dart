import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_duration.dart';
import '../../tokens/app_opacity.dart';
import '../../tokens/app_radius.dart';
import '../../tokens/app_spacing.dart';

class AppPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double activeDotWidth;

  const AppPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
    this.activeDotWidth = 24,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final active = activeColor ?? colors.primary;
    final inactive = inactiveColor ?? colors.onSurface.withValues(alpha: AppOpacity.medium);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == currentIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s4 / 2),
          child: AnimatedContainer(
            duration: AppDuration.normal,
            width: isActive ? activeDotWidth : dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              color: isActive ? active : inactive,
              borderRadius: BorderRadius.circular(AppRadius.circular),
            ),
          ),
        );
      }),
    );
  }
}
