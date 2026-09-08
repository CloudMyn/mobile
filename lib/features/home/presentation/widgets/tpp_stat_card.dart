import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/report_viewer_controller.dart';
import '../controllers/statistik_controller.dart';
import '../pages/report_viewer_page.dart';
import '../pages/tpp_daily_detail_screen.dart';

class TppStatCard extends StatelessWidget {
  const TppStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<StatistikController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(() {
      final tpp = ctrl.data.value?.tpp;
      final period = ctrl.data.value?.period;

      if (tpp == null) {
        return AppCard(
          outlined: true,
          child: _EmptySection(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Statistik TPP',
            subtitle: period != null
                ? 'Belum ada data TPP untuk ${period.label}'
                : 'Belum ada data TPP',
            colors: colors,
            typography: typography,
          ),
        );
      }

      final pagu = tpp.paguJabatan ?? tpp.amountBeforeDeduction;
      final netHadir = tpp.attendanceNetPagu ?? pagu;
      final finalTakeHome = tpp.finalTakeHomePayRp ?? tpp.amountAfterDeduction;
      final ekpScore = tpp.skpScorePct != null ? (tpp.skpScorePct! / 100) : tpp.activityScore;

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
                        Icons.account_balance_wallet_rounded,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.s12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Statistik TPP',
                          style: typography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          period?.label ?? tpp.periodDate,
                          style: typography.caption.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                _EkpStatusBadge(
                  status: tpp.ekpStatus,
                  colors: colors,
                  typography: typography,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s16.h),

            // ── Mini bar chart ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _MiniBar(
                    label: 'Pagu',
                    value: pagu.toDouble(),
                    maxValue: pagu > 0 ? pagu.toDouble() : 1.0,
                    color: colors.primary,
                    typography: typography,
                  ),
                ),
                SizedBox(width: AppSpacing.s8.w),
                Expanded(
                  child: _MiniBar(
                    label: 'Net Hadir',
                    value: netHadir.toDouble(),
                    maxValue: pagu > 0 ? pagu.toDouble() : 1.0,
                    color: const Color(0xFF0891B2),
                    typography: typography,
                  ),
                ),
                SizedBox(width: AppSpacing.s8.w),
                Expanded(
                  child: _MiniBar(
                    label: 'Diterima',
                    value: finalTakeHome.toDouble(),
                    maxValue: pagu > 0 ? pagu.toDouble() : 1.0,
                    color: colors.success,
                    typography: typography,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s16.h),

            // ── Detail rows ───────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(AppSpacing.s12.w),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Pagu Jabatan',
                    value: _rupiah(pagu),
                    color: colors.onSurface,
                    typography: typography,
                  ),
                  SizedBox(height: AppSpacing.s8.h),
                  _DetailRow(
                    label: 'Pagu Net Kehadiran',
                    value: _rupiah(netHadir),
                    color: const Color(0xFF0891B2),
                    typography: typography,
                  ),
                  Divider(
                    height: AppSpacing.s16.h,
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                  _DetailRow(
                    label: 'Nilai TPP Diterima',
                    value: _rupiah(finalTakeHome),
                    color: colors.success,
                    bold: true,
                    typography: typography,
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.s12.h),

            // ── Score chips ───────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ScoreChip(
                    label: 'Disiplin',
                    score: tpp.disciplineScore,
                    colors: colors,
                    typography: typography,
                  ),
                ),
                SizedBox(width: AppSpacing.s8.w),
                Expanded(
                  child: _ScoreChip(
                    label: 'Skor EKP',
                    score: ekpScore,
                    subtitle: tpp.displayPredikat,
                    colors: colors,
                    typography: typography,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.s16.h),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Get.to(() => TppDailyDetailScreen(
                            tpp: tpp,
                            initialMonth: ctrl.selectedMonth.value,
                            initialYear: ctrl.selectedYear.value,
                          ));
                    },
                    icon: Icon(Icons.analytics_rounded, size: 18.w),
                    label: const Text('Rincian Lengkap'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colors.primary,
                      side: BorderSide(
                        color: colors.primary.withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s12.h),
                      textStyle: typography.labelMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.s8.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.to(
                        () => const ReportViewerPage(),
                        arguments: {
                          'reportType': ReportType.tpp,
                          'year': ctrl.selectedYear.value,
                          'month': ctrl.selectedMonth.value,
                        },
                      );
                    },
                    icon: Icon(Icons.picture_as_pdf_rounded, size: 18.w),
                    label: const Text('Laporan PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.r8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s12.h),
                      textStyle: typography.labelMedium
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }


  String _rupiah(int amount) {
    final formatted = amount.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m.group(1)}.',
    );
    return 'Rp $formatted';
  }
}

// ── Widgets pendukung ─────────────────────────────────────────────────────────

class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.typography,
  });

  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final fraction =
        maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.r4),
          child: LinearProgressIndicator(
            value: fraction,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
        SizedBox(height: AppSpacing.s4.h),
        Text(
          label,
          style: typography.caption
              .copyWith(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ScoreChip extends StatelessWidget {
  const _ScoreChip({
    required this.label,
    required this.score,
    this.subtitle,
    required this.colors,
    required this.typography,
  });

  final String label;
  final double score; // 0.0–1.0
  final String? subtitle;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).toStringAsFixed(0);
    final color = score >= 0.9
        ? colors.success
        : score >= 0.75
            ? colors.warning
            : colors.error;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s8.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(AppRadius.r8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              Text(
                '$pct%',
                style: typography.labelLarge.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (subtitle != null && subtitle!.isNotEmpty) ...[
            SizedBox(height: 2.h),
            Text(
              subtitle!,
              style: typography.caption.copyWith(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: subtitle == 'Belum Ada Penilaian'
                    ? colors.outline
                    : const Color(0xFF0D9488),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _EkpStatusBadge extends StatelessWidget {
  const _EkpStatusBadge({
    required this.status,
    required this.colors,
    required this.typography,
  });

  final String? status;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final s = status?.toLowerCase() ?? 'belum_upload';
    String text;
    Color color;

    switch (s) {
      case 'disetujui':
        text = 'EKP Disetujui';
        color = colors.success;
        break;
      case 'pending':
        text = 'EKP Menunggu';
        color = colors.warning;
        break;
      case 'ditolak':
        text = 'EKP Ditolak';
        color = colors.error;
        break;
      default:
        text = 'Belum Ada EKP';
        color = colors.outline;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.r4),
        border: Border.all(color: color.withValues(alpha: 0.3)),
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
}

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
              .copyWith(color: color.withValues(alpha: 0.6)),
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

class _EmptySection extends StatelessWidget {
  const _EmptySection({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.typography,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: colors.outline.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          child: Icon(icon, color: colors.outline, size: 20),
        ),
        SizedBox(width: AppSpacing.s12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: typography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
