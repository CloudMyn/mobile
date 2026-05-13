import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_icon_size.dart';
import '../../tokens/app_opacity.dart';
import '../../tokens/app_spacing.dart';
import '../../tokens/app_typography.dart';
import '../app_button.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const AppEmptyState({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: AppIconSize.xxl,
              color: colors.onSurface.withValues(alpha: AppOpacity.disabled),
            ),
            const SizedBox(height: AppSpacing.s16),
            Text(
              title,
              style: typography.titleMedium.copyWith(color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.s8),
              Text(
                subtitle!,
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurface.withValues(alpha: AppOpacity.hint),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.s24),
              AppButton(
                label: actionLabel!,
                onPressed: onAction,
                style: AppButtonStyle.outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
