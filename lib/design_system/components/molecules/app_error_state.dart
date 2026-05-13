import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_icon_size.dart';
import '../../tokens/app_opacity.dart';
import '../../tokens/app_spacing.dart';
import '../../tokens/app_typography.dart';
import '../app_button.dart';

class AppErrorState extends StatelessWidget {
  final String? title;
  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    this.title = 'Terjadi Kesalahan',
    required this.message,
    this.retryLabel = 'Coba Lagi',
    this.onRetry,
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
              Icons.error_outline_rounded,
              size: AppIconSize.xxl,
              color: colors.error.withValues(alpha: 0.7),
            ),
            const SizedBox(height: AppSpacing.s16),
            if (title != null)
              Text(
                title!,
                style: typography.titleMedium.copyWith(color: colors.onSurface),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: AppSpacing.s8),
            Text(
              message,
              style: typography.bodyMedium.copyWith(
                color: colors.onSurface.withValues(alpha: AppOpacity.hint),
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.s24),
              AppButton(
                label: retryLabel,
                onPressed: onRetry,
                icon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
