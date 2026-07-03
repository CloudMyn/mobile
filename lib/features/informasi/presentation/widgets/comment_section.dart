import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/network/session_manager.dart';
import '../../../../design_system/components/app_skeleton.dart';
import '../../../../design_system/components/molecules/app_empty_state.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/comment_item.dart';
import '../controllers/informasi_controller.dart';
import '../../../auth/data/models/user_model.dart';

class CommentSection extends StatelessWidget {
  const CommentSection({
    super.key,
    required this.articleId,
    required this.articleSlug,
    required this.initialTotal,
    this.isCommentsEnabled = true,
    required this.onReplyTap,
  });

  final String articleId;
  final String articleSlug;
  final int initialTotal;
  final bool isCommentsEnabled;
  final void Function(String id, String name, int depth, String? parentId)
  onReplyTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final ctrl = Get.find<InformasiController>();
    final session = Get.find<SessionManager>();

    return Obx(() {
      final comments = ctrl.commentsFor(articleId);
      final total = ctrl.totalComments(articleId, fallback: initialTotal);
      final isInitialLoading = ctrl.isCommentsInitialLoading(articleId);
      final isLoadingMore = ctrl.isCommentsLoadingMore(articleId);
      final error = ctrl.commentsErrorFor(articleId);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_rounded,
                size: 18.sp,
                color: colors.primary,
              ),
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
          if (isInitialLoading)
            Column(
              children: List.generate(
                3,
                (index) => const _CommentSkeleton(),
              ),
            )
          else if (error != null && comments.isEmpty)
            Column(
              children: [
                AppEmptyState(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Komentar belum dimuat',
                  subtitle: error,
                ),
                TextButton(
                  onPressed: () => ctrl.loadComments(articleSlug, articleId),
                  child: const Text('Coba Lagi'),
                ),
              ],
            )
          else if (comments.isEmpty)
            AppEmptyState(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Belum ada komentar',
              subtitle: 'Jadilah yang pertama memberikan komentar.',
            )
          else ...[
            ...comments.map(
              (c) => _CommentTile(
                articleId: articleId,
                comment: c,
                allComments: comments,
                colors: colors,
                typography: typography,
                isCommentsEnabled: isCommentsEnabled,
                currentUserId: session.currentUser.value?.id?.toString(),
                onReply: onReplyTap,
              ),
            ),
            if (isLoadingMore)
              const _CommentSkeleton(),
          ],
        ],
      );
    });
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.articleId,
    required this.comment,
    required this.allComments,
    required this.colors,
    required this.typography,
    required this.isCommentsEnabled,
    this.currentUserId,
    required this.onReply,
  });

  final String articleId;
  final CommentItem comment;
  final List<CommentItem> allComments;
  final AppColors colors;
  final AppTypography typography;
  final bool isCommentsEnabled;
  final String? currentUserId;
  final void Function(String id, String name, int depth, String? parentId)
  onReply;

  @override
  Widget build(BuildContext context) {
    final isDeleted = comment.isDeleted;
    final displayAuthorName = isDeleted ? 'Anonim' : comment.authorName;
    final displayInitials = isDeleted ? '?' : comment.initials;
    final displayContent = isDeleted ? 'Pesan telah dihapus' : comment.content;

    final level = (comment.depth - 1).clamp(0, 2);
    final isRoot = comment.depth == 1;
    final calculatedIndent = level * 36.w;

    String? parentSnippet;
    if (comment.depth >= 3 && comment.parentId != null) {
      final parentComment = allComments.firstWhereOrNull(
        (c) => c.id == comment.parentId,
      );
      if (parentComment != null) {
        var snippet = parentComment.content.replaceAll('\n', ' ').trim();
        if (snippet.length > 48) {
          snippet = '${snippet.substring(0, 48)}...';
        }
        parentSnippet = 'Membalas @${parentComment.authorName}: "$snippet"';
      }
    }

    return Padding(
      padding: EdgeInsets.only(
        left: calculatedIndent,
        bottom: AppSpacing.s12.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _showUserProfile(context, comment),
            child: Container(
              width: isRoot ? 34.w : 28.w,
              height: isRoot ? 34.w : 28.w,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: (!isDeleted && comment.avatarUrl != null)
                    ? Image.network(
                        comment.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildInitials(colors, displayInitials, isRoot ? 12.sp : 10.sp),
                      )
                    : _buildInitials(colors, displayInitials, isRoot ? 12.sp : 10.sp),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayAuthorName,
                        style: typography.bodySmall.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpacing.s8.w),
                    Text(
                      comment.timeAgo + (!isDeleted && comment.editedAt != null ? ' (Diedit)' : ''),
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
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12.w,
                    vertical: AppSpacing.s8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isRoot
                        ? colors.surface
                        : colors.primary.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(AppRadius.r12),
                      bottomLeft: Radius.circular(AppRadius.r12),
                      bottomRight: Radius.circular(AppRadius.r12),
                    ),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    displayContent,
                    style: typography.bodySmall.copyWith(
                      color: isDeleted
                          ? colors.onSurface.withValues(alpha: 0.5)
                          : colors.onSurface.withValues(alpha: 0.85),
                      fontStyle: isDeleted ? FontStyle.italic : null,
                      height: 1.4,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (isCommentsEnabled)
                      InkWell(
                        onTap: isDeleted ? null : () => onReply(
                          comment.id,
                          displayAuthorName,
                          comment.depth,
                          comment.parentId,
                        ),
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
                                color: isDeleted
                                    ? colors.onSurface.withValues(alpha: 0.3)
                                    : colors.primary.withValues(alpha: 0.7),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Balas',
                                style: typography.caption.copyWith(
                                  color: isDeleted
                                      ? colors.onSurface.withValues(alpha: 0.3)
                                      : colors.primary.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (!isDeleted && currentUserId != null && currentUserId == comment.authorId) ...[
                      if (isCommentsEnabled) SizedBox(width: AppSpacing.s12.w),
                      InkWell(
                        onTap: () => _showEditDialog(context, Get.find<InformasiController>()),
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
                                Icons.edit_rounded,
                                size: 13.sp,
                                color: colors.onSurface.withValues(alpha: 0.5),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Edit',
                                style: typography.caption.copyWith(
                                  color: colors.onSurface.withValues(alpha: 0.5),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.s12.w),
                      InkWell(
                        onTap: () => _confirmDelete(context, Get.find<InformasiController>()),
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
                                Icons.delete_outline_rounded,
                                size: 13.sp,
                                color: colors.error.withValues(alpha: 0.7),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Hapus',
                                style: typography.caption.copyWith(
                                  color: colors.error.withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, InformasiController ctrl) {
    final textController = TextEditingController(text: comment.content);
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Edit Komentar',
            style: typography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: textController,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Tulis komentar Anda...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                final content = textController.text.trim();
                if (content.isEmpty) return;
                
                // Show loading indicator in dialog
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  await ctrl.editComment(articleId, comment.id, content);
                  if (context.mounted) {
                    Navigator.pop(context); // close loading
                    Navigator.pop(context); // close dialog
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // close loading
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, InformasiController ctrl) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Hapus Komentar',
            style: typography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus komentar ini?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  await ctrl.deleteComment(articleId, comment.id);
                  if (context.mounted) {
                    Navigator.pop(context); // close loading
                    Navigator.pop(context); // close dialog
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context); // close loading
                  }
                }
              },
              child: Text(
                'Hapus',
                style: TextStyle(color: colors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showUserProfile(BuildContext context, CommentItem comment) {
    if (comment.isDeleted) return; // Jangan tampilkan profil untuk komentar yang dihapus
    
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final ctrl = Get.find<InformasiController>();

    // Trigger the fetch
    ctrl.getPublicProfile(comment.authorId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Obx(() {
          final isLoading = ctrl.isLoadingPublicProfile[comment.authorId] ?? false;
          final UserModel? user = ctrl.publicProfiles[comment.authorId];

          return Container(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s16.w,
              AppSpacing.s24.h,
              AppSpacing.s16.w,
              AppSpacing.s32.h,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.r24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: AppSpacing.s24.h),
                  decoration: BoxDecoration(
                    color: colors.outline.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.r2),
                  ),
                ),
                if (isLoading && user == null) ...[
                  // Loading State (Skeleton)
                  AppSkeleton.circle(size: 100.w),
                  SizedBox(height: AppSpacing.s16.h),
                  AppSkeleton(width: 180.w, height: 20.h),
                  SizedBox(height: 8.h),
                  AppSkeleton(width: 120.w, height: 14.h),
                  SizedBox(height: AppSpacing.s24.h),
                  _buildInfoRowSkeleton(Icons.business_rounded, 'Instansi', colors),
                  SizedBox(height: AppSpacing.s12.h),
                  _buildInfoRowSkeleton(Icons.work_outline_rounded, 'Jabatan', colors),
                  SizedBox(height: AppSpacing.s12.h),
                  _buildInfoRowSkeleton(Icons.military_tech_rounded, 'Pangkat/Golongan', colors),
                ] else if (user != null) ...[
                  // Loaded State
                  GestureDetector(
                    onTap: () {
                      if (user.profilePictureUrl != null) {
                        _showFullScreenImage(context, user.profilePictureUrl!);
                      }
                    },
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: user.profilePictureUrl != null
                            ? Image.network(
                                user.profilePictureUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildInitials(colors, user.initials, 32.sp),
                              )
                            : _buildInitials(colors, user.initials, 32.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  Text(
                    user.fullName.isNotEmpty ? user.fullName : user.name,
                    style: typography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (user.nip.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'NIP. ${user.nip}',
                      style: typography.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                  SizedBox(height: AppSpacing.s24.h),
                  _buildInfoRow(Icons.business_rounded, 'Instansi', user.institution?.name ?? '-', colors, typography),
                  SizedBox(height: AppSpacing.s12.h),
                  _buildInfoRow(Icons.work_outline_rounded, 'Jabatan', user.jobTitle?.name ?? '-', colors, typography),
                  SizedBox(height: AppSpacing.s12.h),
                  _buildInfoRow(Icons.military_tech_rounded, 'Pangkat/Golongan', user.rank?.displayLabel ?? '-', colors, typography),
                ] else ...[
                  // Error Fallback
                  GestureDetector(
                    onTap: () {
                      if (comment.avatarUrl != null) {
                        _showFullScreenImage(context, comment.avatarUrl!);
                      }
                    },
                    child: Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: comment.avatarUrl != null
                            ? Image.network(
                                comment.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildInitials(colors, comment.initials, 32.sp),
                              )
                            : _buildInitials(colors, comment.initials, 32.sp),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s16.h),
                  Text(
                    comment.authorName,
                    style: typography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (comment.nip != null && comment.nip!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'NIP. ${comment.nip}',
                      style: typography.bodyMedium.copyWith(color: colors.onSurface.withValues(alpha: 0.6)),
                    ),
                  ],
                  SizedBox(height: AppSpacing.s24.h),
                  _buildInfoRow(Icons.business_rounded, 'Instansi', comment.instansi ?? '-', colors, typography),
                  SizedBox(height: AppSpacing.s12.h),
                  _buildInfoRow(Icons.work_outline_rounded, 'Jabatan', comment.jabatan ?? '-', colors, typography),
                  SizedBox(height: AppSpacing.s16.h),
                  TextButton(
                    onPressed: () => ctrl.getPublicProfile(comment.authorId),
                    child: const Text('Coba Lagi'),
                  ),
                ]
              ],
            ),
          );
        });
      },
    );
  }

  Widget _buildInitials(AppColors colors, String initials, double fontSize) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontWeight: FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  Widget _buildInfoRowSkeleton(IconData icon, String label, AppColors colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: colors.primary.withValues(alpha: 0.4)),
        SizedBox(width: AppSpacing.s12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: typography.caption.copyWith(color: colors.onSurface.withValues(alpha: 0.4)),
              ),
              SizedBox(height: 4.h),
              AppSkeleton(
                width: 150.w,
                height: 16.h,
                borderRadius: AppRadius.r4,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, AppColors colors, AppTypography typography) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: colors.primary),
        SizedBox(width: AppSpacing.s12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: typography.caption.copyWith(color: colors.onSurface.withValues(alpha: 0.5)),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: typography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 16.h,
                right: 16.w,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}



class _CommentSkeleton extends StatelessWidget {
  const _CommentSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeleton.circle(size: 34.w),
          SizedBox(width: AppSpacing.s8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    AppSkeleton(width: 100.w, height: 14.h),
                    SizedBox(width: AppSpacing.s8.w),
                    AppSkeleton(width: 50.w, height: 10.h),
                  ],
                ),
                SizedBox(height: 4.h),
                AppSkeleton(
                  width: double.infinity,
                  height: 60.h,
                  borderRadius: AppRadius.r12,
                ),
                SizedBox(height: 4.h),
                AppSkeleton(width: 40.w, height: 12.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

