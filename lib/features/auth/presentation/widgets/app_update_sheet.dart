import 'package:flutter/material.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';

class AppUpdateSheet extends StatelessWidget {
  final String url;
  final String changelog;
  final bool isForced;
  final VoidCallback? onContinue;
  final VoidCallback onUpdate;

  const AppUpdateSheet({
    super.key,
    required this.url,
    required this.changelog,
    required this.isForced,
    this.onContinue,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.s24,
        right: AppSpacing.s24,
        top: AppSpacing.s16,
        bottom: AppSpacing.s32,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Drag handle indicator (only for optional updates)
          if (!isForced)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.bottom(AppSpacing.s20),
              decoration: BoxDecoration(
                color: colors.outline.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.r2),
              ),
            ),
          
          // Icon with gradient/colored circular background
          Container(
            padding: const EdgeInsets.all(AppSpacing.s20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.primary.withOpacity(0.08),
            ),
            child: Icon(
              Icons.system_update_alt_rounded,
              size: 40,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.s16),
          
          // Title
          Text(
            'Pembaruan Tersedia',
            style: typography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.s8),
          
          // Description
          Text(
            isForced
                ? 'Versi aplikasi Anda sudah usang dan tidak didukung lagi. Silakan perbarui aplikasi untuk melanjutkan.'
                : 'Versi baru aplikasi tersedia. Perbarui sekarang untuk mendapatkan fitur terbaru.',
            style: typography.bodyMedium.copyWith(
              color: colors.onSurface.withValues(alpha: 0.65),
            ),
            textAlign: TextAlign.center,
          ),
          
          // Changelog Box (if not empty)
          if (changelog.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Catatan Rilis:',
                style: typography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.s8),
            Container(
              width: double.infinity,
              maxHeight: 120,
              padding: const EdgeInsets.all(AppSpacing.s16),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(AppRadius.r12),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  changelog,
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
          
          const SizedBox(height: AppSpacing.s24),
          
          // Primary Action (Update Button)
          AppButton(
            label: 'Update Sekarang',
            style: AppButtonStyle.filled,
            fullWidth: true,
            icon: Icons.download_rounded,
            onPressed: onUpdate,
          ),
          
          // Secondary Action (Cancel/Nanti Button)
          if (!isForced) ...[
            const SizedBox(height: AppSpacing.s12),
            AppButton(
              label: 'Nanti Saja',
              style: AppButtonStyle.ghost,
              fullWidth: true,
              onPressed: onContinue,
            ),
          ],
        ],
      ),
    );
  }
}
