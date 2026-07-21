import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../controllers/report_viewer_controller.dart';

class ReportFilterBottomSheet extends StatefulWidget {
  const ReportFilterBottomSheet({
    super.key,
    required this.controller,
  });

  final ReportViewerController controller;

  @override
  State<ReportFilterBottomSheet> createState() =>
      _ReportFilterBottomSheetState();
}

class _ReportFilterBottomSheetState extends State<ReportFilterBottomSheet> {
  late int _selectedYear;
  late int _selectedMonth;
  late String _selectedScope;

  final List<String> _monthNames = const [
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

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.controller.selectedYear.value;
    _selectedMonth = widget.controller.selectedMonth.value;
    _selectedScope = widget.controller.selectedScope.value;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;
    final isAttendance =
        widget.controller.reportType.value == ReportType.attendance;

    final currentYear = DateTime.now().year;
    final years = List.generate(
      currentYear - 2020 + 1,
      (index) => currentYear - index,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s20.w,
        vertical: AppSpacing.s16.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.r20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.s16.h),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Laporan',
                  style: typography.titleMedium.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            SizedBox(height: AppSpacing.s16.h),

            // Year selection
            Text(
              'Tahun',
              style: typography.labelLarge.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.s8.h),
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: years.length,
                separatorBuilder: (_, __) => SizedBox(width: AppSpacing.s8.w),
                itemBuilder: (context, index) {
                  final yr = years[index];
                  final isSelected = yr == _selectedYear;
                  return ChoiceChip(
                    label: Text('$yr'),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedYear = yr);
                    },
                    selectedColor: colors.primary.withValues(alpha: 0.15),
                    labelStyle: typography.bodyMedium.copyWith(
                      color: isSelected ? colors.primary : colors.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.s16.h),

            // Month selection
            Text(
              'Bulan',
              style: typography.labelLarge.copyWith(
                color: colors.onSurface.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.s8.h),
            SizedBox(
              height: 40.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 12,
                separatorBuilder: (_, __) => SizedBox(width: AppSpacing.s8.w),
                itemBuilder: (context, index) {
                  final m = index + 1;
                  final isSelected = m == _selectedMonth;
                  return ChoiceChip(
                    label: Text(_monthNames[m]),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedMonth = m);
                    },
                    selectedColor: colors.primary.withValues(alpha: 0.15),
                    labelStyle: typography.bodyMedium.copyWith(
                      color: isSelected ? colors.primary : colors.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: AppSpacing.s16.h),

            // Scope selection (Attendance only)
            if (isAttendance) ...[
              Text(
                'Cakupan Laporan',
                style: typography.labelLarge.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: AppSpacing.s8.h),
              Row(
                children: [
                  Expanded(
                    child: _ScopeOptionChip(
                      label: 'Bulanan',
                      value: 'monthly',
                      selectedValue: _selectedScope,
                      colors: colors,
                      typography: typography,
                      onTap: () => setState(() => _selectedScope = 'monthly'),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  Expanded(
                    child: _ScopeOptionChip(
                      label: 'Mingguan',
                      value: 'weekly',
                      selectedValue: _selectedScope,
                      colors: colors,
                      typography: typography,
                      onTap: () => setState(() => _selectedScope = 'weekly'),
                    ),
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  Expanded(
                    child: _ScopeOptionChip(
                      label: 'Harian',
                      value: 'daily',
                      selectedValue: _selectedScope,
                      colors: colors,
                      typography: typography,
                      onTap: () => setState(() => _selectedScope = 'daily'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.s20.h),
            ],

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  widget.controller.updateFilters(
                    year: _selectedYear,
                    month: _selectedMonth,
                    scope: _selectedScope,
                  );
                  Get.back();
                },
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Terapkan Filter'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r12),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.s12.h),
          ],
        ),
      ),
    );
  }
}

class _ScopeOptionChip extends StatelessWidget {
  const _ScopeOptionChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.colors,
    required this.typography,
    required this.onTap,
  });

  final String label;
  final String value;
  final String selectedValue;
  final AppColors colors;
  final AppTypography typography;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.s10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.12)
              : colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r8),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: typography.bodyMedium.copyWith(
            color: isSelected ? colors.primary : colors.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
