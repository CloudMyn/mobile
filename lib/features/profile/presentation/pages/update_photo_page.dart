import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_avatar_badge.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/profile_controller.dart';

class UpdatePhotoPage extends StatelessWidget {
  const UpdatePhotoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Update Foto Profil',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Obx(() {
                final file = ctrl.photoFile.value;
                if (file != null) {
                  return CircleAvatar(
                    radius: 80.r,
                    backgroundImage: FileImage(file),
                  );
                }
                return AppAvatar(
                  imageUrl: ctrl.employee.value?.photoUrl,
                  initials: ctrl.initials,
                  size: 160.r,
                );
              }),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s16.w,
              vertical: AppSpacing.s8.h,
            ),
            child: Column(
              children: [
                AppButton(
                  label: 'Ambil Foto dari Kamera',
                  style: AppButtonStyle.outlined,
                  icon: Icons.camera_alt_rounded,
                  fullWidth: true,
                  onPressed: () => ctrl.pickPhoto(ImageSource.camera),
                ),
                SizedBox(height: AppSpacing.s12.h),
                AppButton(
                  label: 'Pilih dari Galeri',
                  style: AppButtonStyle.outlined,
                  icon: Icons.photo_library_rounded,
                  fullWidth: true,
                  onPressed: () => ctrl.pickPhoto(ImageSource.gallery),
                ),
                SizedBox(height: AppSpacing.s24.h),
                Text(
                  'Foto harus berupa gambar dengan ukuran maksimal 2 MB.',
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.s12.h),
                Obx(
                  () => AppButton(
                    label: 'Simpan Foto',
                    fullWidth: true,
                    icon: Icons.check_circle_outline_rounded,
                    isLoading: ctrl.isUpdatingPhoto.value,
                    onPressed: ctrl.photoFile.value != null
                        ? ctrl.uploadPhoto
                        : null,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.s32.h),
        ],
      ),
    );
  }
}
