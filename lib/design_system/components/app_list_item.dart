import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_radius.dart';

class AppListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  const AppListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final textTheme = Theme.of(context).textTheme;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s4),
          leading: leading != null 
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                  child: Center(
                    child: IconTheme(
                      data: IconThemeData(color: colors.primary, size: 20),
                      child: leading!,
                    ),
                  ),
                )
              : null,
          title: Text(
            title,
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: colors.onSurface),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: textTheme.bodySmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.6)),
                )
              : null,
          trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: colors.outline) : null),
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r12)),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
            child: Divider(height: 1, color: colors.outline.withValues(alpha: 0.1)),
          ),
      ],
    );
  }
}
