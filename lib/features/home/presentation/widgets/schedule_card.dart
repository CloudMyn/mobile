import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_icon_size.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/dashboard_model.dart';
import '../controllers/home_controller.dart';

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(() {
      final schedule = controller.todaySchedule.value;
      if (schedule == null) return const SizedBox.shrink();

      final isWorkday = schedule.isWorkday;
      final icon = isWorkday ? Icons.schedule_rounded : Icons.beach_access_rounded;
      final iconColor = isWorkday ? colors.primary : colors.warning;

      return AppCard(
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: AppIconSize.lg),
            ),
            SizedBox(width: AppSpacing.s16.w),
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
                  if (isWorkday) ...[
                    Text(
                      schedule.schedule?.name ?? 'Shift',
                      style: typography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s2.h),
                    Text(
                      _formatTimeRange(schedule),
                      style: typography.bodySmall.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ] else ...[
                    Text(
                      schedule.dayStatusLabel,
                      style: typography.titleSmall.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  String _formatTimeRange(TodaySchedule schedule) {
    String _t(String? iso) {
      if (iso == null) return '--:--';
      final dt = DateTime.tryParse(iso);
      if (dt == null) return '--:--';
      final local = dt.toLocal();
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    return '${_t(schedule.scheduledStartAt)} – ${_t(schedule.scheduledEndAt)}';
  }
}
