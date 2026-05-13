import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/attendance_history_item.dart';
import '../helpers/attendance_status_style.dart';

class AttendanceDayTile extends StatelessWidget {
  final AttendanceHistoryItem item;

  const AttendanceDayTile({
    super.key,
    required this.item,
  });

  static const List<String> _weekdayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final style = item.status.resolveStyle(colors);

    final dateLabel =
        '${item.date.day} ${_monthNames[item.date.month - 1]} ${item.date.year}';
    final weekdayLabel = _weekdayNames[item.date.weekday - 1];
    final secondary = item.checkInTime != null && item.checkOutTime != null
        ? '${item.checkInTime} - ${item.checkOutTime}'
        : item.note ?? item.label;

    return Container(
      padding: EdgeInsets.all(AppSpacing.s12.w),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: style.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: style.foregroundColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.r12),
              border: Border.all(
                color: style.foregroundColor.withValues(alpha: 0.18),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.date.day.toString().padLeft(2, '0'),
                  style: typography.titleMedium.copyWith(
                    color: style.foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _monthNames[item.date.month - 1],
                  style: typography.caption.copyWith(
                    color: style.foregroundColor.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  weekdayLabel,
                  style: typography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.s2.h),
                Text(
                  dateLabel,
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.68),
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  secondary,
                  style: typography.bodySmall.copyWith(
                    color: style.foregroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s8.w),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s8.w,
              vertical: AppSpacing.s4.h,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppRadius.circular),
              border: Border.all(
                color: style.foregroundColor.withValues(alpha: 0.14),
              ),
            ),
            child: Text(
              item.status.label,
              style: typography.labelMedium.copyWith(
                color: style.foregroundColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
