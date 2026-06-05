import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../design_system/components/app_button.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_radius.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import '../../../data/models/subordinate_activity_item.dart';
import '../../controllers/kinerja_bawahan_controller.dart';
import 'reject_reason_dialog.dart';

class KinerjaBawahanDetailSheet extends StatelessWidget {
  final SubordinateActivityItem item;

  const KinerjaBawahanDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return DraggableScrollableSheet(
      initialChildSize: item.hasAttachment && !item.isPdf ? 0.8 : 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollCtrl) => SingleChildScrollView(
        controller: scrollCtrl,
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s20.w,
          AppSpacing.s12.h,
          AppSpacing.s20.w,
          AppSpacing.s32.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Drag Handle ─────────────────────────────────
            Center(
              child: Container(
                width: 40.w,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.s24.h),

            // ── Pegawai Info ────────────────────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    item.subordinateAvatar,
                    style: typography.titleMedium.copyWith(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.s12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.subordinateName,
                        style: typography.titleMedium.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        item.subordinateNip,
                        style: typography.bodyMedium.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s16.h),
            Divider(color: colors.outline.withValues(alpha: 0.2)),
            SizedBox(height: AppSpacing.s16.h),

            // ── Type + Date ────────────────────────────────
            Row(
              children: [
                Icon(
                  _getTypeIcon(item.typeId),
                  size: 20,
                  color: colors.primary,
                ),
                SizedBox(width: AppSpacing.s8.w),
                Text(
                  item.typeName,
                  style: typography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: colors.onSurface.withValues(alpha: 0.4),
                ),
                SizedBox(width: AppSpacing.s4.w),
                Text(
                  _formatDate(item.date),
                  style: typography.caption.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s16.h),

            // ── Description ────────────────────────────────
            Text(
              'Deskripsi Kegiatan',
              style: typography.labelMedium.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
            SizedBox(height: AppSpacing.s4.h),
            Text(
              item.description,
              style: typography.bodyMedium.copyWith(
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.s16.h),

            // ── Attachment ─────────────────────────────────
            if (item.hasAttachment) ...[
              Text(
                'Lampiran',
                style: typography.labelMedium.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(height: AppSpacing.s8.h),
              if (item.isPdf)
                Container(
                  padding: EdgeInsets.all(AppSpacing.s12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_rounded, color: colors.error, size: 32),
                      SizedBox(width: AppSpacing.s12.w),
                      Expanded(
                        child: Text(
                          'Dokumen Lampiran.pdf',
                          style: typography.bodyMedium.copyWith(color: colors.onSurface),
                        ),
                      ),
                      AppButton(
                        label: 'Buka',
                        style: AppButtonStyle.outlined,
                        onPressed: () => _openUrl(item.attachmentUrl!),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: () {
                    // In real app, might want to navigate to a full screen image viewer
                    // Or show a dialog with InteractiveViewer
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                    child: item.attachmentUrl!.startsWith('http') 
                        ? Image.network(
                            item.attachmentUrl!,
                            width: double.infinity,
                            height: 200.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildErrorImage(colors),
                          )
                        : Image.file(
                            File(item.attachmentUrl!),
                            width: double.infinity,
                            height: 200.h,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildErrorImage(colors),
                          ),
                  ),
                ),
              SizedBox(height: AppSpacing.s16.h),
            ],

            // ── Status & Reason ────────────────────────────
            if (item.status == ActivityStatus.rejected && item.rejectReason != null) ...[
              Container(
                padding: EdgeInsets.all(AppSpacing.s12.w),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  border: Border.all(color: colors.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline_rounded, color: colors.error, size: 16),
                        SizedBox(width: AppSpacing.s8.w),
                        Text(
                          'Alasan Penolakan',
                          style: typography.labelMedium.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.s8.h),
                    Text(
                      item.rejectReason!,
                      style: typography.bodyMedium.copyWith(color: colors.onSurface),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.s24.h),
            ],

            // ── Actions ────────────────────────────────────
            if (item.status == ActivityStatus.pending) ...[
              SizedBox(height: AppSpacing.s16.h),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Tolak',
                      onPressed: () => _handleReject(context),
                      style: AppButtonStyle.outlined,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s12.w),
                  Expanded(
                    child: AppButton(
                      label: 'Setujui',
                      onPressed: () => _handleApprove(context),
                      style: AppButtonStyle.filled,
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(height: AppSpacing.s16.h),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Tutup',
                  onPressed: () => Navigator.of(context).pop(),
                  style: AppButtonStyle.outlined,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorImage(AppColors colors) {
    return Container(
      width: double.infinity,
      height: 200.h,
      color: colors.surface,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: colors.outline,
          size: 40,
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar('Error', 'Tidak dapat membuka file lampiran', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _handleApprove(BuildContext context) {
    Get.find<KinerjaBawahanController>().approveActivity(item.id);
    Navigator.of(context).pop();
  }

  void _handleReject(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => RejectReasonDialog(activityId: item.id),
    );
    
    // If successfully rejected (returned true), close the sheet too
    if (result == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  IconData _getTypeIcon(String typeId) {
    switch (typeId) {
      case 'kedinasan': return Icons.work_history_rounded;
      case 'bimtek': return Icons.school_rounded;
      case 'rakor': return Icons.groups_rounded;
      case 'pelayanan': return Icons.handshake_rounded;
      default: return Icons.assignment_rounded;
    }
  }

  String _formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
