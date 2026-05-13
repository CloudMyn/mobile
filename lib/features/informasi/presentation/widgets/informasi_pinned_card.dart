import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/informasi_category.dart';
import '../../data/models/informasi_item.dart';

class InformasiPinnedCard extends StatelessWidget {
  final InformasiItem item;
  final InformasiCategory? category;
  final VoidCallback onTap;

  const InformasiPinnedCard({
    super.key,
    required this.item,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.r16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Ink(
            height: 180.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.r16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.primary,
                  colors.primaryContainer.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background pattern overlay
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: Icon(
                      Icons.article_rounded,
                      size: 160,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Pin badge
                Positioned(
                  top: AppSpacing.s12.h,
                  right: AppSpacing.s12.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.s8.w,
                      vertical: AppSpacing.s4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppRadius.r20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.push_pin_rounded, size: 10.sp, color: Colors.white),
                        SizedBox(width: AppSpacing.s4.w),
                        Text(
                          'Terpasang',
                          style: typography.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Content
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.s16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (category != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.s8.w,
                              vertical: AppSpacing.s4.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppRadius.r20),
                            ),
                            child: Text(
                              category!.name,
                              style: typography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        SizedBox(height: AppSpacing.s8.h),
                        Text(
                          item.title,
                          style: typography.titleMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpacing.s8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.person_rounded,
                              size: 12.sp,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            SizedBox(width: AppSpacing.s4.w),
                            Expanded(
                              child: Text(
                                item.author,
                                style: typography.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 12.sp,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            SizedBox(width: AppSpacing.s4.w),
                            Text(
                              '${item.commentCount}',
                              style: typography.caption.copyWith(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
