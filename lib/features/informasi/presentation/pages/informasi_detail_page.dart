import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/informasi_item.dart';
import '../controllers/informasi_controller.dart';
import '../widgets/comment_section.dart';

class InformasiDetailPage extends StatefulWidget {
  final InformasiItem item;

  const InformasiDetailPage({super.key, required this.item});

  @override
  State<InformasiDetailPage> createState() => _InformasiDetailPageState();
}

class _InformasiDetailPageState extends State<InformasiDetailPage> {
  late final InformasiController _ctrl;
  final _scrollCtrl = ScrollController();
  final _commentFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<InformasiController>();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  void _scrollToComments() {
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
    Future.delayed(const Duration(milliseconds: 450), () {
      _commentFocus.requestFocus();
    });
  }

  void _share() {
    final text = '${widget.item.title}\n\nBaca selengkapnya di Aplikasi Presensi Barru Kab.';
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Disalin',
      'Tautan informasi telah disalin ke clipboard.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final category = _ctrl.categories
        .firstWhereOrNull((c) => c.id == widget.item.categoryId);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ── SliverAppBar ────────────────────────────────────────────────
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
            actions: [
              Padding(
                padding: EdgeInsets.only(right: AppSpacing.s8.w),
                child: _FrostedButton(
                  icon: Icons.share_rounded,
                  onTap: _share,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover image or gradient placeholder
                  widget.item.imageUrl != null
                      ? Image.network(
                          widget.item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _GradientCover(colors: colors),
                        )
                      : _GradientCover(colors: colors),

                  // Bottom gradient overlay
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

                  // Category + title on image
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
                              borderRadius: BorderRadius.circular(AppRadius.r20),
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
                          widget.item.title,
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

          // ── Content ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author + date row
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
                            widget.item.author.isNotEmpty
                                ? widget.item.author[0].toUpperCase()
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
                              widget.item.author,
                              style: typography.bodySmall.copyWith(
                                color: colors.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatDate(widget.item.publishedAt),
                              style: typography.caption.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.45),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // View count
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
                            '${widget.item.viewCount}',
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

                  // Article body
                  Text(
                    widget.item.content,
                    style: typography.bodyMedium.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.85),
                      height: 1.75,
                    ),
                  ),

                  SizedBox(height: AppSpacing.s20.h),

                  // Tags
                  if (widget.item.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: AppSpacing.s8.w,
                      runSpacing: AppSpacing.s8.h,
                      children: widget.item.tags.map((tag) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.s8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: colors.outline.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(AppRadius.r20),
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

                  // Comments
                  CommentSection(
                    articleId: widget.item.id,
                    inputFocusNode: _commentFocus,
                  ),

                  SizedBox(height: 80.h),
                ],
              ),
            ),
          ),
        ],
      ),

      // FAB — tulis komentar
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _scrollToComments,
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: const Text('Tulis Komentar'),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

class _FrostedButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FrostedButton({required this.icon, required this.onTap});

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
  final AppColors colors;
  const _GradientCover({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary,
            colors.primaryContainer,
          ],
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
