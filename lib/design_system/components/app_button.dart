import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_duration.dart';
import '../tokens/app_elevation.dart';
import '../tokens/app_icon_size.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

enum AppButtonStyle { filled, outlined, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.style = AppButtonStyle.filled,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: AppIconSize.sm,
            height: AppIconSize.sm,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getTextColor(colors),
            ),
          ),
          const SizedBox(width: AppSpacing.s8),
        ] else if (icon != null) ...[
          Icon(icon, size: AppIconSize.md, color: _getTextColor(colors)),
          const SizedBox(width: AppSpacing.s8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _getTextColor(colors),
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );

    if (fullWidth) content = SizedBox(width: double.infinity, child: content);

    switch (style) {
      case AppButtonStyle.filled:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            elevation: AppElevation.none,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s12,
            ),
            animationDuration: AppDuration.normal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
          ),
          child: content,
        );
      case AppButtonStyle.outlined:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: colors.primary),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s12,
            ),
            animationDuration: AppDuration.normal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
          ),
          child: content,
        );
      case AppButtonStyle.ghost:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s24,
              vertical: AppSpacing.s12,
            ),
            animationDuration: AppDuration.normal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
          ),
          child: content,
        );
    }
  }

  Color _getTextColor(AppColors colors) {
    if (onPressed == null && !isLoading) return colors.onSurface.withValues(alpha: 0.38);
    return switch (style) {
      AppButtonStyle.filled => colors.onPrimary,
      AppButtonStyle.outlined || AppButtonStyle.ghost => colors.primary,
    };
  }
}
