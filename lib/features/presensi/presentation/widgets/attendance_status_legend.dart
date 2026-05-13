import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/attendance_history_item.dart';
import '../helpers/attendance_status_style.dart';

class AttendanceStatusLegend extends StatelessWidget {
  const AttendanceStatusLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legend Status',
            style: typography.titleSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.s12.h),
          Wrap(
            spacing: AppSpacing.s8.w,
            runSpacing: AppSpacing.s8.h,
            children: AttendanceDayStatus.values.map((status) {
              final style = status.resolveStyle(colors);
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12.w,
                  vertical: AppSpacing.s8.h,
                ),
                decoration: BoxDecoration(
                  color: style.backgroundColor,
                  borderRadius: BorderRadius.circular(AppRadius.circular),
                  border: Border.all(color: style.borderColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: BoxDecoration(
                        color: style.foregroundColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s8.w),
                    Text(
                      status.label,
                      style: typography.labelMedium.copyWith(
                        color: style.foregroundColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
