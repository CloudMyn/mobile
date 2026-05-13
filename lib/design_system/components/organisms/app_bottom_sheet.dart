import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_spacing.dart';
import '../../tokens/app_typography.dart';

class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool showDragHandle = true,
    bool isDismissible = true,
    bool isScrollControlled = true,
    double? maxHeightFraction,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: isScrollControlled,
      useSafeArea: true,
      builder: (ctx) => _AppBottomSheetContent(
        title: title,
        showDragHandle: showDragHandle,
        maxHeightFraction: maxHeightFraction,
        child: child,
      ),
    );
  }
}

class _AppBottomSheetContent extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showDragHandle;
  final double? maxHeightFraction;

  const _AppBottomSheetContent({
    required this.child,
    this.title,
    this.showDragHandle = true,
    this.maxHeightFraction,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final maxHeight = maxHeightFraction != null
        ? MediaQuery.of(context).size.height * maxHeightFraction!
        : MediaQuery.of(context).size.height * 0.9;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s16,
                AppSpacing.s24,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: typography.titleLarge.copyWith(color: colors.onSurface),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.onSurface),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                ],
              ),
            ),
            Divider(
              height: AppSpacing.s16,
              color: colors.outline.withValues(alpha: 0.12),
            ),
          ],
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s24,
                AppSpacing.s8,
                AppSpacing.s24,
                AppSpacing.s24,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
