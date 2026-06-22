import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_spacing.dart';
import '../tokens/app_radius.dart';
import 'app_button.dart';

enum FeedbackType { success, warning, info, error }

class AppFeedback {
  static void showSnackbar({
    required String title,
    required String message,
    FeedbackType type = FeedbackType.info,
    bool? isError,
  }) {
    final colors = Get.theme.extension<AppColors>()!;
    
    FeedbackType resolvedType = type;
    if (isError != null) {
      resolvedType = isError ? FeedbackType.error : FeedbackType.info;
    }

    Color bgColor;
    Color textColor;
    IconData iconData;

    switch (resolvedType) {
      case FeedbackType.success:
        bgColor = colors.success;
        textColor = colors.onSuccess;
        iconData = Icons.check_circle_outline_rounded;
        break;
      case FeedbackType.warning:
        bgColor = colors.warning;
        textColor = colors.onWarning;
        iconData = Icons.warning_amber_rounded;
        break;
      case FeedbackType.error:
        bgColor = colors.error;
        textColor = colors.onError;
        iconData = Icons.error_outline_rounded;
        break;
      case FeedbackType.info:
        bgColor = const Color(0xFF1976D2); // Solid Blue
        textColor = Colors.white;
        iconData = Icons.info_outline_rounded;
        break;
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: bgColor,
      colorText: textColor,
      margin: const EdgeInsets.all(AppSpacing.s16),
      borderRadius: AppRadius.r12,
      duration: const Duration(seconds: 3),
      barBlur: 0, // Disable blur to ensure solid background
      overlayBlur: 0,
      icon: Icon(
        iconData,
        color: textColor,
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
