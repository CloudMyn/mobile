import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/statistik_controller.dart';
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
                Icon(
                  Icons.trending_up_rounded,
                  color: colors.success,
                  size: 20,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s16.h),

            // ── Mini bar chart ────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _MiniBar(
                    label: 'Besaran',
                    value: tpp.amountBeforeDeduction.toDouble(),
                    maxValue: tpp.amountBeforeDeduction.toDouble(),
                    color: colors.primary,
                    typography: typography,
                  ),
                ),
                SizedBox(width: AppSpacing.s8.w),
                Expanded(
                  child: _MiniBar(
                    label: 'Potongan',
                    value: tpp.deductionAmount.toDouble(),
                    maxValue: tpp.amountBeforeDeduction.toDouble(),
                    color: colors.warning,
                    typography: typography,
                  ),
                ),
                SizedBox(width: AppSpacing.s8.w),
                Expanded(
                  child: _MiniBar(
                    label: 'Hasil',
                    value: tpp.amountAfterDeduction.toDouble(),
                    maxValue: tpp.amountBeforeDeduction.toDouble(),
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
                    label: 'Jumlah Besaran',
                    value: _rupiah(tpp.amountBeforeDeduction),
                    color: colors.onSurface,
                    typography: typography,
                  ),
                  SizedBox(height: AppSpacing.s8.h),
                  _DetailRow(
                    label: 'Potongan',
                    value: _rupiah(tpp.deductionAmount),
                    color: colors.warning,
                    typography: typography,
                  ),
                  Divider(
                    height: AppSpacing.s16.h,
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                  _DetailRow(
                    label: 'Hasil Potongan',
                    value: _rupiah(tpp.amountAfterDeduction),
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
                    label: 'Aktivitas',
                    score: tpp.activityScore,
                    colors: colors,
                    typography: typography,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpacing.s16.h),
            
            // ── Tombol Detail Harian ───────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.to(() => TppDailyDetailScreen(tpp: tpp));
                },
                icon: Icon(Icons.calendar_month_rounded, size: 20.w),
                label: const Text('Detail Potongan Harian'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colors.primary,
                  side: BorderSide(color: colors.primary.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.s12.h),
                  textStyle: typography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
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
    required this.colors,
    required this.typography,
  });

  final String label;
  final double score; // 0.0–1.0
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
      child: Row(
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
