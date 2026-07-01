import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/informasi_item.dart';
import '../controllers/informasi_controller.dart';
import '../widgets/comment_section.dart';
import '../widgets/informasi_content_view.dart';

class InformasiDetailPage extends StatefulWidget {
  const InformasiDetailPage({super.key, required this.item});

  final InformasiItem item;

  @override
  State<InformasiDetailPage> createState() => _InformasiDetailPageState();
}

class _InformasiDetailPageState extends State<InformasiDetailPage> {
  late final InformasiController _ctrl;
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<InformasiController>();
    _ctrl.loadDetail(widget.item.slug, widget.item.id);
    _ctrl.loadComments(widget.item.slug, widget.item.id);
    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      _ctrl.loadMoreComments(widget.item.slug, widget.item.id);
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _showCommentSheet({String? replyToId, String? replyToName}) {
    String? snippet;
    if (replyToId != null) {
      final comments = _ctrl.commentsFor(widget.item.id);
      final parentComment = comments.firstWhereOrNull((c) => c.id == replyToId);
      if (parentComment != null) {
        snippet = parentComment.content.replaceAll('\n', ' ').trim();
        if (snippet.length > 24) {
          snippet = '${snippet.substring(0, 24)}...';
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentBottomSheet(
        articleId: widget.item.id,
        articleSlug: widget.item.slug,
        replyToId: replyToId,
        replyToName: replyToName,
        replySnippet: snippet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Obx(() {
      final article = _ctrl.articleFor(widget.item.id, fallback: widget.item);
      final category = _ctrl.categories.firstWhereOrNull(
        (c) => c.id == article.categoryId,
      );

      return Scaffold(
        backgroundColor: colors.background,
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([
              _ctrl.loadDetail(widget.item.slug, widget.item.id),
              _ctrl.loadComments(widget.item.slug, widget.item.id),
            ]);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollCtrl,
            slivers: [
            SliverAppBar(
              expandedHeight: 260.h,
              pinned: true,
              backgroundColor: colors.surface,
              foregroundColor: colors.onSurface,
              elevation: 0,
              leading: Padding(
                padding: EdgeInsets.all(8.w),
                child: _FrostedButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Get.back(),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    article.imageUrl != null
                        ? Hero(
                            tag: 'article_image_${article.id}',
                            child: Image.network(
                              article.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  _GradientCover(colors: colors),
                            ),
                          )
                        : _GradientCover(colors: colors),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.4, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppSpacing.s16.w,
                      right: AppSpacing.s16.w,
                      bottom: AppSpacing.s16.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (category != null)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSpacing.s8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: category.color.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.r20,
                                ),
                              ),
                              child: Text(
                                category.name,
                                style: typography.caption.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          SizedBox(height: AppSpacing.s8.h),
                          Text(
                            article.title,
                            style: typography.titleLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                              height: 1.3,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.s16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              article.author.isNotEmpty
                                  ? article.author[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: colors.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.s8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.author,
                                style: typography.bodySmall.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formatDate(article.publishedAt),
                                style: typography.caption.copyWith(
                                  color: colors.onSurface.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_rounded,
                              size: 13.sp,
                              color: colors.onSurface.withValues(alpha: 0.4),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${article.viewCount}',
                              style: typography.caption.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.s16.h),
                    Divider(
                      height: 1,
                      color: colors.outline.withValues(alpha: 0.12),
                    ),
                    SizedBox(height: AppSpacing.s16.h),
                    InformasiContentView(
                      content: article.content,
                      contentFormat: article.contentFormat,
                    ),
                    SizedBox(height: AppSpacing.s20.h),
                    if (article.tags.isNotEmpty) ...[
                      Wrap(
                        spacing: AppSpacing.s8.w,
                        runSpacing: AppSpacing.s8.h,
                        children: article.tags.map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.s8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.outline.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                AppRadius.r20,
                              ),
                              border: Border.all(
                                color: colors.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: typography.caption.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.55),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: AppSpacing.s20.h),
                    ],
                    Divider(
                      height: 1,
                      color: colors.outline.withValues(alpha: 0.12),
                    ),
                    SizedBox(height: AppSpacing.s20.h),
                    CommentSection(
                      articleId: article.id,
                      articleSlug: article.slug,
                      initialTotal: article.commentCount,
                      isCommentsEnabled: article.isCommentsEnabled,
                      onReplyTap: (id, name, depth, parentId) =>
                          _showCommentSheet(
                            replyToId: depth >= 3 ? (parentId ?? id) : id,
                            replyToName: name,
                          ),
                    ),
                    if (!article.isCommentsEnabled)
                      Container(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.s16.h),
                        alignment: Alignment.center,
                        child: Text(
                          'Komentar dinonaktifkan untuk artikel ini',
                          style: typography.bodyMedium.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.5),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ],
        ),
        ),
        floatingActionButton: article.isCommentsEnabled
            ? FloatingActionButton.extended(
                onPressed: _showCommentSheet,
                icon: const Icon(Icons.chat_bubble_outline_rounded),
                label: const Text('Tulis Komentar'),
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              )
            : null,
      );
    });
  }

  String _formatDate(DateTime dt) {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

class _FrostedButton extends StatelessWidget {
  const _FrostedButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Material(
        color: Colors.black.withValues(alpha: 0.3),
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.2),
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: Icon(icon, color: Colors.white, size: 18.sp),
          ),
        ),
      ),
    );
  }
}

class _GradientCover extends StatelessWidget {
  const _GradientCover({required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors.primary, colors.primaryContainer],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.article_rounded,
          size: 80,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
    );
  }
}

class _CommentBottomSheet extends StatefulWidget {
  const _CommentBottomSheet({
    required this.articleId,
    required this.articleSlug,
    this.replyToId,
    this.replyToName,
    this.replySnippet,
  });

  final String articleId;
  final String articleSlug;
  final String? replyToId;
  final String? replyToName;
  final String? replySnippet;

  @override
  State<_CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<_CommentBottomSheet> {
  final _textCtrl = TextEditingController();
  final _focusNode = FocusNode();
  late final InformasiController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<InformasiController>();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) {
      AppFeedback.showSnackbar(
        title: 'Komentar kosong',
        message: 'Isi komentar terlebih dahulu.',
        isError: true,
      );
      return;
    }

    _ctrl
        .addComment(widget.articleId, text, parentId: widget.replyToId)
        .then((_) {
          if (mounted) Navigator.of(context).pop();
        })
        .catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16.w,
        AppSpacing.s16.h,
        AppSpacing.s16.w,
        AppSpacing.s16.h + viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.r24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.replyToId != null ? 'Balas Komentar' : 'Tulis Komentar',
                style: typography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s16.h),
          if (widget.replyToId != null)
            Container(
              margin: EdgeInsets.only(bottom: AppSpacing.s12.h),
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
                      widget.replySnippet != null
                          ? 'Membalas @${widget.replyToName}: "${widget.replySnippet}"'
                          : 'Membalas @${widget.replyToName}',
                      style: typography.bodySmall.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                    border: Border.all(
                      color: colors.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: _textCtrl,
                    focusNode: _focusNode,
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.newline,
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.replyToId != null
                          ? 'Tulis balasan...'
                          : 'Tulis komentar...',
                      hintStyle: typography.bodyMedium.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.35),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.s12.w,
                        vertical: AppSpacing.s10.h,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.s12.w),
              Material(
                color: colors.primary,
                borderRadius: BorderRadius.circular(AppRadius.r12),
                child: InkWell(
                  onTap: _submit,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  child: SizedBox(
                    width: 44.w,
                    height: 44.w,
                    child: Icon(
                      Icons.send_rounded,
                      color: colors.onPrimary,
                      size: 20.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
