import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/attendance_history_item.dart';
import '../../data/models/attendance_history_summary.dart';
import '../helpers/attendance_status_style.dart';

class AttendanceSummaryPieChart extends StatelessWidget {
  final AttendanceHistorySummary summary;

  const AttendanceSummaryPieChart({
    super.key,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final segments = AttendanceDayStatus.values
        .map(
          (status) => _ChartSegment(
            status: status,
            value: summary.countOf(status),
            color: status.resolveStyle(colors).foregroundColor,
          ),
        )
        .where((segment) => segment.value > 0)
        .toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Bulanan',
            style: typography.titleSmall.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: AppSpacing.s4.h),
          Text(
            'Distribusi status presensi untuk bulan ini.',
            style: typography.bodySmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.62),
            ),
          ),
          SizedBox(height: AppSpacing.s16.h),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(200.w, 200.w),
                  painter: _PieChartPainter(
                    segments: segments,
                    holeColor: colors.surface,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${summary.totalDays}',
                      style: typography.headlineSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Total Hari',
                      style: typography.bodySmall.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.s16.h),
          Wrap(
            spacing: AppSpacing.s8.w,
            runSpacing: AppSpacing.s8.h,
            children: AttendanceDayStatus.values.map((status) {
              final count = summary.countOf(status);
              final style = status.resolveStyle(colors);
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12.w,
                  vertical: AppSpacing.s8.h,
                ),
                decoration: BoxDecoration(
                  color: style.backgroundColor,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: style.borderColor),
                ),
                child: Text(
                  '${status.label}: $count',
                  style: typography.labelMedium.copyWith(
                    color: style.foregroundColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ChartSegment {
  final AttendanceDayStatus status;
  final int value;
  final Color color;

  const _ChartSegment({
    required this.status,
    required this.value,
    required this.color,
  });
}

class _PieChartPainter extends CustomPainter {
  final List<_ChartSegment> segments;
  final Color holeColor;

  const _PieChartPainter({
    required this.segments,
    required this.holeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<int>(0, (sum, item) => sum + item.value);
    final rect = Offset.zero & size;
    final center = rect.center;

    if (total == 0) {
      final emptyPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, size.width / 2, emptyPaint);
      return;
    }

    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      final sweepAngle = (segment.value / total) * math.pi * 2;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    final holePaint = Paint()
      ..color = holeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, size.width * 0.28, holePaint);
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) {
    return oldDelegate.segments != segments ||
        oldDelegate.holeColor != holeColor;
  }
}
