import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_avatar_badge.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

/// Menampilkan informasi pengguna (nama, NIP, foto profil)
/// dalam satu card ringan, ditempatkan sebelum [AttendanceCard].
class UserInfoCard extends StatelessWidget {
  const UserInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final profileCtrl = Get.find<ProfileController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(() {
      final employee = profileCtrl.employee.value;

      if (employee == null) return const SizedBox.shrink();

      return AppCard(
        child: Row(
          children: [
            AppAvatar(
              imageUrl: employee.photoUrl,
              initials: profileCtrl.initials,
              size: 48.r,
            ),
            SizedBox(width: AppSpacing.s12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: typography.titleMedium.copyWith(
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.s2.h),
                  Text(
                    employee.nip,
                    style: typography.bodySmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
