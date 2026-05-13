import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_radius.dart';
import 'app_button.dart';

class AppFeedback {
  static void showSnackbar({
    required String title,
    required String message,
    bool isError = false,
  }) {
    final colors = Get.theme.extension<AppColors>()!;
    
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? colors.error : colors.primary,
      colorText: isError ? colors.onError : colors.onPrimary,
      margin: const EdgeInsets.all(AppSpacing.s16),
      borderRadius: AppRadius.r12,
      duration: const Duration(seconds: 3),
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: isError ? colors.onError : colors.onPrimary,
      ),
    );
  }

  static Future<void> showDialog({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    VoidCallback? onConfirm,
    String? cancelLabel,
    VoidCallback? onCancel,
  }) async {
    final textTheme = Get.textTheme;

    return Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.r16)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: AppSpacing.s16),
              Text(message, style: textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.s24),
              Row(
                children: [
                  if (cancelLabel != null)
                    Expanded(
                      child: AppButton(
                        label: cancelLabel,
                        style: AppButtonStyle.ghost,
                        onPressed: () {
                          Get.back();
                          onCancel?.call();
                        },
                      ),
                    ),
                  if (cancelLabel != null) const SizedBox(width: AppSpacing.s12),
                  Expanded(
                    child: AppButton(
                      label: confirmLabel,
                      onPressed: () {
                        Get.back();
                        onConfirm?.call();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void showLoading([String? message]) {
    final colors = Get.theme.extension<AppColors>()!;
    Get.dialog(
      Center(
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              if (message != null) ...[
                const SizedBox(height: AppSpacing.s16),
                Text(message, style: Get.textTheme.bodyMedium),
              ],
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoading() => Get.back();
}
