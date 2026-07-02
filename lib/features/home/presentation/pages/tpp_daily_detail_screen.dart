import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/statistik_model.dart';

class TppDailyDetailScreen extends StatelessWidget {
  const TppDailyDetailScreen({super.key, required this.tpp});

  final StatistikTpp tpp;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Detail Potongan Harian',
          style: typography.titleMedium.copyWith(color: colors.onSurface),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onSurface),
      ),
      body: tpp.dailyRecords.isEmpty
          ? _EmptyState(colors: colors, typography: typography)
          : ListView.separated(
              padding: EdgeInsets.all(AppSpacing.s16.w),
              itemCount: tpp.dailyRecords.length,
              separatorBuilder: (_, __) => SizedBox(height: AppSpacing.s12.h),
              itemBuilder: (context, index) {
                final record = tpp.dailyRecords[index];
                return _DailyRecordCard(
                  record: record,
                  colors: colors,
                  typography: typography,
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.typography});

  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                color: colors.primary,
                size: 36.w,
              ),
            ),
            SizedBox(height: AppSpacing.s24.h),
            Text(
              'Belum Ada Rincian Harian',
              style: typography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s8.h),
            Text(
              'Data rincian potongan harian TPP untuk periode ini belum dihitung atau belum disinkronkan oleh admin.',
              style: typography.bodyMedium.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyRecordCard extends StatelessWidget {
  const _DailyRecordCard({
    required this.record,
    required this.colors,
    required this.typography,
  });

  final StatistikTppDailyRecord record;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final dateObj = DateTime.tryParse(record.recordDate);
    final dateStr = dateObj != null
        ? DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(dateObj)
        : record.recordDate;

    final isOffday = !record.isWorkday;
    final hasDisciplineDeduction = record.disciplineDeductionPct > 0;
    final hasActivityDeduction = record.activityDeductionPct > 0;
    final noDeduction = !hasDisciplineDeduction && !hasActivityDeduction;

    Color statusColor = colors.success;
    if (isOffday) {
      statusColor = colors.outline;
    } else if (hasDisciplineDeduction || hasActivityDeduction) {
      statusColor = colors.error;
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.s16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r12),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: typography.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8.w,
                  vertical: AppSpacing.s4.h,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Text(
                  isOffday
                      ? 'Hari Libur'
                      : (noDeduction ? 'Aman' : 'Ada Potongan'),
                  style: typography.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (!isOffday) ...[
            SizedBox(height: AppSpacing.s12.h),
            Divider(color: colors.outline.withValues(alpha: 0.1), height: 1),
            SizedBox(height: AppSpacing.s12.h),

            // Discipline Info
            _buildInfoRow(
              icon: Icons.access_time_filled_rounded,
              label: 'Disiplin',
              value: record.attendanceStatus ?? '-',
              deduction: record.disciplineDeductionPct,
              deductionLabel: 'Potongan Disiplin',
            ),

            if (record.totalLateMinutes > 0 ||
                record.totalEarlyLeaveMinutes > 0)
              Padding(
                padding: EdgeInsets.only(left: 28.w, top: 4.h, bottom: 8.h),
                child: Text(
                  'Telat: ${record.totalLateMinutes}m, Pulang Cepat: ${record.totalEarlyLeaveMinutes}m',
                  style: typography.caption.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),

            SizedBox(height: AppSpacing.s8.h),

            // Activity Info
            _buildInfoRow(
              icon: Icons.assignment_turned_in_rounded,
              label: 'Kinerja',
              value: record.hasApprovedActivity
                  ? 'Telah Input & Disetujui'
                  : 'Belum Input / Tidak Disetujui',
              deduction: record.activityDeductionPct,
              deductionLabel: 'Potongan Kinerja',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required double deduction,
    required String deductionLabel,
  }) {
    final hasDeduction = deduction > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.w, color: colors.primary.withValues(alpha: 0.7)),
        SizedBox(width: AppSpacing.s8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        if (hasDeduction)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '-${deduction.toStringAsFixed(2)}%',
                style: typography.labelLarge.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                deductionLabel,
                style: typography.caption.copyWith(
                  color: colors.error.withValues(alpha: 0.8),
                  fontSize: 10.sp,
                ),
              ),
            ],
          )
        else
          Text(
            '0%',
            style: typography.labelLarge.copyWith(
              color: colors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
