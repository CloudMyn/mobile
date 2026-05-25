import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/services/statistik_service.dart';
import '../controllers/statistik_controller.dart';
import '../widgets/cuti_stat_card.dart';
import '../widgets/monthly_stats_card.dart';
import '../widgets/tpp_stat_card.dart';

class StatistikPage extends StatefulWidget {
  const StatistikPage({super.key});

  @override
  State<StatistikPage> createState() => _StatistikPageState();
}

class _StatistikPageState extends State<StatistikPage> {
  late final StatistikController _ctrl;

  @override
  void initState() {
    super.initState();
    // Gunakan controller yang sudah ada (fenix) atau buat baru jika belum ada
    _ctrl = Get.isRegistered<StatistikController>()
        ? Get.find<StatistikController>()
        : Get.put(
            StatistikController(service: Get.find<StatistikService>()),
            permanent: false,
          );

    // Muat data segar setiap kali halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ctrl.loadStatistik();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      appBar: const AppTopAppBar(
        title: 'Statistik',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_ctrl.errorMessage.value != null) {
          return _ErrorView(
            message: _ctrl.errorMessage.value!,
            onRetry: _ctrl.refresh,
            colors: colors,
            typography: typography,
          );
        }

        return RefreshIndicator(
          onRefresh: _ctrl.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.s16.w,
              vertical: AppSpacing.s12.h,
            ),
            child: Column(
              children: [
                _PeriodSelector(ctrl: _ctrl, colors: colors, typography: typography),
                SizedBox(height: AppSpacing.s16.h),
                const TppStatCard(),
                SizedBox(height: AppSpacing.s12.h),
                const MonthlyStatsCard(),
                SizedBox(height: AppSpacing.s12.h),
                const CutiStatCard(),
                SizedBox(height: AppSpacing.s32.h),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ── Period Selector ───────────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.ctrl,
    required this.colors,
    required this.typography,
  });

  final StatistikController ctrl;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // periodLabel membaca data.value (reactive) → rebuild saat data load
      final label = ctrl.data.value?.period.label ??
          '${_monthName(ctrl.selectedMonth.value)} ${ctrl.selectedYear.value}';

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s4.w,
          vertical: AppSpacing.s4.h,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.s12),
          border: Border.all(color: colors.outline.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: ctrl.isLoading.value ? null : ctrl.goToPreviousMonth,
              color: colors.onSurface,
              iconSize: 20,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Text(
                label,
                style: typography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: (ctrl.canGoNext && !ctrl.isLoading.value)
                  ? ctrl.goToNextMonth
                  : null,
              color: ctrl.canGoNext
                  ? colors.onSurface
                  : colors.outline.withValues(alpha: 0.3),
              iconSize: 20,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );
    });
  }

  String _monthName(int m) => const [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
      ][m];
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({
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
            Icon(Icons.signal_wifi_off_rounded, size: 48, color: colors.outline),
            SizedBox(height: AppSpacing.s16.h),
            Text(
              message,
              style: typography.bodyMedium.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.s24.h),
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
