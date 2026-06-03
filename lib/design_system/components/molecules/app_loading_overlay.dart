import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_opacity.dart';
import '../../tokens/app_radius.dart';
import '../../tokens/app_spacing.dart';
import '../../tokens/app_typography.dart';

class AppLoadingOverlay {
  static final _message = Rx<String?>(null);
  static bool _isShowing = false;

  static void show([String? message]) {
    _message.value = message;
    if (_isShowing) return;

    _isShowing = true;
    final colors = Get.theme.extension<AppColors>()!;
    final typography = Get.theme.extension<AppTypography>()!;

    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s32,
                vertical: AppSpacing.s24,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: AppOpacity.light),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: colors.primary,
                    strokeWidth: 3,
                  ),
                  Obx(() {
                    final msg = _message.value;
                    if (msg == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.s16),
                      child: Text(
                        msg,
                        style: typography.bodyMedium.copyWith(color: colors.onSurface),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: AppOpacity.scrim),
    );
  }

  static void hide() {
    if (!_isShowing) return;
    _isShowing = false;
    _message.value = null;
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}
