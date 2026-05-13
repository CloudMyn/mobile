import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_chip.dart';
import '../../../../design_system/components/organisms/app_bottom_sheet.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/informasi_controller.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      title: 'Filter Informasi',
      maxHeightFraction: 0.65,
      child: const FilterBottomSheet(),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late final InformasiController _ctrl;
  String? _selectedCategoryId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<InformasiController>();
    _selectedCategoryId = _ctrl.selectedCategoryId.value;
    _fromDate = _ctrl.dateRange.value?.start;
    _toDate = _ctrl.dateRange.value?.end;
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate != null && _toDate!.isBefore(picked)) _toDate = picked;
      } else {
        _toDate = picked;
        if (_fromDate != null && _fromDate!.isAfter(picked)) _fromDate = picked;
      }
    });
  }

  void _apply() {
    _ctrl.selectCategory(_selectedCategoryId);
    if (_fromDate != null && _toDate != null) {
      _ctrl.applyDateRange(DateTimeRange(start: _fromDate!, end: _toDate!));
    } else {
      _ctrl.applyDateRange(null);
    }
    Navigator.of(context).pop();
  }

  void _reset() {
    setState(() {
      _selectedCategoryId = null;
      _fromDate = null;
      _toDate = null;
    });
    _ctrl.resetFilters();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Kategori ---
        Text(
          'Kategori',
          style: typography.labelLarge.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.s12.h),
        Wrap(
          spacing: AppSpacing.s8.w,
          runSpacing: AppSpacing.s8.h,
          children: [
            AppChip(
              label: 'Semua',
              isSelected: _selectedCategoryId == null,
              onSelected: (_) => setState(() => _selectedCategoryId = null),
            ),
            ..._ctrl.categories.map((cat) => AppChip(
                  label: cat.name,
                  icon: cat.icon,
                  isSelected: _selectedCategoryId == cat.id,
                  onSelected: (_) =>
                      setState(() => _selectedCategoryId = cat.id),
                )),
          ],
        ),

        SizedBox(height: AppSpacing.s24.h),

        // --- Tanggal ---
        Text(
          'Rentang Tanggal',
          style: typography.labelLarge.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: AppSpacing.s12.h),
        Row(
          children: [
            Expanded(
              child: _DatePicker(
                label: 'Dari',
                date: _fromDate,
                colors: colors,
                typography: typography,
                onTap: () => _pickDate(isFrom: true),
              ),
            ),
            SizedBox(width: AppSpacing.s12.w),
            Expanded(
              child: _DatePicker(
                label: 'Sampai',
                date: _toDate,
                colors: colors,
                typography: typography,
                onTap: () => _pickDate(isFrom: false),
              ),
            ),
          ],
        ),

        SizedBox(height: AppSpacing.s32.h),

        // --- Actions ---
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Reset',
                style: AppButtonStyle.outlined,
                onPressed: _reset,
              ),
            ),
            SizedBox(width: AppSpacing.s12.w),
            Expanded(
              child: AppButton(
                label: 'Terapkan',
                onPressed: _apply,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime? date;
  final AppColors colors;
  final AppTypography typography;
  final VoidCallback onTap;

  const _DatePicker({
    required this.label,
    required this.date,
    required this.colors,
    required this.typography,
    required this.onTap,
  });

  String get _displayText {
    if (date == null) return 'Pilih tanggal';
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${date!.day} ${months[date!.month]} ${date!.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    final borderColor = hasDate ? colors.primary : colors.outline.withValues(alpha: 0.3);
    final contentColor = hasDate ? colors.primary : colors.onSurface.withValues(alpha: 0.4);

    return Material(
      color: hasDate ? colors.primary.withValues(alpha: 0.05) : Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.r8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.r8),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s12.w,
            vertical: AppSpacing.s12.h,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(AppRadius.r8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: typography.caption.copyWith(
                  color: contentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 10.sp,
                ),
              ),
              SizedBox(height: AppSpacing.s4.h),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 12.sp, color: contentColor),
                  SizedBox(width: AppSpacing.s4.w),
                  Expanded(
                    child: Text(
                      _displayText,
                      style: typography.bodySmall.copyWith(
                        color: contentColor,
                        fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
