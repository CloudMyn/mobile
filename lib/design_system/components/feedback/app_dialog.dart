import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_radius.dart';
import '../../tokens/app_spacing.dart';
import '../../tokens/app_typography.dart';
import '../app_button.dart';

class AppDialog {
  static Future<bool?> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Konfirmasi',
    String cancelLabel = 'Batal',
    bool isDestructive = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) async {
    return Get.dialog<bool>(
      _AppDialogWidget(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }

  static Future<void> info({
    required String title,
    required String message,
    String closeLabel = 'Tutup',
    IconData? icon,
  }) async {
    return Get.dialog(
      _AppDialogWidget(
        title: title,
        message: message,
        confirmLabel: closeLabel,
        icon: icon ?? Icons.info_outline_rounded,
      ),
    );
  }

  static Future<T?> custom<T>({required Widget child}) async {
    return Get.dialog<T>(child);
  }
}

class _AppDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String? cancelLabel;
  final bool isDestructive;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final IconData? icon;

  const _AppDialogWidget({
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel,
    this.isDestructive = false,
    this.onConfirm,
    this.onCancel,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.r16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 48,
                color: isDestructive ? colors.error : colors.primary,
              ),
              const SizedBox(height: AppSpacing.s12),
            ],
            Text(
              title,
              style: typography.titleLarge.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s12),
            Text(
              message,
              style: typography.bodyMedium.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.s24),
            Row(
              children: [
                if (cancelLabel != null) ...[
                  Expanded(
                    child: AppButton(
                      label: cancelLabel!,
                      style: AppButtonStyle.ghost,
                      onPressed: () {
                        Get.back(result: false);
                        onCancel?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.s12),
                ],
                Expanded(
                  child: AppButton(
                    label: confirmLabel,
                    onPressed: () {
                      Get.back(result: true);
                      onConfirm?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
