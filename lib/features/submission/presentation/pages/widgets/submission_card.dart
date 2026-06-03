import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../design_system/components/app_card.dart';
import '../../../../../design_system/components/feedback/app_dialog.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import '../../../data/models/submission_item.dart';

class SubmissionCard extends StatelessWidget {
  final SubmissionItem item;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const SubmissionCard({
    super.key,
    required this.item,
    required this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
      child: AppCard(
        outlined: true,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: typography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.s4.h),
                  Text(
                    item.description,
                    style: typography.bodySmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.s8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 12,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                      SizedBox(width: AppSpacing.s4.w),
                      Text(
                        item.formattedDate,
                        style: typography.labelSmall.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      SizedBox(width: AppSpacing.s8.w),
                      _StatusBadge(status: item.status),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                color: colors.error,
                size: 20,
              ),
              onPressed: () async {
                final confirmed = await AppDialog.confirm(
                  title: 'Hapus Pengajuan',
                  message: 'Yakin ingin menghapus pengajuan "${item.title}"?',
                  confirmLabel: 'Hapus',
                  cancelLabel: 'Batal',
                  isDestructive: true,
                );
                if (confirmed == true) onDelete();
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Hapus',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SubmissionStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    final (bgColor, textColor) = switch (status) {
      SubmissionStatus.draft => (
          colors.primary.withValues(alpha: 0.15),
          colors.primary,
        ),
      SubmissionStatus.pending => (
          colors.warning.withValues(alpha: 0.15),
          colors.warning,
        ),
      SubmissionStatus.approved => (
          colors.success.withValues(alpha: 0.15),
          colors.success,
        ),
      SubmissionStatus.rejected => (
          colors.error.withValues(alpha: 0.15),
          colors.error,
        ),
      SubmissionStatus.cancelled => (
          colors.onSurface.withValues(alpha: 0.15),
          colors.onSurface.withValues(alpha: 0.7),
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        status.label,
        style: typography.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
