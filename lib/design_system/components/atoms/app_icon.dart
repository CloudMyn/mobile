import 'package:flutter/material.dart';
import '../../tokens/app_colors.dart';
import '../../tokens/app_icon_size.dart';

class AppIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color? color;

  const AppIcon(
    this.icon, {
    super.key,
    this.size = AppIconSize.lg,
    this.color,
  });

  const AppIcon.sm(this.icon, {super.key, this.color}) : size = AppIconSize.sm;
  const AppIcon.md(this.icon, {super.key, this.color}) : size = AppIconSize.md;
  const AppIcon.lg(this.icon, {super.key, this.color}) : size = AppIconSize.lg;
  const AppIcon.xl(this.icon, {super.key, this.color}) : size = AppIconSize.xl;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    return Icon(
      icon,
      size: size,
      color: color ?? colors.onSurface,
    );
  }
}
