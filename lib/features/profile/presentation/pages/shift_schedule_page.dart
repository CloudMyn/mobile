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
      body: Obx(() {
        if (ctrl.isLoadingSchedules.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.shifts.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_busy_rounded,
                    size: 64,
                    color: colors.outline.withValues(alpha: 0.4),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  Text(
                    'Tidak ada jadwal tersedia',
                    style: typography.titleMedium.copyWith(
                      color: colors.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.s8.h),
                  Text(
                    'Hubungi admin instansi Anda untuk mengatur jadwal kerja.',
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
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
                    SizedBox(height: AppSpacing.s12.h),
                    _InfoBanner(
                      hasCheckedInToday: ctrl.hasCheckedInToday.value,
                      colors: colors,
                      typography: typography,
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
                                      isCurrent: ctrl.selectedShiftId.value == shift.id,
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
        );
      }),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final bool hasCheckedInToday;
  final AppColors colors;
  final AppTypography typography;

  const _InfoBanner({
    required this.hasCheckedInToday,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon;
    final String message;
    final Color bgColor;
    final Color iconColor;

    if (hasCheckedInToday) {
      icon = Icons.info_outline_rounded;
      bgColor = colors.warning.withValues(alpha: 0.15);
      iconColor = colors.warning;
      message =
          'Anda sudah presensi masuk hari ini. Jika mengubah jadwal, perubahan akan berlaku mulai besok.';
    } else {
      icon = Icons.check_circle_outline_rounded;
      bgColor = colors.primaryContainer.withValues(alpha: 0.3);
      iconColor = colors.primary;
      message =
          'Anda belum presensi hari ini. Jika mengubah jadwal, perubahan akan langsung berlaku hari ini.';
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.s12.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.r12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          SizedBox(width: AppSpacing.s8.w),
          Expanded(
            child: Text(
              message,
              style: typography.bodySmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final ShiftModel shift;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  const _ShiftCard({
    required this.shift,
    required this.isSelected,
    required this.isCurrent,
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            shift.name,
                            style: typography.titleSmall.copyWith(
                              color: colors.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (shift.isGlobal) ...[
                          SizedBox(width: AppSpacing.s8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 6.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.outline.withValues(alpha: 0.1),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r4),
                            ),
                            child: Text(
                              'Global',
                              style: typography.labelSmall.copyWith(
                                color: colors.outline,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${shift.checkIn} – ${shift.checkOut}',
                      style: typography.bodySmall.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    if (shift.institutionName != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        shift.institutionName!,
                        style: typography.labelSmall.copyWith(
                          color: colors.outline.withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
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
    final name = shift.name.toLowerCase();
    if (name.contains('pagi') || name.contains('morning')) {
      return Icons.wb_sunny_rounded;
    }
    if (name.contains('siang') || name.contains('afternoon')) {
      return Icons.brightness_5_rounded;
    }
    if (name.contains('malam') || name.contains('night')) {
      return Icons.nights_stay_rounded;
    }
    if (name.contains('reguler') || name.contains('normal')) {
      return Icons.access_time_rounded;
    }
    return Icons.schedule_rounded;
  }
}
