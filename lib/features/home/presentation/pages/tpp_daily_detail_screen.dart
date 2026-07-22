import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/components/app_card.dart';
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
      body: Column(
        children: [
          _TppSummaryHeader(tpp: tpp, colors: colors, typography: typography),
          Expanded(
            child: tpp.dailyRecords.isEmpty
                ? _EmptyState(colors: colors, typography: typography)
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(AppSpacing.s16.w, 0, AppSpacing.s16.w, AppSpacing.s16.h),
                    itemCount: tpp.dailyRecords.length,
                    separatorBuilder: (_, __) => SizedBox(height: AppSpacing.s8.h),
                    itemBuilder: (context, index) {
                      final record = tpp.dailyRecords[index];
                      return _DailyRecordCard(
                        record: record,
                        colors: colors,
                        typography: typography,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TppSummaryHeader extends StatelessWidget {
  final StatistikTpp tpp;
  final AppColors colors;
  final AppTypography typography;

  const _TppSummaryHeader({
    required this.tpp,
    required this.colors,
    required this.typography,
  });

  String _formatRupiah(num val) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return format.format(val);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(AppSpacing.s16.w, AppSpacing.s16.h, AppSpacing.s16.w, AppSpacing.s8.h),
      child: AppCard(
        outlined: true,
        padding: EdgeInsets.all(AppSpacing.s16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rangkuman Potongan TPP',
              style: typography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.s12.h),

            // Nominal info row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNominalTile(
                  label: 'TPP Kotor',
                  value: _formatRupiah(tpp.amountBeforeDeduction),
                  valueColor: colors.onSurface,
                ),
                _buildNominalTile(
                  label: 'Potongan',
                  value: '-${_formatRupiah(tpp.deductionAmount)}',
                  valueColor: colors.error,
                ),
                _buildNominalTile(
                  label: 'Diterima',
                  value: _formatRupiah(tpp.amountAfterDeduction),
                  valueColor: colors.success,
                  isBold: true,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s16.h),
            Divider(color: colors.outline.withValues(alpha: 0.1), height: 1),
            SizedBox(height: AppSpacing.s16.h),

            // Capaian Bobot Perbub
            Text(
              'Capaian Penilaian (Perbub No. 2026)',
              style: typography.labelSmall.copyWith(
                color: colors.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.s10.h),

            // Disiplin Kerja progress
            _buildScoreProgress(
              label: 'Disiplin Kerja',
              weightLabel: 'Bobot 40%',
              scorePct: tpp.disciplineScore * 100,
              color: colors.success,
            ),
            SizedBox(height: AppSpacing.s10.h),

            // Produktivitas progress
            _buildScoreProgress(
              label: 'Produktivitas Kerja',
              weightLabel: 'Bobot 60%',
              scorePct: tpp.activityScore * 100,
              color: colors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNominalTile({
    required String label,
    required String value,
    required Color valueColor,
    bool isBold = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: typography.caption.copyWith(
            color: colors.onSurface.withValues(alpha: 0.5),
            fontSize: 10.sp,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: typography.bodyMedium.copyWith(
            color: valueColor,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreProgress({
    required String label,
    required String weightLabel,
    required double scorePct,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$label ($weightLabel)',
              style: typography.caption.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${scorePct.toStringAsFixed(1)}%',
              style: typography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.s4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: scorePct / 100,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6.h,
          ),
        ),
      ],
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

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8.w, vertical: AppSpacing.s2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Text(
        text,
        style: typography.caption.copyWith(
          color: color,
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getBadgeLabel(StatistikTppDailyRecord record) {
    final status = record.attendanceStatus?.toLowerCase();
    if (status != null && status.isNotEmpty) {
      return switch (status) {
        'offday' => 'Hari Libur',
        'holiday' => 'Libur Nasional',
        'wfh' => 'WFH',
        'wfa' => 'WFA',
        'leave' => 'Cuti',
        'permit' => 'Izin',
        'sick' => 'Sakit',
        'absent' => 'Alpa',
        'present' => 'Hadir',
        'workday' => 'Hari Kerja',
        _ => status.toUpperCase(),
      };
    }
    
    if (!record.isWorkday) {
      return 'Tanpa Status';
    }

    final totalDeduction = record.disciplineDeductionPct + record.activityDeductionPct;
    return totalDeduction > 0 ? 'Ada Potongan' : 'Kinerja Aman';
  }

  Color _getBadgeColor(StatistikTppDailyRecord record, AppColors colors) {
    final status = record.attendanceStatus?.toLowerCase();
    if (status != null && status.isNotEmpty) {
      if (status == 'offday' || status == 'holiday') return colors.outline;
      if (status == 'wfh' || status == 'wfa') return colors.warning;
      if (status == 'absent') return colors.error;
      if (status == 'present') return colors.success;
    }
    
    if (!record.isWorkday) {
      return colors.outline;
    }

    final totalDeduction = record.disciplineDeductionPct + record.activityDeductionPct;
    return totalDeduction > 0 ? colors.error : colors.success;
  }

  @override
  Widget build(BuildContext context) {
    final dateObj = DateTime.tryParse(record.recordDate);
    final dateStr = dateObj != null
        ? DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(dateObj)
        : record.recordDate;

    final isOffday = !record.isWorkday;
    final totalDeduction = record.disciplineDeductionPct + record.activityDeductionPct;

    return AppCard(
      outlined: true,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16.w, vertical: AppSpacing.s12.h),
      child: Row(
        children: [
          // Left Side: Date and Day
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: typography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Row(
                  children: [
                    _buildMiniBadge(
                      _getBadgeLabel(record),
                      _getBadgeColor(record, colors),
                    ),
                    if (record.isWorkday && (record.totalLateMinutes > 0 || record.totalEarlyLeaveMinutes > 0)) ...[
                      SizedBox(width: AppSpacing.s8.w),
                      Text(
                        'T:${record.totalLateMinutes}m | PC:${record.totalEarlyLeaveMinutes}m',
                        style: typography.caption.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Right Side: Deductions Summary
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isOffday)
                Text(
                  '0%',
                  style: typography.bodyMedium.copyWith(
                    color: colors.outline,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else ...[
                Row(
                  children: [
                    Icon(Icons.access_time_filled_rounded, size: 12.w, color: record.disciplineDeductionPct > 0 ? colors.error : colors.success),
                    SizedBox(width: 4.w),
                    Text(
                      'D: ${record.disciplineDeductionPct > 0 ? "-${record.disciplineDeductionPct.toStringAsFixed(1)}%" : "0%"}',
                      style: typography.labelSmall.copyWith(
                        color: record.disciplineDeductionPct > 0 ? colors.error : colors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(Icons.assignment_turned_in_rounded, size: 12.w, color: record.activityDeductionPct > 0 ? colors.error : colors.success),
                    SizedBox(width: 4.w),
                    Text(
                      'K: ${record.activityDeductionPct > 0 ? "-${record.activityDeductionPct.toStringAsFixed(1)}%" : "0%"}',
                      style: typography.labelSmall.copyWith(
                        color: record.activityDeductionPct > 0 ? colors.error : colors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
