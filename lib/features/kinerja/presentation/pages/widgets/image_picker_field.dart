import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../design_system/components/app_card.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_radius.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';

class ImagePickerField extends StatelessWidget {
  final String? imagePath;
  final ValueChanged<String> onImagePicked;
  final VoidCallback onRemove;

  const ImagePickerField({
    super.key,
    required this.imagePath,
    required this.onImagePicked,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final hasImage = imagePath != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lampiran Foto',
          style: typography.titleSmall.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpacing.s8.h),
        if (!hasImage) ...[
          // ── Belum ada gambar ─────────────────────────────
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded, size: 18),
                  label: const Text('Ambil Foto'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.s12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                    ),
                    side: BorderSide(
                      color: colors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickImage(context, ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_rounded, size: 18),
                  label: const Text('Pilih Galeri'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: AppSpacing.s12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r12),
                    ),
                    side: BorderSide(
                      color: colors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s4.h),
          Text(
            'Foto akan dikompresi dengan ukuran maksimal sesuai pengaturan',
            style: typography.caption.copyWith(
              color: colors.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ] else ...[
          // ── Sudah ada gambar → preview ───────────────────
          AppCard(
            outlined: true,
            padding: EdgeInsets.all(AppSpacing.s12.w),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  child: Image.file(
                    File(imagePath!),
                    width: 64.w,
                    height: 64.w,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: AppSpacing.s12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Foto kegiatan',
                        style: typography.bodySmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '1:1 • ${_getFileSize(imagePath!)}',
                        style: typography.caption.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.error,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 28,
                    minHeight: 28,
                  ),
                  tooltip: 'Hapus foto',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: source,
      imageQuality: 100,
    );
    if (xFile != null) {
      onImagePicked(xFile.path);
    }
  }

  String _getFileSize(String path) {
    try {
      final file = File(path);
      final size = file.lengthSync();
      if (size < 1024) return '$size B';
      if (size < 1024 * 1024) return '${(size / 1024).round()} KB';
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (_) {
      return '?';
    }
  }
}
