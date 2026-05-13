import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_duration.dart';
import '../tokens/app_elevation.dart';
import '../tokens/app_opacity.dart';
import '../tokens/app_radius.dart';
import '../tokens/app_spacing.dart';

class AppBottomNavBarItem {
  final IconData icon;
  final String label;

  const AppBottomNavBarItem({required this.icon, required this.label});
}

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final List<AppBottomNavBarItem> items;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: AppElevation.bottomNav,
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final item = items[index];
            
            return InkWell(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: AppDuration.normal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary.withValues(alpha: AppOpacity.overlay) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: isSelected ? colors.primary : colors.outline,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: isSelected ? colors.primary : colors.outline,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
