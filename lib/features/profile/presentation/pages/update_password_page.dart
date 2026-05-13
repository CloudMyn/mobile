import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/profile_controller.dart';

class UpdatePasswordPage extends StatelessWidget {
  const UpdatePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Update Password',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s16.w,
          vertical: AppSpacing.s16.h,
        ),
        child: Form(
          key: ctrl.formKeyPassword,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Keamanan Akun',
                style: typography.titleMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.s4.h),
              Text(
                'Pastikan kata sandi baru Anda kuat dan mudah diingat.',
                style: typography.bodySmall.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: AppSpacing.s24.h),
              Obx(() => AppTextField(
                    label: 'Kata Sandi Lama',
                    hint: 'Masukkan kata sandi saat ini',
                    controller: ctrl.currentPassCtrl,
                    obscureText: !ctrl.isCurrentPassVisible.value,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        ctrl.isCurrentPassVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: ctrl.toggleCurrentPassVisibility,
                    ),
                    validator: ctrl.validateCurrentPassword,
                    textInputAction: TextInputAction.next,
                  )),
              SizedBox(height: AppSpacing.s16.h),
              Obx(() => AppTextField(
                    label: 'Kata Sandi Baru',
                    hint: 'Minimal 8 karakter',
                    controller: ctrl.newPassCtrl,
                    obscureText: !ctrl.isNewPassVisible.value,
                    prefixIcon: const Icon(Icons.lock_reset_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(
                        ctrl.isNewPassVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: ctrl.toggleNewPassVisibility,
                    ),
                    validator: ctrl.validateNewPassword,
                    textInputAction: TextInputAction.next,
                  )),
              SizedBox(height: AppSpacing.s16.h),
              Obx(() => AppTextField(
                    label: 'Konfirmasi Kata Sandi Baru',
                    hint: 'Ulangi kata sandi baru',
                    controller: ctrl.confirmPassCtrl,
                    obscureText: !ctrl.isConfirmPassVisible.value,
                    prefixIcon: const Icon(Icons.lock_person_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        ctrl.isConfirmPassVisible.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: ctrl.toggleConfirmPassVisibility,
                    ),
                    validator: ctrl.validateConfirmPassword,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: ctrl.updatePassword,
                  )),
              SizedBox(height: AppSpacing.s32.h),
              Obx(() => AppButton(
                    label: 'Perbarui Kata Sandi',
                    fullWidth: true,
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: ctrl.isUpdatingPassword.value,
                    onPressed: ctrl.updatePassword,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
