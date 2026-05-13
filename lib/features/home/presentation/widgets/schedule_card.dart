import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_icon_size.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/attendance_schedule.dart';
import '../controllers/home_controller.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(
      () {
        final schedule = controller.schedule.value;
        if (schedule == null) return const SizedBox.shrink();

        return AppCard(
          child: Row(
            children: [
              // Icon section
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: _iconBgColor(schedule.status, colors),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _scheduleIcon(schedule.status),
                  color: _iconColor(schedule.status, colors),
                  size: AppIconSize.lg,
                ),
              ),
              SizedBox(width: AppSpacing.s16.w),

              // Info section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jadwal Hari Ini',
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4.h),
                    if (schedule.isActive) ...[
                      Text(
                        schedule.shiftName ?? 'Shift',
                        style: typography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.s2.h),
                      Text(
                        '${schedule.checkInTime ?? '--:--'} – ${schedule.checkOutTime ?? '--:--'}',
                        style: typography.bodySmall.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ] else ...[
                      Text(
                        _statusTitle(schedule.status),
                        style: typography.titleSmall.copyWith(
                          color: _iconColor(schedule.status, colors),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (schedule.message != null) ...[
                        SizedBox(height: AppSpacing.s2.h),
                        Text(
                          schedule.message!,
                          style: typography.bodySmall.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _scheduleIcon(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.active:
        return Icons.schedule_rounded;
      case ScheduleStatus.dayOff:
        return Icons.beach_access_rounded;
      case ScheduleStatus.submitted:
        return Icons.task_alt_rounded;
      case ScheduleStatus.noSchedule:
        return Icons.event_busy_rounded;
    }
  }

  Color _iconBgColor(ScheduleStatus status, AppColors colors) {
    switch (status) {
      case ScheduleStatus.active:
        return colors.primary.withValues(alpha: 0.12);
      case ScheduleStatus.dayOff:
        return colors.warning.withValues(alpha: 0.12);
      case ScheduleStatus.submitted:
        return colors.success.withValues(alpha: 0.12);
      case ScheduleStatus.noSchedule:
        return colors.outline.withValues(alpha: 0.12);
    }
  }

  Color _iconColor(ScheduleStatus status, AppColors colors) {
    switch (status) {
      case ScheduleStatus.active:
        return colors.primary;
      case ScheduleStatus.dayOff:
        return colors.warning;
      case ScheduleStatus.submitted:
        return colors.success;
      case ScheduleStatus.noSchedule:
        return colors.outline;
    }
  }

  String _statusTitle(ScheduleStatus status) {
    switch (status) {
      case ScheduleStatus.active:
        return ''; // not used for active
      case ScheduleStatus.dayOff:
        return 'Hari Libur';
      case ScheduleStatus.submitted:
        return 'Sudah Pengajuan';
      case ScheduleStatus.noSchedule:
        return 'Tidak Ada Jadwal';
    }
  }
}
