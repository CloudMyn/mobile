import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_text_field.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_icon_size.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/auth_controller.dart';
import '../widgets/wave_background.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      body: Stack(
        children: [
          // === FULL-SCREEN GRADIENT BACKGROUND ===
          const Positioned.fill(
            child: RippleGradientBackground(),
          ),

          // === CONTENT DI ATAS BACKGROUND ===
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 60.h),

                  // === LOGO & HEADER ===
                  _buildHeader(colors, typography),
                  SizedBox(height: 48.h),

                  // === FORM ===
                  _buildForm(controller, colors, typography),

                  SizedBox(height: AppSpacing.s32.h),

                  // === VERSION ===
                  Center(
                    child: Text(
                      '${AppConstants.appName} ${AppConstants.fullVersion}',
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ),

                  SizedBox(height: AppSpacing.s24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColors colors, AppTypography typography) {
    return Column(
      children: [
        // Icon logo
        Container(
          width: 72.w,
          height: 72.h,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.fingerprint,
            size: 36,
            color: colors.primary,
          ),
        ),
        SizedBox(height: 16.h),

        // App name
        Text(
          AppConstants.appName,
          style: typography.h2.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),

        // Subtitle
        Text(
          'Sistem Presensi ASN',
          style: typography.bodyMedium.copyWith(
            color: colors.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(
    AuthController controller,
    AppColors colors,
    AppTypography typography,
  ) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            'Selamat Datang',
            style: typography.titleLarge.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Silakan masuk menggunakan akun Anda',
            style: typography.bodyMedium.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 24.h),

          // NIP Field
          AppTextField(
            label: 'NIP',
            hint: 'Masukkan NIP Anda',
            controller: controller.nipController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            prefixIcon: Icon(
              Icons.badge_outlined,
              size: AppIconSize.lg,
              color: colors.outline,
            ),
            validator: controller.validateNip,
          ),
          SizedBox(height: AppSpacing.s20.h),

          // Password Field
          Obx(
            () => AppTextField(
              label: 'Kata Sandi',
              hint: 'Masukkan kata sandi',
              controller: controller.passwordController,
              obscureText: !controller.isPasswordVisible.value,
              textInputAction: TextInputAction.done,
              prefixIcon: Icon(
                Icons.lock_outlined,
                size: AppIconSize.lg,
                color: colors.outline,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.isPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: AppIconSize.lg,
                  color: colors.outline,
                ),
                onPressed: controller.togglePasswordVisibility,
              ),
              validator: controller.validatePassword,
              onEditingComplete: controller.login,
            ),
          ),
          SizedBox(height: AppSpacing.s32.h),

          // Login Button
          Obx(
            () => AppButton(
              label: 'Masuk',
              onPressed: controller.login,
              isLoading: controller.isLoading.value,
              fullWidth: true,
            ),
          ),
        ],
      ),
    );
  }
}
