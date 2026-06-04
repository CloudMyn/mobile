import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/informasi_category.dart';
import '../../data/models/informasi_item.dart';

class InformasiCard extends StatelessWidget {
  final InformasiItem item;
  final InformasiCategory? category;
  final VoidCallback onTap;

  const InformasiCard({
    super.key,
    required this.item,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.s12.h),
      child: AppCard(
        outlined: true,
        padding: const EdgeInsets.all(0),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageUrl != null)
              Hero(
                tag: 'article_image_${item.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.r12),
                  ),
                  child: Image.network(
                    item.imageUrl!,
                    height: 140.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _PlaceholderImage(
                      colors: colors,
                      height: 140.h,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.s12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip + date row
                  Row(
                    children: [
                      if (category != null)
                        _CategoryChip(
                          category: category!,
                          typography: typography,
                        ),
                      const Spacer(),
                      Icon(
                        Icons.access_time_rounded,
                        size: 11.sp,
                        color: colors.onSurface.withValues(alpha: 0.4),
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        _formatDate(item.publishedAt),
                        style: typography.caption.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.4),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.s8.h),

                  // Title
                  Text(
                    item.title,
                    style: typography.titleSmall.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.s4.h),

                  // Author
                  Text(
                    item.author,
                    style: typography.caption.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  SizedBox(height: AppSpacing.s12.h),

                  // Footer stats
                  Row(
                    children: [
                      _Stat(
                        icon: Icons.visibility_rounded,
                        value: '${item.viewCount}',
                        color: colors.onSurface.withValues(alpha: 0.4),
                        typography: typography,
                      ),
                      SizedBox(width: AppSpacing.s12.w),
                      _Stat(
                        icon: Icons.chat_bubble_outline_rounded,
                        value: '${item.commentCount}',
                        color: colors.onSurface.withValues(alpha: 0.4),
                        typography: typography,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }
}

class _CategoryChip extends StatelessWidget {
  final InformasiCategory category;
  final AppTypography typography;

  const _CategoryChip({required this.category, required this.typography});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: category.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.r20),
        border: Border.all(color: category.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: 10.sp, color: category.color),
          SizedBox(width: 4.w),
          Text(
            category.name,
            style: typography.caption.copyWith(
              color: category.color,
              fontWeight: FontWeight.w700,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final AppTypography typography;

  const _Stat({
    required this.icon,
    required this.value,
    required this.color,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12.sp, color: color),
        SizedBox(width: 4.w),
        Text(
          value,
          style: typography.caption.copyWith(color: color, fontSize: 11.sp),
        ),
      ],
    );
  }
}

class _PlaceholderImage extends StatelessWidget {
  final AppColors colors;
  final double height;
  const _PlaceholderImage({required this.colors, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      color: colors.primary.withValues(alpha: 0.06),
      child: Icon(
        Icons.image_rounded,
        size: 36,
        color: colors.primary.withValues(alpha: 0.2),
      ),
    );
  }
}
