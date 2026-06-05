import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/molecules/app_empty_state.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_radius.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/monthly_activity_stats.dart';
import '../controllers/kinerja_statistik_controller.dart';

class KinerjaStatistikPage extends StatefulWidget {
  const KinerjaStatistikPage({super.key});

  @override
  State<KinerjaStatistikPage> createState() => _KinerjaStatistikPageState();
}

class _KinerjaStatistikPageState extends State<KinerjaStatistikPage> {
  final KinerjaStatistikController _controller =
      Get.find<KinerjaStatistikController>();

  final List<String> _months = [
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppTopAppBar(
        title: 'Statistik Kinerja',
        variant: AppTopAppBarVariant.withBack,
        centerTitle: true,
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = _controller.stats.value;
        if (stats == null) {
          return const Center(child: Text('Gagal memuat data statistik'));
        }

        final categories = stats.activitiesByCategory;
        final total = stats.totalActivities;

        return SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.s16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilterRow(colors, typography),
              SizedBox(height: AppSpacing.s16.h),
              _buildTargetBulananCard(stats, colors, typography),
              SizedBox(height: AppSpacing.s24.h),
              if (total == 0)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  child: const AppEmptyState(
                    icon: Icons.bar_chart_rounded,
                    title: 'Belum Ada Data',
                    subtitle: 'Tidak ada kinerja pada bulan yang dipilih.',
                  ),
                )
              else ...[
                // ── Pie Chart ───────────────────────────────
                AppCard(
                  outlined: true,
                  padding: EdgeInsets.all(AppSpacing.s20.w),
                  child: Column(
                    children: [
                      Text(
                        'Total Kinerja',
                        style: typography.titleSmall.copyWith(
                          color: colors.onSurface,
                        ),
                      ),
                      SizedBox(height: AppSpacing.s4.h),
                      Text(
                        '$total Kegiatan',
                        style: typography.titleLarge.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.s32.h),
                      SizedBox(
                        height: 220.h,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 50.r,
                            sections: _generateChartSections(
                              categories,
                              colors,
                              typography,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: AppSpacing.s32.h),
                      _buildLegend(categories, colors, typography),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterRow(AppColors colors, AppTypography typography) {
    final currentYear = DateTime.now().year;
    final years = [currentYear - 1, currentYear, currentYear + 1];

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12.w),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r8),
              border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _controller.selectedMonth.value,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.onSurface,
                ),
                items: List.generate(12, (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text(
                      _months[index],
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  );
                }),
                onChanged: (val) {
                  if (val != null) {
                    _controller.updateFilter(
                      val,
                      _controller.selectedYear.value,
                    );
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.s12.w),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.s12.w),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.r8),
              border: Border.all(color: colors.outline.withValues(alpha: 0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _controller.selectedYear.value,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colors.onSurface,
                ),
                items: years.map((y) {
                  return DropdownMenuItem(
                    value: y,
                    child: Text(
                      y.toString(),
                      style: typography.bodyMedium.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _controller.updateFilter(
                      _controller.selectedMonth.value,
                      val,
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generateChartSections(
    Map<String, int> data,
    AppColors colors,
    AppTypography typography,
  ) {
    final Map<String, Color> colorPalette = {
      'Kegiatan Kedinasan': colors.primary,
      'Pelayanan Masyarakat': colors.secondary,
      'Rapat Koordinasi': colors.success,
      'Bimbingan Teknis': colors.warning,
      'Kegiatan Lainnya': colors.error,
    };

    final paletteColors = [
      colors.primary,
      colors.secondary,
      colors.success,
      colors.warning,
      colors.error,
      colors.outline,
    ];

    List<PieChartSectionData> sections = [];
    int i = 0;

    data.forEach((key, value) {
      if (value > 0) {
        final color =
            colorPalette[key] ?? paletteColors[i % paletteColors.length];
        sections.add(
          PieChartSectionData(
            color: color,
            value: value.toDouble(),
            title: '$value',
            radius: 40.r,
            titleStyle: typography.labelLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
        i++;
      }
    });

    return sections;
  }

  Widget _buildLegend(
    Map<String, int> data,
    AppColors colors,
    AppTypography typography,
  ) {
    final Map<String, Color> colorPalette = {
      'Kegiatan Kedinasan': colors.primary,
      'Pelayanan Masyarakat': colors.secondary,
      'Rapat Koordinasi': colors.success,
      'Bimbingan Teknis': colors.warning,
      'Kegiatan Lainnya': colors.error,
    };

    final paletteColors = [
      colors.primary,
      colors.secondary,
      colors.success,
      colors.warning,
      colors.error,
      colors.outline,
    ];

    int i = 0;
    return Column(
      children: data.entries.map((entry) {
        if (entry.value == 0) return const SizedBox.shrink();

        final color =
            colorPalette[entry.key] ?? paletteColors[i % paletteColors.length];
        i++;

        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
          child: Row(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: AppSpacing.s8.w),
              Expanded(
                child: Text(
                  entry.key,
                  style: typography.bodyMedium.copyWith(
                    color: colors.onSurface,
                  ),
                ),
              ),
              Text(
                '${entry.value}',
                style: typography.labelLarge.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTargetBulananCard(
    MonthlyActivityStats stats,
    AppColors colors,
    AppTypography typography,
  ) {
    return AppCard(
      outlined: true,
      padding: EdgeInsets.all(AppSpacing.s16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.track_changes_rounded,
                size: 16,
                color: colors.warning,
              ),
              SizedBox(width: AppSpacing.s8.w),
              Text(
                'Target Bulanan',
                style: typography.labelLarge.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${stats.totalActivities} / ${stats.target} Kegiatan',
                style: typography.bodyMedium.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(stats.progressPercent * 100).round()}%',
                style: typography.labelLarge.copyWith(
                  color: stats.progressPercent >= 1.0
                      ? colors.success
                      : colors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.s8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.r4),
            child: LinearProgressIndicator(
              value: stats.progressPercent,
              minHeight: 6.h,
              backgroundColor: colors.outline.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                stats.progressPercent >= 1.0
                    ? colors.success
                    : colors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
