import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../design_system/components/app_button.dart';
import '../../../../../design_system/components/app_feedback.dart';
import '../../../../../design_system/components/app_image_viewer.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_radius.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import '../../../data/models/subordinate_activity_item.dart';
import '../../controllers/kinerja_bawahan_controller.dart';
import 'reject_reason_dialog.dart';

/// Bottom sheet yang menampilkan detail lengkap kinerja bawahan untuk atasan.
/// Menampilkan Info Pegawai, Judul, Output, Lokasi, Deskripsi, Jam/Tanggal,
/// Lampiran, Status E-Kinerja BKN, serta aksi Setujui / Tolak.
class KinerjaBawahanDetailSheet extends StatelessWidget {
  final SubordinateActivityItem item;

  const KinerjaBawahanDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final attachmentUrl = item.attachmentUrl != null
        ? AppConstants.sanitizeImageUrl(item.attachmentUrl!)
        : (item.attachments.isNotEmpty ? item.attachments.first.url : null);
    final hasAttachment = item.hasAttachment;
    final isPdf = item.isPdf;

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
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
            SizedBox(height: AppSpacing.s16.h),

            // ── Pegawai Info & Status Chip ──────────────────
            Row(
              children: [
                CircleAvatar(
                  radius: 22.r,
                  backgroundColor: colors.primaryContainer,
                  child: Text(
                    item.subordinateAvatar,
                    style: typography.titleSmall.copyWith(
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
                        style: typography.titleSmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'NIP. ${item.subordinateNip}',
                        style: typography.caption.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (item.institutionName != null || item.departmentName != null) ...[
                        SizedBox(height: AppSpacing.s2.h),
                        Text(
                          item.institutionName ?? item.departmentName ?? '',
                          style: typography.caption.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusChip(colors, typography),
              ],
            ),
            SizedBox(height: AppSpacing.s16.h),
            Divider(color: colors.outline.withValues(alpha: 0.15)),
            SizedBox(height: AppSpacing.s12.h),

            // ── Judul Kegiatan ──────────────────────────────
            Text(
              item.displayTitle,
              style: typography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.s12.h),

            // ── Tanggal, Jam & Jenis Kegiatan ───────────────
            Container(
              padding: EdgeInsets.all(AppSpacing.s12.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r8),
                border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 16, color: colors.primary),
                      SizedBox(width: AppSpacing.s8.w),
                      Expanded(
                        child: Text(
                          _formatDate(item.date),
                          style: typography.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (item.startTime != null && item.endTime != null) ...[
                        Icon(Icons.access_time_rounded, size: 16, color: colors.primary),
                        SizedBox(width: AppSpacing.s4.w),
                        Text(
                          '${item.startTime} - ${item.endTime}',
                          style: typography.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.s8.h),
                  Row(
                    children: [
                      Icon(_getTypeIcon(item.typeId), size: 16, color: colors.primary),
                      SizedBox(width: AppSpacing.s8.w),
                      Text(
                        'Jenis: ',
                        style: typography.caption.copyWith(color: colors.onSurface.withValues(alpha: 0.5)),
                      ),
                      Text(
                        item.typeName.isNotEmpty ? item.typeName : 'Kegiatan',
                        style: typography.bodySmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.s16.h),

            // ── Output / Hasil ──────────────────────────────
            _buildSectionLabel('Output / Hasil', colors, typography),
            SizedBox(height: AppSpacing.s4.h),
            Text(
              item.output != null && item.output!.isNotEmpty ? item.output! : '—',
              style: typography.bodyMedium.copyWith(
                color: item.output != null ? colors.primary : colors.onSurface.withValues(alpha: 0.5),
                fontWeight: item.output != null ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
            SizedBox(height: AppSpacing.s16.h),

            // ── Lokasi ──────────────────────────────────────
            if (item.locationText != null && item.locationText!.isNotEmpty) ...[
              _buildSectionLabel('Lokasi', colors, typography),
              SizedBox(height: AppSpacing.s4.h),
              Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 16, color: colors.error),
                  SizedBox(width: AppSpacing.s8.w),
                  Expanded(
                    child: Text(
                      item.locationText!,
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s16.h),
            ],

            // ── Deskripsi Kegiatan ──────────────────────────
            _buildSectionLabel('Deskripsi Kegiatan', colors, typography),
            SizedBox(height: AppSpacing.s4.h),
            Text(
              item.description.isNotEmpty ? item.description : '—',
              style: typography.bodyMedium.copyWith(
                color: colors.onSurface,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpacing.s16.h),

            // ── Lampiran ────────────────────────────────────
            if (hasAttachment && attachmentUrl != null) ...[
              _buildSectionLabel('Lampiran Bukti', colors, typography),
              SizedBox(height: AppSpacing.s8.h),
              if (isPdf)
                Container(
                  padding: EdgeInsets.all(AppSpacing.s12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_rounded, color: colors.error, size: 30),
                      SizedBox(width: AppSpacing.s12.w),
                      Expanded(
                        child: Text(
                          item.attachments.isNotEmpty
                              ? item.attachments.first.fileName
                              : 'Dokumen Lampiran.pdf',
                          style: typography.bodyMedium.copyWith(color: colors.onSurface),
                        ),
                      ),
                      AppButton(
                        label: 'Buka',
                        style: AppButtonStyle.outlined,
                        onPressed: () => _openUrl(attachmentUrl),
                      ),
                    ],
                  ),
                )
              else
                GestureDetector(
                  onTap: () => AppImageViewer.show(
                    context,
                    imageUrl: attachmentUrl,
                    heroTag: 'bawahan_img_${item.id}',
                  ),
                  child: Hero(
                    tag: 'bawahan_img_${item.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                      child: Stack(
                        children: [
                          attachmentUrl.startsWith('http')
                              ? Image.network(
                                  attachmentUrl,
                                  width: double.infinity,
                                  height: 180.h,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (_, child, progress) =>
                                      progress == null
                                          ? child
                                          : SizedBox(
                                              height: 180.h,
                                              child: const Center(
                                                  child: CircularProgressIndicator()),
                                            ),
                                  errorBuilder: (_, _, _) => _buildErrorImage(colors),
                                )
                              : Image.file(
                                  File(attachmentUrl),
                                  width: double.infinity,
                                  height: 180.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => _buildErrorImage(colors),
                                ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.zoom_in_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              SizedBox(height: AppSpacing.s16.h),
            ],

            // ── Status Sinkronisasi E-Kinerja (BKN) ──────────
            if (item.ekinerjaSyncStatus != null) ...[
              _buildEkinerjaSyncCard(colors, typography),
              SizedBox(height: AppSpacing.s16.h),
            ],

            // ── Alasan Penolakan ────────────────────────────
            if (item.status == ActivityStatus.rejected && item.rejectReason != null) ...[
              Container(
                width: double.infinity,
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
              SizedBox(height: AppSpacing.s16.h),
            ],

            // ── Actions ────────────────────────────────────
            if (item.status == ActivityStatus.pending) ...[
              SizedBox(height: AppSpacing.s12.h),
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
              SizedBox(height: AppSpacing.s12.h),
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

  Widget _buildSectionLabel(String title, AppColors colors, AppTypography typography) {
    return Text(
      title,
      style: typography.labelMedium.copyWith(
        color: colors.onSurface.withValues(alpha: 0.5),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildEkinerjaSyncCard(AppColors colors, AppTypography typography) {
    Color badgeBg;
    Color badgeFg;
    String statusLabel;

    switch (item.ekinerjaSyncStatus?.toLowerCase()) {
      case 'synced':
        badgeBg = colors.success.withValues(alpha: 0.15);
        badgeFg = colors.success;
        statusLabel = 'Tersinkron';
        break;
      case 'failed':
        badgeBg = colors.error.withValues(alpha: 0.15);
        badgeFg = colors.error;
        statusLabel = 'Gagal';
        break;
      default:
        badgeBg = colors.warning.withValues(alpha: 0.15);
        badgeFg = colors.warning;
        statusLabel = 'Menunggu';
        break;
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.s12.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r8),
        border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sync_rounded, size: 16, color: colors.primary),
              SizedBox(width: AppSpacing.s8.w),
              Text(
                'Status Sinkronisasi E-Kinerja BKN',
                style: typography.labelMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8.w, vertical: AppSpacing.s2.h),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                ),
                child: Text(
                  statusLabel,
                  style: typography.caption.copyWith(
                    color: badgeFg,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (item.ekinerjaSyncAction != null && item.ekinerjaSyncAction!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.s8.h),
            Text(
              'Aksi: ${item.ekinerjaSyncAction!.toUpperCase()}',
              style: typography.caption.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          if (item.ekinerjaSyncedAt != null) ...[
            SizedBox(height: AppSpacing.s2.h),
            Text(
              'Waktu Sync: ${_formatDateTime(item.ekinerjaSyncedAt!)}',
              style: typography.caption.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          if (item.ekinerjaSyncError != null && item.ekinerjaSyncError!.isNotEmpty) ...[
            SizedBox(height: AppSpacing.s8.h),
            Container(
              padding: EdgeInsets.all(AppSpacing.s8.w),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.r4),
              ),
              child: Text(
                item.ekinerjaSyncError!,
                style: typography.caption.copyWith(
                  color: colors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(AppColors colors, AppTypography typography) {
    Color bg;
    Color fg;
    String label;

    switch (item.status) {
      case ActivityStatus.pending:
        bg = colors.warning.withValues(alpha: 0.15);
        fg = colors.warning;
        label = 'Pending';
        break;
      case ActivityStatus.approved:
        bg = colors.success.withValues(alpha: 0.15);
        fg = colors.success;
        label = 'Disetujui';
        break;
      case ActivityStatus.rejected:
        bg = colors.error.withValues(alpha: 0.15);
        fg = colors.error;
        label = 'Ditolak';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8.w, vertical: AppSpacing.s4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(color: fg, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildErrorImage(AppColors colors) {
    return Container(
      width: double.infinity,
      height: 180.h,
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
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Tidak dapat membuka file lampiran',
        type: FeedbackType.error,
      );
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

    if (result == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  IconData _getTypeIcon(String typeId) {
    switch (typeId) {
      case 'kedinasan':
        return Icons.work_history_rounded;
      case 'bimtek':
        return Icons.school_rounded;
      case 'rakor':
        return Icons.groups_rounded;
      case 'pelayanan':
        return Icons.handshake_rounded;
      default:
        return Icons.assignment_rounded;
    }
  }

  String _formatDate(DateTime d) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatDateTime(DateTime d) {
    final date =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    final time =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}
