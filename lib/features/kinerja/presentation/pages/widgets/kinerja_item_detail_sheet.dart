import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../design_system/components/app_button.dart';
import '../../../../../design_system/components/app_image_viewer.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_radius.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../data/models/activity_item.dart';
import '../../controllers/kinerja_controller.dart';
import '../kinerja_create_page.dart';

/// Bottom sheet yang menampilkan detail item kinerja.
/// Berisi informasi lengkap, lampiran gambar, serta aksi edit dan hapus.
class KinerjaItemDetailSheet extends StatelessWidget {
  final ActivityItem item;

  const KinerjaItemDetailSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final imageUrl = item.imageUrl != null ? AppConstants.sanitizeImageUrl(item.imageUrl!) : null;
    final hasImage = imageUrl != null;

    return DraggableScrollableSheet(
      initialChildSize: hasImage ? 0.7 : 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
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

            // ── Image ──────────────────────────────────────
            if (hasImage) ...[
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
                                height: 200.h,
                                fit: BoxFit.cover,
                                loadingBuilder: (_, child, progress) =>
                                    progress == null
                                        ? child
                                        : SizedBox(
                                            height: 200.h,
                                            child: const Center(
                                                child:
                                                    CircularProgressIndicator()),
                                          ),
                                errorBuilder: (_, _, _) => SizedBox(
                                  height: 200.h,
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
                                height: 200.h,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => SizedBox(
                                  height: 200.h,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      color: colors.outline,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                        // Hint ikon zoom di pojok kanan bawah
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
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

            // ── Time & Status ───────────────────────────────
            if ((item.startTime != null && item.endTime != null) || item.status != null) ...[
              Row(
                children: [
                  if (item.startTime != null && item.endTime != null) ...[
                    Icon(
                      Icons.access_time_rounded,
                      size: 16,
                      color: colors.primary,
                    ),
                    SizedBox(width: AppSpacing.s8.w),
                    Text(
                      'Pukul ${item.startTime} - ${item.endTime}',
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (item.status != null) _buildStatusChip(item.status!, colors, typography),
                ],
              ),
              SizedBox(height: AppSpacing.s16.h),
            ],

            // ── Description ────────────────────────────────
            Text(
              'Deskripsi',
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
            SizedBox(height: AppSpacing.s12.h),

            // ── Created At ─────────────────────────────────
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

            // ── Action Buttons ─────────────────────────────
            Row(
              children: [
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

  void _confirmDelete(BuildContext context, String id) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    Navigator.of(context).pop(); // tutup sheet

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

  Widget _buildStatusChip(String status, AppColors colors, AppTypography typography) {
    Color bg;
    Color fg;
    
    if (status == 'Selesai') {
      bg = colors.success.withValues(alpha: 0.15);
      fg = colors.success;
    } else {
      bg = colors.warning.withValues(alpha: 0.15);
      fg = colors.warning;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s10.w, vertical: AppSpacing.s4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.r8),
      ),
      child: Text(
        status,
        style: typography.caption.copyWith(
          color: fg,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
