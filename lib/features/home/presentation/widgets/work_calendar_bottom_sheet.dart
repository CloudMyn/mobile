import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/organisms/app_bottom_sheet.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/home_controller.dart';

class WorkCalendarBottomSheet {
  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      title: 'Kalender Kerja',
      maxHeightFraction: 0.75,
      child: const _CalendarBody(),
    );
  }
}

class _CalendarBody extends StatefulWidget {
  const _CalendarBody();

  @override
  State<_CalendarBody> createState() => _CalendarBodyState();
}

class _CalendarBodyState extends State<_CalendarBody> {
  late DateTime _displayMonth;

  static const List<String> _dayLabels = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'
  ];

  static const List<String> _monthNames = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  // Hari libur nasional Indonesia 2025–2026 (sample)
  static final List<DateTime> _nationalHolidays = [
    DateTime(2026, 1, 1),
    DateTime(2026, 3, 31),
    DateTime(2026, 4, 1),
    DateTime(2026, 4, 2),
    DateTime(2026, 4, 3),
    DateTime(2026, 5, 1),
    DateTime(2026, 5, 14),
    DateTime(2026, 5, 29),
    DateTime(2026, 6, 1),
    DateTime(2026, 8, 17),
    DateTime(2026, 12, 25),
  ];

  @override
  void initState() {
    super.initState();
    final ctrl = Get.find<HomeController>();
    _displayMonth = DateTime(
      ctrl.currentDateTime.value.year,
      ctrl.currentDateTime.value.month,
    );
  }

  void _prevMonth() => setState(() {
        _displayMonth = DateTime(_displayMonth.year, _displayMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _displayMonth = DateTime(_displayMonth.year, _displayMonth.month + 1);
      });

  bool _isHoliday(DateTime date) => _nationalHolidays.any(
        (h) => h.year == date.year && h.month == date.month && h.day == date.day,
      );

  bool _isWeekend(DateTime date) => date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final firstDay = DateTime(_displayMonth.year, _displayMonth.month, 1);
    // weekday: 1=Mon ... 7=Sun → offset = weekday - 1
    final startOffset = firstDay.weekday - 1;
    final daysInMonth = DateUtils.getDaysInMonth(_displayMonth.year, _displayMonth.month);
    final totalCells = startOffset + daysInMonth;
    final rowCount = (totalCells / 7).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month navigator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _prevMonth,
              icon: Icon(Icons.chevron_left_rounded, color: colors.onSurface),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            Text(
              '${_monthNames[_displayMonth.month]} ${_displayMonth.year}',
              style: typography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: Icon(Icons.chevron_right_rounded, color: colors.onSurface),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.s12.h),

        // Day-of-week header
        Row(
          children: _dayLabels.map((d) {
            final isWeekendHeader = d == 'Sab' || d == 'Min';
            return Expanded(
              child: Center(
                child: Text(
                  d,
                  style: typography.caption.copyWith(
                    color: isWeekendHeader
                        ? colors.warning
                        : colors.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: AppSpacing.s8.h),

        // Calendar grid
        ...List.generate(rowCount, (row) {
          return Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final dayNum = cellIndex - startOffset + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const Expanded(child: SizedBox(height: 40));
              }

              final date = DateTime(_displayMonth.year, _displayMonth.month, dayNum);
              final isHoliday = _isHoliday(date);
              final isWeekend = _isWeekend(date);
              final isToday = _isToday(date);

              Color textColor;
              Color? bgColor;
              if (isToday) {
                bgColor = colors.primary;
                textColor = colors.onPrimary;
              } else if (isHoliday) {
                textColor = colors.error;
              } else if (isWeekend) {
                textColor = colors.warning;
              } else {
                textColor = colors.onSurface;
              }

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 3.h,
                    horizontal: 3.w,
                  ),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor ?? (isHoliday
                            ? colors.error.withValues(alpha: 0.08)
                            : isWeekend
                                ? colors.warning.withValues(alpha: 0.08)
                                : Colors.transparent),
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                      ),
                      child: Center(
                        child: Text(
                          '$dayNum',
                          style: typography.bodySmall.copyWith(
                            color: textColor,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),

        SizedBox(height: AppSpacing.s16.h),

        // Legend
        Wrap(
          spacing: AppSpacing.s16.w,
          runSpacing: AppSpacing.s8.h,
          children: [
            _LegendItem(color: colors.primary, label: 'Hari Ini', typography: typography),
            _LegendItem(color: colors.onSurface, label: 'Hari Kerja', typography: typography),
            _LegendItem(color: colors.warning, label: 'Weekend', typography: typography),
            _LegendItem(color: colors.error, label: 'Hari Libur', typography: typography),
          ],
        ),
        SizedBox(height: AppSpacing.s8.h),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final AppTypography typography;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: typography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
