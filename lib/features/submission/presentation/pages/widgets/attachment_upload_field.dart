import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../design_system/tokens/app_colors.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../../../../design_system/tokens/app_typography.dart';

class AttachmentUploadField extends StatelessWidget {
  final String fieldName;
  final bool isRequired;
  final String? fileName;
  final List<String> allowedExtensions;
  final int? maxFileSizeKb;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const AttachmentUploadField({
    super.key,
    required this.fieldName,
    required this.isRequired,
    required this.fileName,
    this.allowedExtensions = const [],
    this.maxFileSizeKb,
    required this.onPick,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final hasFile = fileName != null;
    
    String helperText = '';
    if (allowedExtensions.isNotEmpty) {
      helperText += allowedExtensions.map((e) => e.toUpperCase()).join(', ');
    }
    if (maxFileSizeKb != null) {
      final mb = (maxFileSizeKb! / 1024).toStringAsFixed(1);
      if (helperText.isNotEmpty) helperText += ' • ';
      helperText += 'Maks $mb MB';
    }

    return Container(
      padding: EdgeInsets.all(AppSpacing.s12.w),
      decoration: BoxDecoration(
        border: Border.all(
          color: hasFile
              ? colors.primary.withValues(alpha: 0.4)
              : colors.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
        color: hasFile
            ? colors.primary.withValues(alpha: 0.04)
            : colors.surface,
      ),
      child: Row(
        children: [
          Icon(
            hasFile ? Icons.insert_drive_file_rounded : Icons.attach_file_rounded,
            size: 20,
            color: hasFile ? colors.primary : colors.onSurface.withValues(alpha: 0.4),
          ),
          SizedBox(width: AppSpacing.s8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    text: fieldName,
                    style: typography.bodySmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    children: isRequired
                        ? [
                            TextSpan(
                              text: ' *',
                              style: typography.bodySmall.copyWith(
                                color: colors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          ]
                        : [],
                  ),
                ),
                if (!hasFile && helperText.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    helperText,
                    style: typography.labelSmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
                if (hasFile) ...[
                  SizedBox(height: 2.h),
                  Text(
                    fileName!,
                    style: typography.labelSmall.copyWith(
                      color: colors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s8.w),
          if (!hasFile)
            OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.upload_rounded, size: 16),
              label: const Text('Pilih'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s12.w,
                  vertical: AppSpacing.s8.h,
                ),
                textStyle: typography.labelSmall,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            )
          else
            IconButton(
              onPressed: onRemove,
              icon: Icon(Icons.close_rounded, size: 18, color: colors.error),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              tooltip: 'Hapus file',
            ),
        ],
      ),
    );
  }
}
