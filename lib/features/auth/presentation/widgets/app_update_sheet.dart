import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';

class AppUpdateSheet extends StatelessWidget {
  final String url;
  final String changelog;
  final String name;
  final String version;
  final bool isForced;
  final VoidCallback? onContinue;
  final VoidCallback onUpdate;

  const AppUpdateSheet({
    super.key,
    required this.url,
    required this.changelog,
    required this.name,
    required this.version,
    required this.isForced,
    this.onContinue,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            left: AppSpacing.s24,
            right: AppSpacing.s24,
            top: AppSpacing.s16,
            bottom: AppSpacing.s32,
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
                  margin: const EdgeInsets.only(bottom: AppSpacing.s20),
                  decoration: BoxDecoration(
                    color: colors.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.r2),
                  ),
                ),
              
              // Icon with gradient/colored circular background
              Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary.withValues(alpha: 0.08),
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
              const SizedBox(height: AppSpacing.s4),

              // Subtitle: name — version
              if (name.isNotEmpty || version.isNotEmpty)
                Text(
                  [
                    if (name.isNotEmpty) name,
                    if (version.isNotEmpty) 'v$version',
                  ].join(' — '),
                  style: typography.bodyMedium.copyWith(
                    color: colors.primary.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
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
              
              // Changelog Box (if not empty) — rendered as markdown
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
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.12),
                      width: 1,
                    ),
                  ),
                  child: MarkdownBody(
                    data: changelog,
                    selectable: true,
                    shrinkWrap: true,
                    onTapLink: (text, href, title) {
                      if (href != null) {
                        final uri = Uri.tryParse(href);
                        if (uri != null) {
                          launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      }
                    },
                    styleSheet: _buildMarkdownStyleSheet(colors, typography),
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
        ),
      ),
    );
  }

  /// Build a MarkdownStyleSheet that matches the app's design system.
  MarkdownStyleSheet _buildMarkdownStyleSheet(AppColors colors, AppTypography typography) {
    final baseTextColor = colors.onSurface.withValues(alpha: 0.8);
    final codeBackground = colors.outline.withValues(alpha: 0.08);

    return MarkdownStyleSheet(
      // Body / paragraph
      p: typography.bodySmall.copyWith(
        color: baseTextColor,
        height: 1.5,
      ),
      // Headers
      h1: typography.titleMedium.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.bold,
      ),
      h2: typography.titleSmall.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.bold,
      ),
      h3: typography.labelLarge.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      h4: typography.labelMedium.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      h5: typography.labelSmall.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      h6: typography.caption.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.w600,
      ),
      // Bold / emphasis
      strong: typography.bodySmall.copyWith(
        color: colors.onSurface,
        fontWeight: FontWeight.bold,
      ),
      em: typography.bodySmall.copyWith(
        color: baseTextColor,
        fontStyle: FontStyle.italic,
      ),
      // Links
      a: typography.bodySmall.copyWith(
        color: colors.primary,
        decoration: TextDecoration.underline,
        decorationColor: colors.primary.withValues(alpha: 0.4),
      ),
      // Inline code
      code: typography.bodySmall.copyWith(
        color: colors.primary,
        backgroundColor: codeBackground,
        fontFamily: 'monospace',
        fontSize: 11,
      ),
      // Code blocks
      codeblockDecoration: BoxDecoration(
        color: codeBackground,
        borderRadius: BorderRadius.circular(AppRadius.r8),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      codeblockPadding: const EdgeInsets.all(AppSpacing.s12),
      // Blockquote
      blockquote: typography.bodySmall.copyWith(
        color: baseTextColor.withValues(alpha: 0.7),
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: colors.primary.withValues(alpha: 0.3),
            width: 3,
          ),
        ),
      ),
      blockquotePadding: const EdgeInsets.only(left: AppSpacing.s12),
      // Lists
      listBullet: typography.bodySmall.copyWith(
        color: colors.primary,
      ),
      listIndent: 16,
      // Horizontal rule
      horizontalRuleDecoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colors.outline.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      // Spacing
      h1Padding: const EdgeInsets.only(top: 8, bottom: 4),
      h2Padding: const EdgeInsets.only(top: 6, bottom: 4),
      h3Padding: const EdgeInsets.only(top: 4, bottom: 2),
      pPadding: const EdgeInsets.only(bottom: 4),
    );
  }
}
