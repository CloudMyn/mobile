import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/shift_model.dart';
import '../controllers/profile_controller.dart';

class ShiftSchedulePage extends StatelessWidget {
  const ShiftSchedulePage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ProfileController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Jadwal Shift',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s16.w,
                vertical: AppSpacing.s16.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pilih jadwal shift kerja Anda',
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  Obx(() => Column(
                        children: ctrl.shifts
                            .map((shift) => Padding(
                                  padding: EdgeInsets.only(
                                      bottom: AppSpacing.s12.h),
                                  child: _ShiftCard(
                                    shift: shift,
                                    isSelected:
                                        ctrl.selectedShiftId.value == shift.id,
                                    onTap: () => ctrl.selectShift(shift.id),
                                  ),
                                ))
                            .toList(),
                      )),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s16.w,
              AppSpacing.s8.h,
              AppSpacing.s16.w,
              AppSpacing.s32.h,
            ),
            child: Obx(() => AppButton(
                  label: 'Simpan Jadwal',
                  fullWidth: true,
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: ctrl.isUpdatingShift.value,
                  onPressed: ctrl.saveShift,
                )),
          ),
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final ShiftModel shift;
  final bool isSelected;
  final VoidCallback onTap;

  const _ShiftCard({
    required this.shift,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(
          color: isSelected
              ? colors.primary
              : colors.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.s16.w),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.primaryContainer
                      : colors.outline.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _shiftIcon,
                  size: 22,
                  color: isSelected ? colors.primary : colors.outline,
                ),
              ),
              SizedBox(width: AppSpacing.s12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shift ${shift.name}',
                      style: typography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${shift.checkIn} – ${shift.checkOut}',
                      style: typography.bodySmall.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isSelected ? colors.primary : colors.outline,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData get _shiftIcon {
    switch (shift.name.toLowerCase()) {
      case 'pagi':
        return Icons.wb_sunny_rounded;
      case 'siang':
        return Icons.brightness_5_rounded;
      case 'malam':
        return Icons.nights_stay_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }
}
