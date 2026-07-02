import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../design_system/components/app_avatar_badge.dart';
import '../../../../../design_system/components/app_card.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import '../../../data/models/submission_type.dart';

class SubmissionTypeInfoCard extends StatelessWidget {
  final SubmissionType type;

  const SubmissionTypeInfoCard({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 14, color: colors.primary),
              SizedBox(width: AppSpacing.s4.w),
              Text(
                'Informasi Jenis Pengajuan',
                style: typography.labelSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Divider(height: AppSpacing.s16.h, color: colors.outline.withValues(alpha: 0.2)),
          Row(
            children: [
              Icon(type.icon, size: 18, color: colors.primary),
              SizedBox(width: AppSpacing.s8.w),
              Text(
                type.name,
                style: typography.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s8.h),
          Text(
            type.description ?? '',
            style: typography.bodySmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: AppSpacing.s12.h),
          _InfoRow(
            icon: Icons.account_balance_wallet_outlined,
            label: 'Memotong saldo cuti',
            value: type.deductsLeaveBalance ? 'Ya' : 'Tidak',
            valueColor: type.deductsLeaveBalance ? colors.warning : colors.success,
            colors: colors,
            typography: typography,
          ),
          SizedBox(height: AppSpacing.s8.h),
          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'Maksimal hari pengajuan',
            value: '${type.maxDaysPerRequest} hari',
            valueColor: colors.onSurface,
            colors: colors,
            typography: typography,
          ),
          SizedBox(height: AppSpacing.s12.h),
          Text(
            'Disetujui oleh',
            style: typography.labelSmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: AppSpacing.s8.h),
          Row(
            children: [
              AppAvatar(
                initials: _initials(type.approverName ?? '-'),
                size: 36,
              ),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.approverName ?? '-',
                      style: typography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                    Text(
                      type.approverPosition ?? '-',
                      style: typography.labelSmall.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim().split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final AppColors colors;
  final AppTypography typography;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: colors.onSurface.withValues(alpha: 0.5)),
        SizedBox(width: AppSpacing.s4.w),
        Text(
          '$label: ',
          style: typography.bodySmall.copyWith(
            color: colors.onSurface.withValues(alpha: 0.6),
          ),
        ),
        Text(
          value,
          style: typography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
