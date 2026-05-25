import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/statistik_model.dart';
import '../controllers/statistik_controller.dart';

class CutiStatCard extends StatelessWidget {
  const CutiStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StatistikController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(() {
      final balance = ctrl.primaryLeaveBalance;
      final submissions = ctrl.data.value?.recentSubmissions ?? [];
      final year = ctrl.selectedYear.value;

      if (balance == null) {
        return AppCard(
          outlined: true,
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                ),
                child: Icon(
                  Icons.beach_access_rounded,
                  color: colors.outline,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpacing.s12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kuota Cuti',
                      style: typography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Belum ada saldo cuti untuk tahun $year',
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      final remaining = balance.remainingBalance;
      final total = balance.totalAvailable;
      final used = balance.usedBalance;
      final usedPct = total > 0 ? (used / total).clamp(0.0, 1.0) : 0.0;

      final remainColor = remaining <= 3
          ? colors.error
          : remaining <= 6
              ? colors.warning
              : colors.success;

      return AppCard(
        outlined: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                      ),
                      child: Icon(
                        Icons.beach_access_rounded,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          balance.leaveTypeName.isNotEmpty
                              ? balance.leaveTypeName
                              : 'Kuota Cuti',
                          style: typography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tahun $year',
                          style: typography.caption.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s8.w,
                    vertical: AppSpacing.s4.h,
                  ),
                  decoration: BoxDecoration(
                    color: remainColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.r20),
                    border: Border.all(
                      color: remainColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    '${_fmt(remaining)} hari tersisa',
                    style: typography.caption.copyWith(
                      color: remainColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.s16.h),

            // ── Progress bar ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_fmt(used)} terpakai dari ${_fmt(total)} hari tersedia',
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  '${(usedPct * 100).toStringAsFixed(0)}%',
                  style: typography.titleSmall.copyWith(
                    color: remainColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.r4),
              child: LinearProgressIndicator(
                value: usedPct,
                backgroundColor: colors.outline.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(remainColor),
                minHeight: 6.h,
              ),
            ),

            SizedBox(height: AppSpacing.s16.h),

            // ── Detail grid ───────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(AppSpacing.s12.w),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Kuota Tahun $year',
                    value: '${_fmt(balance.currentYearQuota)} hari',
                    color: colors.onSurface,
                    typography: typography,
                  ),
                  if (balance.carryForwardBalance > 0) ...[
                    SizedBox(height: AppSpacing.s8.h),
                    _DetailRow(
                      label: 'Carry Forward',
                      value: '+${_fmt(balance.carryForwardBalance)} hari',
                      color: colors.primary,
                      typography: typography,
                    ),
                  ],
                  if (balance.additionalQuota > 0) ...[
                    SizedBox(height: AppSpacing.s8.h),
                    _DetailRow(
                      label: 'Tambahan',
                      value: '+${_fmt(balance.additionalQuota)} hari',
                      color: colors.primary,
                      typography: typography,
                    ),
                  ],
                  Divider(
                    height: AppSpacing.s16.h,
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                  _DetailRow(
                    label: 'Total Tersedia',
                    value: '${_fmt(total)} hari',
                    color: colors.onSurface,
                    bold: true,
                    typography: typography,
                  ),
                  SizedBox(height: AppSpacing.s8.h),
                  _DetailRow(
                    label: 'Sudah Terpakai',
                    value: '${_fmt(used)} hari',
                    color: colors.warning,
                    typography: typography,
                  ),
                  Divider(
                    height: AppSpacing.s16.h,
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                  _DetailRow(
                    label: 'Sisa Kuota',
                    value: '${_fmt(remaining)} hari',
                    color: remainColor,
                    bold: true,
                    typography: typography,
                  ),
                ],
              ),
            ),

            // ── Riwayat penggunaan dari recent submissions ────────────────────
            if (submissions.isNotEmpty) ...[
              SizedBox(height: AppSpacing.s16.h),
              Text(
                'Riwayat Pengajuan Terakhir',
                style: typography.labelLarge.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.s8.h),
              ...submissions.map(
                (s) => _SubmissionRow(
                  submission: s,
                  colors: colors,
                  typography: typography,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  /// Format angka ke string tanpa desimal jika bulat
  String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
    required this.typography,
  });

  final String label;
  final String value;
  final Color color;
  final bool bold;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: typography.bodySmall
              .copyWith(color: color.withValues(alpha: 0.65)),
        ),
        Text(
          value,
          style: typography.bodyMedium.copyWith(
            color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SubmissionRow extends StatelessWidget {
  const _SubmissionRow({
    required this.submission,
    required this.colors,
    required this.typography,
  });

  final StatistikRecentSubmission submission;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: colors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: colors.success,
              size: 18,
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  submission.typeName,
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_fmtDate(submission.startDate)} – ${_fmtDate(submission.endDate)}',
                  style: typography.caption.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${_fmtDays(submission.totalDays)} hari',
                style: typography.bodySmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s4.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                ),
                child: Text(
                  'Disetujui',
                  style: typography.caption.copyWith(
                    color: colors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtDate(String iso) {
    const m = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.day} ${m[dt.month]}';
  }

  String _fmtDays(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(1);
  }
}
