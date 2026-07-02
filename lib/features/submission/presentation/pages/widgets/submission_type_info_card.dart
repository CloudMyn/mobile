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
              Expanded(
                child: Text(
                  type.name,
                  style: typography.titleSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
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
          if (type.defaultYearlyQuota > 0) ...[
            SizedBox(height: AppSpacing.s8.h),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Kuota tahunan',
              value: '${type.defaultYearlyQuota.toInt()} hari',
              valueColor: colors.onSurface,
              colors: colors,
              typography: typography,
            ),
            SizedBox(height: AppSpacing.s8.h),
            _InfoRow(
              icon: Icons.next_plan_outlined,
              label: 'Akumulasi sisa kuota',
              value: type.allowCarryForward
                  ? 'Ya (maks ${type.maxCarryForwardDays?.toInt() ?? 0} hari)'
                  : 'Tidak',
              valueColor: colors.onSurface,
              colors: colors,
              typography: typography,
            ),
          ],
          SizedBox(height: AppSpacing.s8.h),
          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'Maksimal hari pengajuan',
            value: type.maxDaysPerRequest != null && type.maxDaysPerRequest! > 0
                ? '${type.maxDaysPerRequest} hari'
                : 'Tidak dibatasi',
            valueColor: colors.onSurface,
            colors: colors,
            typography: typography,
          ),
          SizedBox(height: AppSpacing.s8.h),
          _InfoRow(
            icon: Icons.edit_note_rounded,
            label: 'Informasi wajib diisi',
            value: [
              if (type.requiresDateRange) 'Rentang Tanggal',
              if (type.requiresTimeRange) 'Rentang Waktu',
              if (!type.requiresDateRange && !type.requiresTimeRange) 'Satu Hari',
            ].join(' & '),
            valueColor: colors.onSurface,
            colors: colors,
            typography: typography,
          ),
          if (type.attachmentFields.isNotEmpty) ...[
            Divider(height: AppSpacing.s24.h, color: colors.outline.withValues(alpha: 0.2)),
            Row(
              children: [
                Icon(Icons.file_present_rounded, size: 14, color: colors.primary),
                SizedBox(width: AppSpacing.s4.w),
                Text(
                  'Dokumen Pendukung Wajib',
                  style: typography.labelSmall.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s8.h),
            ...type.attachmentFields.map((doc) {
              final sizeMb = (doc.maxFileSizeKb ?? 0) / 1024;
              final sizeText = sizeMb >= 1
                  ? '${sizeMb.toStringAsFixed(sizeMb == sizeMb.toInt() ? 0 : 1)} MB'
                  : '${doc.maxFileSizeKb} KB';
              final extensions = doc.allowedExtensions.map((e) => e.toUpperCase()).join(', ');

              return Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
                child: Container(
                  padding: EdgeInsets.all(AppSpacing.s10.w),
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description_outlined, size: 16, color: colors.primary),
                          SizedBox(width: AppSpacing.s4.w),
                          Expanded(
                            child: Text(
                              doc.name,
                              style: typography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ),
                          if (doc.isRequired)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s4.w, vertical: AppSpacing.s2.h),
                              decoration: BoxDecoration(
                                color: colors.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'Wajib',
                                style: typography.labelSmall.copyWith(
                                  color: colors.error,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (doc.description != null && doc.description!.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.s4.h),
                        Text(
                          doc.description!,
                          style: typography.labelSmall.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                      SizedBox(height: AppSpacing.s4.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Format: $extensions',
                            style: typography.labelSmall.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.5),
                              fontSize: 10.sp,
                            ),
                          ),
                          Text(
                            'Maks: $sizeText',
                            style: typography.labelSmall.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.5),
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
          Divider(height: AppSpacing.s24.h, color: colors.outline.withValues(alpha: 0.2)),
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
        Expanded(
          child: RichText(
            text: TextSpan(
              style: typography.bodySmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
              children: [
                TextSpan(text: '$label: '),
                TextSpan(
                  text: value,
                  style: typography.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
