import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/leave_quota.dart';
import '../controllers/home_controller.dart';

class CutiStatCard extends StatelessWidget {
  const CutiStatCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(() {
      final quota = controller.leaveQuota.value;
      if (quota == null) return const SizedBox.shrink();

      final remainColor = quota.remaining <= 3
          ? colors.error
          : quota.remaining <= 6
              ? colors.warning
              : colors.success;

      return AppCard(
        outlined: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
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
                          'Kuota Cuti',
                          style: typography.titleSmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tahun ${quota.year}',
                          style: typography.caption.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Sisa kuota badge
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
                    '${quota.remaining} hari tersisa',
                    style: typography.caption.copyWith(
                      color: remainColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.s16.h),

            // ── Progress bar ─────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${quota.usedThisYear} terpakai dari ${quota.totalAvailable} hari tersedia',
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  '${(quota.usedPercentage * 100).toStringAsFixed(0)}%',
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
                value: quota.usedPercentage,
                backgroundColor: colors.outline.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation<Color>(remainColor),
                minHeight: 6.h,
              ),
            ),

            SizedBox(height: AppSpacing.s16.h),

            // ── Detail rows ──────────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(AppSpacing.s12.w),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(AppRadius.r8),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: 'Kuota Tahun ${quota.year}',
                    value: '${quota.yearlyQuota} hari',
                    color: colors.onSurface,
                    typography: typography,
                  ),
                  SizedBox(height: AppSpacing.s8.h),
                  _DetailRow(
                    label: 'Sisa Tahun ${int.parse(quota.year) - 1}',
                    value: quota.prevYearRemaining > 0
                        ? '+${quota.prevYearRemaining} hari'
                        : '0 hari',
                    valueNote: quota.prevYearRemaining > 0
                        ? '(dari ${quota.prevYearQuota} hari)'
                        : null,
                    color: quota.prevYearRemaining > 0
                        ? colors.primary
                        : colors.outline,
                    typography: typography,
                  ),
                  Divider(
                    height: AppSpacing.s16.h,
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                  _DetailRow(
                    label: 'Total Tersedia',
                    value: '${quota.totalAvailable} hari',
                    color: colors.onSurface,
                    bold: true,
                    typography: typography,
                  ),
                  SizedBox(height: AppSpacing.s8.h),
                  _DetailRow(
                    label: 'Sudah Terpakai',
                    value: '${quota.usedThisYear} hari',
                    color: colors.warning,
                    typography: typography,
                  ),
                  Divider(
                    height: AppSpacing.s16.h,
                    color: colors.outline.withValues(alpha: 0.15),
                  ),
                  _DetailRow(
                    label: 'Sisa Kuota',
                    value: '${quota.remaining} hari',
                    color: remainColor,
                    bold: true,
                    typography: typography,
                  ),
                ],
              ),
            ),

            // ── Rincian penggunaan ───────────────────────────────────────────
            if (quota.recentUsages.isNotEmpty) ...[
              SizedBox(height: AppSpacing.s16.h),
              Text(
                'Riwayat Penggunaan',
                style: typography.labelLarge.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.s8.h),
              ...quota.recentUsages.map(
                (u) => _UsageRow(usage: u, colors: colors, typography: typography),
              ),
            ],
          ],
        ),
      );
    });
  }
}

// ── Detail row ────────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final String? valueNote;
  final Color color;
  final bool bold;
  final AppTypography typography;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueNote,
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
            color: color.withValues(alpha: 0.65),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: typography.bodyMedium.copyWith(
                color: color,
                fontWeight: bold ? FontWeight.bold : FontWeight.w600,
              ),
            ),
            if (valueNote != null) ...[
              SizedBox(width: 4.w),
              Text(
                valueNote!,
                style: typography.caption.copyWith(
                  color: color.withValues(alpha: 0.5),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Usage row ─────────────────────────────────────────────────────────────────

class _UsageRow extends StatelessWidget {
  final LeaveUsage usage;
  final AppColors colors;
  final AppTypography typography;

  const _UsageRow({
    required this.usage,
    required this.colors,
    required this.typography,
  });

  Color get _statusColor {
    return switch (usage.status) {
      'approved' => colors.success,
      'pending' => colors.warning,
      _ => colors.error,
    };
  }

  String get _statusLabel {
    return switch (usage.status) {
      'approved' => 'Disetujui',
      'pending' => 'Menunggu',
      _ => 'Ditolak',
    };
  }

  String _fmt(DateTime d) {
    const m = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${m[d.month]}';
  }

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
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.r8),
            ),
            child: Icon(
              Icons.event_available_rounded,
              color: _statusColor,
              size: 18,
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  usage.type,
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_fmt(usage.startDate)} – ${_fmt(usage.endDate)}',
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
                '${usage.days} hari',
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
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                ),
                child: Text(
                  _statusLabel,
                  style: typography.caption.copyWith(
                    color: _statusColor,
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
}
