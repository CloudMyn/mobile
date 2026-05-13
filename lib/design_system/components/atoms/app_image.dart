import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_duration.dart';
import '../../tokens/app_icon_size.dart';
import '../../tokens/app_radius.dart';
import '../app_skeleton.dart';

class AppImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final Widget? errorWidget;
  final Widget? placeholder;

  const AppImage({
    super.key,
    this.url,
    this.width,
    this.height,
    this.borderRadius = AppRadius.r8,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    if (url == null || url!.isEmpty) {
      return _buildError(colors);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedSwitcher(
            duration: AppDuration.slow,
            child: frame != null
                ? child
                : (placeholder ??
                    AppSkeleton(
                      width: width,
                      height: height,
                      borderRadius: borderRadius,
                    )),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildError(colors),
      ),
    );
  }

  Widget _buildError(AppColors colors) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: colors.primaryContainer.withValues(alpha: 0.3),
        child: Icon(
          Icons.broken_image_outlined,
          size: AppIconSize.lg,
          color: colors.outline,
        ),
      ),
    );
  }
}
