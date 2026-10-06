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
import '../../../data/models/activity_item.dart';
import '../../controllers/kinerja_controller.dart';
import '../kinerja_create_page.dart';

/// Bottom sheet yang menampilkan detail lengkap item kinerja pegawai.
/// Menampilkan Judul, Output, Lokasi, Deskripsi, Tanggal/Waktu, Lampiran,
/// dan status sinkronisasi E-Kinerja BKN.
class KinerjaItemDetailSheet extends StatelessWidget {
  final ActivityItem item;

  const KinerjaItemDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final imageUrl = item.imageUrl != null ? AppConstants.sanitizeImageUrl(item.imageUrl!) : null;
    final hasImage = imageUrl != null;
    final isPdf = item.attachments.any((a) => a.isPdf) || (item.imageUrl?.toLowerCase().endsWith('.pdf') ?? false);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.35,
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

            // ── Header: Type Tag & Status Chip ──────────────
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.s8.w, vertical: AppSpacing.s4.h),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(AppRadius.r8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTypeIcon(item.typeId),
                        size: 15,
                        color: colors.primary,
                      ),
                      SizedBox(width: AppSpacing.s4.w),
                      Text(
                        item.typeName.isNotEmpty ? item.typeName : 'Kinerja',
                        style: typography.caption.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (item.status != null) _buildStatusChip(item.status!, colors, typography),
              ],
            ),
            SizedBox(height: AppSpacing.s12.h),

            // ── Status Banner (Draft / Pending / Ditolak) ──
            if (item.isDraft) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.s12.w),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit_note_rounded, color: colors.primary, size: 20),
                    SizedBox(width: AppSpacing.s8.w),
                    Expanded(
                      child: Text(
                        'Kinerja ini masih berupa Draft. Ajukan agar dapat ditinjau dan disetujui oleh atasan.',
                        style: typography.bodySmall.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.s12.h),
            ] else if (item.isPending) ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpacing.s12.w),
                decoration: BoxDecoration(
                  color: colors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top_rounded, color: colors.warning, size: 20),
                    SizedBox(width: AppSpacing.s8.w),
                    Expanded(
                      child: Text(
                        'Kinerja berstatus Pending dan sedang menunggu persetujuan dari atasan.',
                        style: typography.bodySmall.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.s12.h),
            ] else if (item.isRejected) ...[
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
                        Icon(Icons.cancel_rounded, color: colors.error, size: 20),
                        SizedBox(width: AppSpacing.s8.w),
                        Text(
                          'Kinerja Ditolak',
                          style: typography.labelMedium.copyWith(
                            color: colors.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (item.rejectReason != null && item.rejectReason!.isNotEmpty) ...[
                      SizedBox(height: AppSpacing.s4.h),
                      Text(
                        'Alasan: ${item.rejectReason}',
                        style: typography.bodySmall.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.s12.h),
            ],

            // ── Judul Kegiatan ──────────────────────────────
            Text(
              item.displayTitle,
              style: typography.titleMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.s12.h),

            // ── Tanggal & Jam Kegiatan ──────────────────────
            Container(
              padding: EdgeInsets.all(AppSpacing.s12.w),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(AppRadius.r8),
                border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
              ),
              child: Row(
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
            if (item.hasAttachment) ...[
              _buildSectionLabel('Lampiran', colors, typography),
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
                        onPressed: () => _openUrl(imageUrl ?? item.attachments.first.url),
                      ),
                    ],
                  ),
                )
              else if (hasImage)
                GestureDetector(
                  onTap: () => AppImageViewer.show(
                    context,
                    imageUrl: imageUrl,
                    heroTag: 'kinerja_img_${item.id}',
                  ),
                  child: Hero(
                    tag: 'kinerja_img_${item.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                      child: Stack(
                        children: [
                          imageUrl.startsWith('http')
                              ? Image.network(
                                  imageUrl,
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
                                  errorBuilder: (_, _, _) => SizedBox(
                                    height: 180.h,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: colors.outline,
                                        size: 40,
                                      ),
                                    ),
                                  ),
                                )
                              : Image.file(
                                  File(imageUrl),
                                  width: double.infinity,
                                  height: 180.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => SizedBox(
                                    height: 180.h,
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image_outlined,
                                        color: colors.outline,
                                        size: 40,
                                      ),
                                    ),
                                  ),
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

            // ── E-Kinerja Sync Status (BKN) ─────────────────
            if (item.ekinerjaSyncStatus != null) ...[
              _buildEkinerjaSyncCard(colors, typography),
              SizedBox(height: AppSpacing.s16.h),
            ],

            // ── Created At ──────────────────────────────────
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: colors.onSurface.withValues(alpha: 0.4),
                ),
                SizedBox(width: AppSpacing.s4.w),
                Text(
                  'Dibuat ${_formatDateTime(item.createdAt)}',
                  style: typography.caption.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s24.h),

            // ── Action Buttons ──────────────────────────────
            if (item.isDraft) ...[
              AppButton(
                label: 'Ajukan Kinerja',
                fullWidth: true,
                icon: Icons.send_rounded,
                onPressed: () => _confirmSubmit(context, item.id),
              ),
              SizedBox(height: AppSpacing.s12.h),
            ],

            Row(
              children: [
                if (item.isDraft) ...[
                  Expanded(
                    child: AppButton(
                      label: 'Edit',
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.to(() => KinerjaCreatePage(item: item));
                      },
                      style: AppButtonStyle.outlined,
                      icon: Icons.edit_rounded,
                    ),
                  ),
                  SizedBox(width: AppSpacing.s12.w),
                ],
                Expanded(
                  child: AppButton(
                    label: 'Hapus',
                    onPressed: () => _confirmDelete(context, item.id),
                    style: AppButtonStyle.outlined,
                    icon: Icons.delete_rounded,
                  ),
                ),
              ],
            ),
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

  void _confirmDelete(BuildContext context, String id) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    Navigator.of(context).pop();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Hapus Kinerja',
          style: typography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan kinerja ini?',
          style: typography.bodyMedium.copyWith(
            color: colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: typography.labelLarge.copyWith(color: colors.onSurface),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Get.find<KinerjaController>(tag: 'kinerja_list')
                  .deleteActivity(id);
            },
            child: Text(
              'Hapus',
              style: typography.labelLarge.copyWith(color: colors.error),
            ),
          ),
        ],
      ),
    );
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

  void _confirmSubmit(BuildContext context, String id) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Ajukan Kinerja?',
          style: typography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Setelah diajukan, status kinerja akan menjadi Pending dan masuk ke antrean atasan untuk disetujui.',
          style: typography.bodyMedium.copyWith(
            color: colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Batal',
              style: typography.labelLarge.copyWith(color: colors.onSurface),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
              if (Get.isRegistered<KinerjaController>(tag: 'kinerja_list')) {
                await Get.find<KinerjaController>(tag: 'kinerja_list')
                    .submitActivity(id);
              }
            },
            child: Text(
              'Ajukan',
              style: typography.labelLarge.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, AppColors colors, AppTypography typography) {
    Color bg;
    Color fg;
    String label = status;

    final lower = status.toLowerCase();
    if (lower == 'disetujui' || lower == 'approved' || lower == 'selesai') {
      bg = colors.success.withValues(alpha: 0.15);
      fg = colors.success;
      label = 'Disetujui';
    } else if (lower == 'pending' || lower == 'submitted' || lower == 'menunggu') {
      bg = colors.warning.withValues(alpha: 0.15);
      fg = colors.warning;
      label = 'Pending';
    } else if (lower == 'ditolak' || lower == 'rejected') {
      bg = colors.error.withValues(alpha: 0.15);
      fg = colors.error;
      label = 'Ditolak';
    } else {
      bg = colors.outline.withValues(alpha: 0.2);
      fg = colors.onSurface.withValues(alpha: 0.7);
      label = 'Draft';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s10.w, vertical: AppSpacing.s4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
