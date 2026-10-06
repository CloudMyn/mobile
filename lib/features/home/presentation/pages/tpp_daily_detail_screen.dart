import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/statistik_model.dart';
import '../../data/models/tpp_detail_model.dart';
import '../../data/services/statistik_service.dart';
import '../controllers/report_viewer_controller.dart';
import '../controllers/tpp_detail_controller.dart';
import 'report_viewer_page.dart';

class TppDailyDetailScreen extends StatefulWidget {
  const TppDailyDetailScreen({
    super.key,
    this.tpp,
    this.initialMonth,
    this.initialYear,
  });

  final StatistikTpp? tpp;
  final int? initialMonth;
  final int? initialYear;

  @override
  State<TppDailyDetailScreen> createState() => _TppDailyDetailScreenState();
}

class _TppDailyDetailScreenState extends State<TppDailyDetailScreen> {
  late final TppDetailController _controller;

  @override
  void initState() {
    super.initState();

    int? month = widget.initialMonth;
    int? year = widget.initialYear;

    if ((month == null || year == null) && widget.tpp != null) {
      final parts = widget.tpp!.periodDate.split('-');
      if (parts.length >= 2) {
        year ??= int.tryParse(parts[0]);
        month ??= int.tryParse(parts[1]);
      }
    }

    _controller = Get.put(
      TppDetailController(
        service: Get.find<StatistikService>(),
        initialMonth: month,
        initialYear: year,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          'Detail TPP',
          style: typography.titleMedium.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: colors.onSurface),
        actions: [
          TextButton.icon(
            onPressed: () {
              Get.to(
                () => const ReportViewerPage(),
                arguments: {
                  'reportType': ReportType.tpp,
                  'year': _controller.selectedYear.value,
                  'month': _controller.selectedMonth.value,
                },
              );
            },
            icon: Icon(Icons.picture_as_pdf_rounded,
                size: 16.w, color: colors.primary),
            label: Text(
              'Export PDF',
              style: typography.labelSmall.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s8.w),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Bar: Tahun & Bulan ─────────────────────────────────────
          _FilterSection(
            controller: _controller,
            colors: colors,
            typography: typography,
          ),

          // ── Main Content ──────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (_controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (_controller.errorMessage.value != null) {
                return _ErrorState(
                  message: _controller.errorMessage.value!,
                  onRetry: _controller.refreshData,
                  colors: colors,
                  typography: typography,
                );
              }

              final data = _controller.tppData.value;
              if (data == null) {
                return _EmptyState(colors: colors, typography: typography);
              }

              return RefreshIndicator(
                onRefresh: _controller.refreshData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.s16.w,
                    AppSpacing.s8.h,
                    AppSpacing.s16.w,
                    AppSpacing.s24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header Identitas Pegawai ─────────────────────────
                      _EmployeeIdentityHeader(
                        user: data.user,
                        period: data.period,
                        colors: colors,
                        typography: typography,
                      ),
                      SizedBox(height: AppSpacing.s12.h),

                      // ── Card 1: Disiplin Kerja (Bobot 40%) ───────────────
                      _DisiplinKerjaCard(
                        calc: data.calculation,
                        colors: colors,
                        typography: typography,
                      ),
                      SizedBox(height: AppSpacing.s12.h),

                      // ── Card 2: Kinerja Harian (Bobot 60%) ───────────────
                      _KinerjaHarianCard(
                        calc: data.calculation,
                        colors: colors,
                        typography: typography,
                      ),
                      SizedBox(height: AppSpacing.s12.h),

                      // ── Card 3: Ringkasan Total & Pajak PPh 21 ───────────
                      _RingkasanPenerimaanCard(
                        calc: data.calculation,
                        colors: colors,
                        typography: typography,
                      ),
                      SizedBox(height: AppSpacing.s20.h),

                      // ── Bagian Detail Potongan Harian ─────────────────────
                      Text(
                        'Detail Potongan Harian',
                        style: typography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: AppSpacing.s8.h),

                      if (data.dailyRecords.isEmpty)
                        _EmptyDailyState(colors: colors, typography: typography)
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.dailyRecords.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: AppSpacing.s8.h),
                          itemBuilder: (context, index) {
                            final record = data.dailyRecords[index];
                            return _DailyRecordItem(
                              index: index + 1,
                              record: record,
                              colors: colors,
                              typography: typography,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Filter Section ─────────────────────────────────────────────────────────────

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.controller,
    required this.colors,
    required this.typography,
  });

  final TppDetailController controller;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s16.w,
        vertical: AppSpacing.s12.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(
            color: colors.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Obx(() {
        final currentYear = controller.selectedYear.value;
        final currentMonth = controller.selectedMonth.value;

        return Row(
          children: [
            // Filter Tahun (Tahun Ini & Tahun Kemarin)
            Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12.w),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(AppRadius.r12),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16.sp,
                    color: colors.primary,
                  ),
                  SizedBox(width: AppSpacing.s8.w),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: currentYear,
                      isDense: false,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.onSurface),
                      dropdownColor: colors.surface,
                      style: typography.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                      items: controller.availableYears.map((y) {
                        return DropdownMenuItem<int>(
                          value: y,
                          child: Text('$y'),
                        );
                      }).toList(),
                      onChanged: (y) {
                        if (y != null) controller.changeYear(y);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSpacing.s12.w),

            // Filter Bulan
            Expanded(
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12.w),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(AppRadius.r12),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_rounded,
                      size: 18.sp,
                      color: colors.primary,
                    ),
                    SizedBox(width: AppSpacing.s8.w),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: currentMonth,
                          isExpanded: true,
                          isDense: false,
                          icon: Icon(Icons.keyboard_arrow_down_rounded, color: colors.onSurface),
                          dropdownColor: colors.surface,
                          style: typography.labelMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                          items: List.generate(12, (index) {
                            final m = index + 1;
                            return DropdownMenuItem<int>(
                              value: m,
                              child: Text(controller.monthNames[index]),
                            );
                          }),
                          onChanged: (m) {
                            if (m != null) controller.changeMonth(m);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ── Employee Identity Header ──────────────────────────────────────────────────

class _EmployeeIdentityHeader extends StatelessWidget {
  const _EmployeeIdentityHeader({
    required this.user,
    required this.period,
    required this.colors,
    required this.typography,
  });

  final TppUserInfo user;
  final TppPeriodInfo period;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final title = user.positionName != null && user.positionName!.isNotEmpty
        ? '${user.displayName.toUpperCase()} — ${user.positionName!.toUpperCase()}'
        : user.displayName.toUpperCase();

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: typography.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),
                Text(
                  'Data : ${period.periodLabel}',
                  style: typography.caption.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.s8.w),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s8.w,
              vertical: AppSpacing.s4.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.r8),
              border: Border.all(
                color: const Color(0xFF0284C7).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'NILAI TPP DITERIMA',
              style: typography.caption.copyWith(
                color: const Color(0xFF0284C7),
                fontWeight: FontWeight.bold,
                fontSize: 9.sp,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 1: Disiplin Kerja (Bobot 40%) ────────────────────────────────────────

class _DisiplinKerjaCard extends StatelessWidget {
  const _DisiplinKerjaCard({
    required this.calc,
    required this.colors,
    required this.typography,
  });

  final TppCalculationInfo calc;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final discScoreStr = calc.disciplineScore.truncateToDouble() == calc.disciplineScore
        ? '${calc.disciplineScore.toInt()}%'
        : '${calc.disciplineScore.toStringAsFixed(1)}%';

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disiplin Kerja',
                      style: typography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Porsi Pagu: 40% × ${TppCalculationInfo.formatRupiah(calc.paguJabatan)}',
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8.w,
                  vertical: AppSpacing.s4.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  border: Border.all(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'BOBOT 40%',
                  style: typography.caption.copyWith(
                    color: const Color(0xFF0284C7),
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s8.h),

          // Nilai Porsi Pagu Disiplin
          Text(
            TppCalculationInfo.formatRupiah(calc.dispPagu),
            style: typography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s10.h),
            child: Divider(
              color: colors.outline.withValues(alpha: 0.12),
              height: 1,
            ),
          ),

          // Skor Disiplin Presensi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skor Disiplin Presensi',
                style: typography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: (calc.disciplineScore >= 90
                          ? colors.success
                          : (calc.disciplineScore >= 70
                              ? const Color(0xFFD97706)
                              : colors.error))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                ),
                child: Text(
                  discScoreStr,
                  style: typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: calc.disciplineScore >= 90
                        ? colors.success
                        : (calc.disciplineScore >= 70
                            ? const Color(0xFFD97706)
                            : colors.error),
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s8.h),

          // Persentase rincian
          _PercentageRow(
            label: 'Persentase Tidak Hadir (Alpa) :',
            pct: calc.absentDeductionPct,
            colors: colors,
            typography: typography,
          ),
          SizedBox(height: 3.h),
          _PercentageRow(
            label: 'Persentase Terlambat Pagi :',
            pct: calc.lateDeductionPct,
            colors: colors,
            typography: typography,
          ),
          SizedBox(height: 3.h),
          _PercentageRow(
            label: 'Persentase Cepat Pulang :',
            pct: calc.earlyLeaveDeductionPct,
            colors: colors,
            typography: typography,
          ),
          if (calc.cutiDeductionPct > 0) ...[
            SizedBox(height: 3.h),
            _PercentageRow(
              label: 'Persentase Cuti :',
              pct: calc.cutiDeductionPct,
              colors: colors,
              typography: typography,
            ),
          ],
          SizedBox(height: 3.h),
          _PercentageRow(
            label: 'Total Potongan Kehadiran :',
            pct: calc.attendanceDeductionPct,
            colors: colors,
            typography: typography,
            isTotal: true,
          ),

          SizedBox(height: AppSpacing.s10.h),
          Container(
            padding: EdgeInsets.all(AppSpacing.s8.w),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(AppRadius.r8),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pagu 40% - Potongan Presensi',
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                        fontSize: 9.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${TppCalculationInfo.formatRupiah(calc.dispPagu)} - ${TppCalculationInfo.formatRupiah(calc.dispDedRp)}',
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  TppCalculationInfo.formatRupiah(calc.dispNet),
                  style: typography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PercentageRow extends StatelessWidget {
  const _PercentageRow({
    required this.label,
    required this.pct,
    required this.colors,
    required this.typography,
    this.isTotal = false,
  });

  final String label;
  final double pct;
  final AppColors colors;
  final AppTypography typography;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final pctStr = pct.truncateToDouble() == pct
        ? '${pct.toInt()}%'
        : '${pct.toStringAsFixed(2)}%';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: typography.caption.copyWith(
            color: colors.onSurface.withValues(alpha: isTotal ? 0.85 : 0.65),
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
            fontSize: 11.sp,
          ),
        ),
        Text(
          pctStr,
          style: typography.caption.copyWith(
            fontWeight: FontWeight.bold,
            color: pct > 0 ? colors.error : colors.onSurface,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
  }
}

// ── Card 2: Kinerja Harian (Bobot 60%) ────────────────────────────────────────

class _KinerjaHarianCard extends StatelessWidget {
  const _KinerjaHarianCard({
    required this.calc,
    required this.colors,
    required this.typography,
  });

  final TppCalculationInfo calc;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final actScoreStr = calc.activityScore.truncateToDouble() == calc.activityScore
        ? '${calc.activityScore.toInt()}%'
        : '${calc.activityScore.toStringAsFixed(1)}%';

    final isFullActivity = calc.activityScore >= 100;

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kinerja Harian',
                      style: typography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Porsi Pagu: 60% × ${TppCalculationInfo.formatRupiah(calc.paguJabatan)}',
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8.w,
                  vertical: AppSpacing.s4.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.r8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'BOBOT 60%',
                  style: typography.caption.copyWith(
                    color: const Color(0xFF10B981),
                    fontWeight: FontWeight.bold,
                    fontSize: 9.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s8.h),

          // Nilai Porsi Pagu Kinerja
          Text(
            TppCalculationInfo.formatRupiah(calc.actPagu),
            style: typography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s10.h),
            child: Divider(
              color: colors.outline.withValues(alpha: 0.12),
              height: 1,
            ),
          ),

          // Capaian Kinerja Harian
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Capaian Kinerja Harian',
                style: typography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: (isFullActivity ? colors.success : const Color(0xFFD97706))
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.r4),
                ),
                child: Text(
                  actScoreStr,
                  style: typography.caption.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isFullActivity ? colors.success : const Color(0xFFD97706),
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s8.h),

          // Baris keterpenuhan hari kerja
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Hari Kerja Disetujui :',
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.65),
                  fontSize: 11.sp,
                ),
              ),
              Text(
                '${calc.approvedDays} dari ${calc.workDays} hari',
                style: typography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          Text(
            '* Setiap hari kerja dengan min. 1 aktivitas disetujui dinilai 100%',
            style: typography.caption.copyWith(
              color: colors.onSurface.withValues(alpha: 0.45),
              fontSize: 9.sp,
              fontStyle: FontStyle.italic,
            ),
          ),

          SizedBox(height: AppSpacing.s10.h),
          Container(
            padding: EdgeInsets.all(AppSpacing.s8.w),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(AppRadius.r8),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pagu 60% × Skor Kinerja',
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                        fontSize: 9.sp,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$actScoreStr × ${TppCalculationInfo.formatRupiah(calc.actPagu)}',
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  TppCalculationInfo.formatRupiah(calc.actNet),
                  style: typography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card 3: Ringkasan Total & Pajak PPh 21 ─────────────────────────────────────

class _RingkasanPenerimaanCard extends StatelessWidget {
  const _RingkasanPenerimaanCard({
    required this.calc,
    required this.colors,
    required this.typography,
  });

  final TppCalculationInfo calc;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final taxRateStr = calc.taxRatePct.truncateToDouble() == calc.taxRatePct
        ? '${calc.taxRatePct.toInt()}%'
        : '${calc.taxRatePct.toStringAsFixed(1)}%';

    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ringkasan Penerimaan TPP',
            style: typography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          SizedBox(height: AppSpacing.s10.h),

          // Disiplin (40%)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Penerimaan Disiplin (40%)',
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                  fontSize: 11.sp,
                ),
              ),
              Text(
                TppCalculationInfo.formatRupiah(calc.dispNet),
                style: typography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),

          // Kinerja (60%)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Penerimaan Kinerja (60%)',
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                  fontSize: 11.sp,
                ),
              ),
              Text(
                TppCalculationInfo.formatRupiah(calc.actNet),
                style: typography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.onSurface,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s8.h),
            child: Divider(
              color: colors.outline.withValues(alpha: 0.12),
              height: 1,
            ),
          ),

          // Total TPP Bruto
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total TPP Bruto',
                style: typography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
              Text(
                TppCalculationInfo.formatRupiah(calc.grossRp),
                style: typography.bodySmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Potongan Pajak PPh 21
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Potongan Pajak PPh 21 ($taxRateStr)',
                style: typography.caption.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.7),
                  fontSize: 11.sp,
                ),
              ),
              Text(
                calc.taxDeductionRp > 0
                    ? '- ${TppCalculationInfo.formatRupiah(calc.taxDeductionRp)}'
                    : 'Rp 0',
                style: typography.caption.copyWith(
                  fontWeight: FontWeight.bold,
                  color: calc.taxDeductionRp > 0 ? colors.error : colors.onSurface,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.s12.h),

          // Highlight Card Cyan "NILAI TPP DITERIMA"
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s12.w,
              vertical: AppSpacing.s12.h,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.r8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00B4D8).withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'NILAI TPP DITERIMA',
                  style: typography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  TppCalculationInfo.formatRupiah(calc.finalTakeHomePayRp),
                  style: typography.titleSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ── Daily Record Item ─────────────────────────────────────────────────────────

class _DailyRecordItem extends StatelessWidget {
  const _DailyRecordItem({
    required this.index,
    required this.record,
    required this.colors,
    required this.typography,
  });

  final int index;
  final TppDailyRecordModel record;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    final dateObj = DateTime.tryParse(record.recordDate);
    final dateStr = dateObj != null
        ? DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(dateObj)
        : record.recordDate;

    final isOffday = !record.isWorkday;
    final discPct = record.disciplineDeductionPct;

    return AppCard(
      outlined: true,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s12.w,
        vertical: AppSpacing.s10.h,
      ),
      child: Row(
        children: [
          // Nomor urut
          Container(
            width: 24.w,
            alignment: Alignment.center,
            child: Text(
              '$index',
              style: typography.caption.copyWith(
                color: colors.outline,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s8.w),

          // Tanggal & Hari kerja
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dateStr,
                        style: typography.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      record.isWorkday
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 14.w,
                      color: record.isWorkday ? colors.success : colors.outline,
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    _StatusBadge(
                      status: record.attendanceStatus,
                      isWorkday: record.isWorkday,
                      colors: colors,
                      typography: typography,
                    ),
                    if (record.isWorkday) ...[
                      SizedBox(width: 4.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.s8.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: record.hasApprovedActivity
                              ? colors.success.withValues(alpha: 0.1)
                              : colors.outline.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.r4),
                        ),
                        child: Text(
                          record.hasApprovedActivity ? 'Kinerja ✓' : 'Tanpa Kinerja',
                          style: typography.caption.copyWith(
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w600,
                            color: record.hasApprovedActivity
                                ? colors.success
                                : colors.outline,
                          ),
                        ),
                      ),
                    ],
                    if (record.isWorkday &&
                        (record.totalLateMinutes > 0 ||
                            record.totalEarlyLeaveMinutes > 0)) ...[
                      SizedBox(width: 6.w),
                      Text(
                        'T: ${record.totalLateMinutes}m | PC: ${record.totalEarlyLeaveMinutes}m',
                        style: typography.caption.copyWith(
                          fontSize: 9.sp,
                          color: colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: AppSpacing.s8.w),

          // Potongan Disiplin
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Disiplin',
                style: typography.caption.copyWith(
                  fontSize: 9.sp,
                  color: colors.outline,
                ),
              ),
              Text(
                isOffday
                    ? '0.00%'
                    : (discPct > 0
                        ? '-${discPct.toStringAsFixed(2)}%'
                        : '0.00%'),
                style: typography.labelSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: discPct > 0 ? colors.error : colors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    required this.isWorkday,
    required this.colors,
    required this.typography,
  });

  final String? status;
  final bool isWorkday;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    String label = 'Hari Kerja';
    Color color = colors.outline;

    final s = status?.toLowerCase();
    if (s != null && s.isNotEmpty) {
      switch (s) {
        case 'present':
          label = 'Hadir';
          color = colors.success;
          break;
        case 'absent':
          label = 'Alpha';
          color = colors.error;
          break;
        case 'leave':
          label = 'Cuti';
          color = colors.primary;
          break;
        case 'sick':
          label = 'Sakit';
          color = colors.warning;
          break;
        case 'permit':
          label = 'Izin';
          color = const Color(0xFF0891B2);
          break;
        case 'offday':
          label = 'Hari Libur';
          color = colors.outline;
          break;
        case 'holiday':
          label = 'Libur Nasional';
          color = colors.outline;
          break;
        default:
          label = s.toUpperCase();
          color = colors.outline;
      }
    } else if (!isWorkday) {
      label = 'Libur';
      color = colors.outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s8.w,
        vertical: 1.h,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.r4),
      ),
      child: Text(
        label,
        style: typography.caption.copyWith(
          color: color,
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── States ────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors, required this.typography});

  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 56.w, color: colors.outline),
            SizedBox(height: AppSpacing.s16.h),
            Text(
              'Belum Ada Data TPP',
              style: typography.titleSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),
            SizedBox(height: AppSpacing.s8.h),
            Text(
              'Data TPP untuk periode ini belum tersedia atau belum dihitung oleh sistem.',
              style: typography.bodySmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.55),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDailyState extends StatelessWidget {
  const _EmptyDailyState({required this.colors, required this.typography});

  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.s24.w),
      alignment: Alignment.center,
      child: Text(
        'Belum ada rincian harian untuk periode ini.',
        style: typography.caption.copyWith(
          color: colors.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
    required this.colors,
    required this.typography,
  });

  final String message;
  final VoidCallback onRetry;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.signal_wifi_off_rounded,
                size: 48.w, color: colors.outline),
            SizedBox(height: AppSpacing.s16.h),
            Text(
              message,
              style: typography.bodySmall.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s16.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
