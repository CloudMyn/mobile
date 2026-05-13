import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/home_controller.dart';

class TppStatCard extends StatelessWidget {
  const TppStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(
      () {
        final tpp = controller.tppStatistic.value;
        if (tpp == null) return const SizedBox.shrink();

        return AppCard(
          outlined: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
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
                            tpp.period,
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

              // Visual mini bar chart untuk proporsi
              Row(
                children: [
                  // Total Amount bar
                  Expanded(
                    child: _buildMiniBar(
                      label: 'Besar',
                      value: tpp.totalAmount,
                      maxValue: tpp.totalAmount,
                      color: colors.primary,
                      typography: typography,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  // Deduction bar
                  Expanded(
                    child: _buildMiniBar(
                      label: 'Potong',
                      value: tpp.totalDeduction,
                      maxValue: tpp.totalAmount,
                      color: colors.warning,
                      typography: typography,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  // Net result bar
                  Expanded(
                    child: _buildMiniBar(
                      label: 'Hasil',
                      value: tpp.netResult,
                      maxValue: tpp.totalAmount,
                      color: colors.success,
                      typography: typography,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s16.h),

              // Detail rows
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
                      value: _formatRupiah(tpp.totalAmount),
                      color: colors.onSurface,
                      typography: typography,
                    ),
                    SizedBox(height: AppSpacing.s8.h),
                    _DetailRow(
                      label: 'Potongan',
                      value: _formatRupiah(tpp.totalDeduction),
                      color: colors.warning,
                      typography: typography,
                    ),
                    Divider(
                      height: AppSpacing.s16.h,
                      color: colors.outline.withValues(alpha: 0.15),
                    ),
                    _DetailRow(
                      label: 'Hasil Potongan',
                      value: _formatRupiah(tpp.netResult),
                      color: colors.success,
                      bold: true,
                      typography: typography,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniBar({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
    required AppTypography typography,
  }) {
    final fraction = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;

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
          style: typography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatRupiah(double amount) {
    final rounded = amount.round();
    final formatted = rounded.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1)}.',
    );
    return 'Rp $formatted';
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool bold;
  final AppTypography typography;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.color,
    this.bold = false,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: typography.bodySmall.copyWith(
            color: color.withValues(alpha: 0.6),
          ),
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
