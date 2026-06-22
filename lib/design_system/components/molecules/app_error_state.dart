import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_icon_size.dart';
import '../../tokens/app_radius.dart';
import '../../tokens/app_spacing.dart';
import '../../tokens/app_typography.dart';
import '../app_button.dart';

class AppErrorState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? technicalDetails;
  final String retryLabel;
  final VoidCallback? onRetry;

  const AppErrorState({
    super.key,
    this.icon = Icons.error_outline_rounded,
    this.title = 'Terjadi Kesalahan',
    required this.message,
    this.technicalDetails,
    this.retryLabel = 'Coba Lagi',
    this.onRetry,
  });

  @override
  State<AppErrorState> createState() => _AppErrorStateState();
}

class _AppErrorStateState extends State<AppErrorState> {
  bool _isDetailsExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with soft background circle
            Container(
              padding: const EdgeInsets.all(AppSpacing.s20),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                size: AppIconSize.xxl,
                color: colors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.s24),

            // Title
            Text(
              widget.title,
              style: typography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s8),

            // Message
            Text(
              widget.message,
              style: typography.bodyMedium.copyWith(
                color: colors.onSurface.withValues(alpha: 0.65),
              ),
              textAlign: TextAlign.center,
            ),

            // Expandable Technical Details (if available)
            if (widget.technicalDetails != null && widget.technicalDetails!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.s16),
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text(
                    'Detail Error',
                    style: typography.labelSmall.copyWith(
                      color: colors.outline,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Icon(
                    _isDetailsExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colors.outline,
                    size: 18,
                  ),
                  onExpansionChanged: (expanded) {
                    setState(() {
                      _isDetailsExpanded = expanded;
                    });
                  },
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: colors.outline.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Text(
                        widget.technicalDetails!,
                        style: typography.bodySmall.copyWith(
                          color: colors.error,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Retry Button
            if (widget.onRetry != null) ...[
              const SizedBox(height: AppSpacing.s24),
              AppButton(
                label: widget.retryLabel,
                onPressed: widget.onRetry,
                icon: Icons.refresh_rounded,
                style: AppButtonStyle.filled,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
