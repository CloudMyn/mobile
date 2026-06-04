import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/comment_item.dart';
import '../controllers/informasi_controller.dart';

class CommentSection extends StatelessWidget {
  final String articleId;
  final void Function(String id, String name, int depth, String? parentId) onReplyTap;

  const CommentSection({
    super.key,
    required this.articleId,
    required this.onReplyTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final ctrl = Get.find<InformasiController>();

    return Obx(() {
      final comments = ctrl.commentsFor(articleId);
      final total = ctrl.totalComments(articleId);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.chat_bubble_rounded,
                  size: 18.sp, color: colors.primary),
              SizedBox(width: AppSpacing.s8.w),
              Text(
                'Komentar ($total)',
                style: typography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s16.h),

          // Comment list
          if (comments.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s16.h),
              child: Center(
                child: Text(
                  'Belum ada komentar. Jadilah yang pertama!',
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.4),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...comments.map((c) => _CommentTile(
                  comment: c,
                  allComments: comments,
                  colors: colors,
                  typography: typography,
                  onReply: onReplyTap,
                )),
          
          if (ctrl.commentsHasMore[articleId] == true)
            Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.s16.h),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary,
                  ),
                ),
              ),
            )
        ],
      );
    });
  }
}
// =============================================================================

class _CommentTile extends StatelessWidget {
  final CommentItem comment;
  final List<CommentItem> allComments;
  final AppColors colors;
  final AppTypography typography;
  final void Function(String id, String name, int depth, String? parentId) onReply;

  const _CommentTile({
    required this.comment,
    required this.allComments,
    required this.colors,
    required this.typography,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final level = (comment.depth - 1).clamp(0, 2);
    final isRoot = comment.depth == 1;
    final calculatedIndent = level * 36.w;

    String? parentSnippet;
    if (comment.depth >= 3 && comment.parentId != null) {
      final parentComment = allComments.firstWhereOrNull((c) => c.id == comment.parentId);
      if (parentComment != null) {
        String snippet = parentComment.content.replaceAll('\n', ' ').trim();
        if (snippet.length > 15) {
          snippet = '${snippet.substring(0, 15)}...';
        }
        parentSnippet = 'Membalas @${parentComment.authorName}: "$snippet"';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: calculatedIndent,
            bottom: AppSpacing.s12.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: isRoot ? 34.w : 28.w,
                height: isRoot ? 34.w : 28.w,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    comment.initials,
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: isRoot ? 12.sp : 10.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s8.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + time
                    Row(
                      children: [
                        Text(
                          comment.authorName,
                          style: typography.bodySmall.copyWith(
                            color: colors.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: AppSpacing.s8.w),
                        Text(
                          comment.timeAgo,
                          style: typography.caption.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.4),
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),

                    if (parentSnippet != null)
                      Container(
                        margin: EdgeInsets.only(bottom: 4.h),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.outline.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.r8),
                          border: Border(
                            left: BorderSide(
                              color: colors.primary.withValues(alpha: 0.5),
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          parentSnippet,
                          style: typography.caption.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    // Content bubble
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12.w,
                        vertical: AppSpacing.s8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isRoot
                            ? colors.surface
                            : colors.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(AppRadius.r12),
                          bottomLeft: Radius.circular(AppRadius.r12),
                          bottomRight: Radius.circular(AppRadius.r12),
                        ),
                        border: Border.all(
                          color: colors.outline.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Text(
                        comment.content,
                        style: typography.bodySmall.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.85),
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),

                    // Reply button
                    InkWell(
                      onTap: () => onReply(comment.id, comment.authorName, comment.depth, comment.parentId),
                      borderRadius: BorderRadius.circular(AppRadius.r8),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: AppSpacing.s4.h,
                          horizontal: AppSpacing.s4.w,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.reply_rounded,
                              size: 13.sp,
                              color: colors.primary.withValues(alpha: 0.7),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Balas',
                              style: typography.caption.copyWith(
                                color: colors.primary.withValues(alpha: 0.7),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
