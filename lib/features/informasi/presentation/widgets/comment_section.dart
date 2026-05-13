import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/comment_item.dart';
import '../controllers/informasi_controller.dart';

class CommentSection extends StatefulWidget {
  final String articleId;
  final FocusNode inputFocusNode;

  const CommentSection({
    super.key,
    required this.articleId,
    required this.inputFocusNode,
  });

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  late final InformasiController _ctrl;
  final _textCtrl = TextEditingController();
  String? _replyToId;
  String? _replyToName;
  int _replyToDepth = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<InformasiController>();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _startReply(String commentId, String authorName, int depth) {
    setState(() {
      _replyToId = commentId;
      _replyToName = authorName;
      _replyToDepth = depth;
    });
    widget.inputFocusNode.requestFocus();
  }

  void _cancelReply() {
    setState(() {
      _replyToId = null;
      _replyToName = null;
      _replyToDepth = 0;
    });
    widget.inputFocusNode.unfocus();
  }

  void _submit() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.addComment(
      widget.articleId,
      text,
      'Saya', // current user placeholder
      parentId: _replyToId,
      parentDepth: _replyToDepth,
    );
    _textCtrl.clear();
    setState(() {
      _replyToId = null;
      _replyToName = null;
      _replyToDepth = 0;
    });
    widget.inputFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(() {
      final comments = _ctrl.commentsFor(widget.articleId);
      final total = _ctrl.totalComments(widget.articleId);

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
                  colors: colors,
                  typography: typography,
                  onReply: (id, name, depth) => _startReply(id, name, depth),
                )),

          SizedBox(height: AppSpacing.s16.h),

          // Reply context banner
          if (_replyToId != null)
            Container(
              margin: EdgeInsets.only(bottom: AppSpacing.s8.h),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s12.w,
                vertical: AppSpacing.s8.h,
              ),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.r8),
                border: Border(
                  left: BorderSide(color: colors.primary, width: 3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.reply_rounded, size: 14.sp, color: colors.primary),
                  SizedBox(width: AppSpacing.s8.w),
                  Expanded(
                    child: Text(
                      'Membalas @$_replyToName',
                      style: typography.bodySmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _cancelReply,
                    borderRadius: BorderRadius.circular(AppRadius.circular),
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.s4.w),
                      child: Icon(Icons.close_rounded,
                          size: 16.sp, color: colors.primary),
                    ),
                  ),
                ],
              ),
            ),

          // Input field
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                    border: Border.all(
                      color: widget.inputFocusNode.hasFocus
                          ? colors.primary
                          : colors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _textCtrl,
                    focusNode: widget.inputFocusNode,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    style: typography.bodyMedium.copyWith(color: colors.onSurface),
                    decoration: InputDecoration(
                      hintText: _replyToId != null
                          ? 'Tulis balasan...'
                          : 'Tulis komentar...',
                      hintStyle: typography.bodyMedium.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.35),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12.w,
                        vertical: AppSpacing.s8.h,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s8.w),
              Material(
                color: colors.primary,
                borderRadius: BorderRadius.circular(AppRadius.r12),
                child: InkWell(
                  onTap: _submit,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  child: SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child: Icon(
                      Icons.send_rounded,
                      color: colors.onPrimary,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

// =============================================================================

class _CommentTile extends StatelessWidget {
  final CommentItem comment;
  final AppColors colors;
  final AppTypography typography;
  final void Function(String id, String name, int depth) onReply;
  final double indent;

  const _CommentTile({
    required this.comment,
    required this.colors,
    required this.typography,
    required this.onReply,
    this.indent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: indent,
        bottom: AppSpacing.s12.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: indent > 0 ? 28.w : 34.w,
            height: indent > 0 ? 28.w : 34.w,
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
                  fontSize: indent > 0 ? 10.sp : 12.sp,
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

                // Content bubble
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12.w,
                    vertical: AppSpacing.s8.h,
                  ),
                  decoration: BoxDecoration(
                    color: comment.depth == 1
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
                  onTap: () => onReply(comment.id, comment.authorName, comment.depth),
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

                // Nested replies
                if (comment.replies.isNotEmpty)
                  ...comment.replies.map((r) => _CommentTile(
                        comment: r,
                        colors: colors,
                        typography: typography,
                        onReply: onReply,
                        indent: 0, // replies ditampilkan di bawah tanpa indent tambahan
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
