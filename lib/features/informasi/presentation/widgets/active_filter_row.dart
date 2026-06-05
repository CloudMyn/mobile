import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/informasi_category.dart';
import '../controllers/informasi_controller.dart';

class ActiveFilterRow extends StatelessWidget {
  const ActiveFilterRow({
    super.key,
    required this.ctrl,
    required this.colors,
    required this.typography,
  });

  final InformasiController ctrl;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final selectedCategoryId = ctrl.selectedCategoryId.value;
    InformasiCategory? cat;
    if (selectedCategoryId != null) {
      for (final category in ctrl.categories) {
        if (category.id == selectedCategoryId) {
          cat = category;
          break;
        }
      }
    }
    final range = ctrl.dateRange.value;

    return Wrap(
      spacing: 8.w,
      children: [
        if (cat != null)
          _FilterChip(
            label: cat.name,
            color: cat.color,
            onRemove: () => ctrl.selectCategory(null),
            typography: typography,
          ),
        if (range != null)
          _FilterChip(
            label: '${_fmt(range.start)} - ${_fmt(range.end)}',
            color: colors.primary,
            onRemove: () => ctrl.applyDateRange(null),
            typography: typography,
          ),
      ],
    );
  }

  String _fmt(DateTime d) {
    const m = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${d.day} ${m[d.month]}';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.color,
    required this.onRemove,
    required this.typography,
  });

  final String label;
  final Color color;
  final VoidCallback onRemove;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: AppSpacing.s4.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.r20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: typography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: AppSpacing.s4.w),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(AppRadius.circular),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.s2.w),
              child: Icon(Icons.close_rounded, size: 12.sp, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
