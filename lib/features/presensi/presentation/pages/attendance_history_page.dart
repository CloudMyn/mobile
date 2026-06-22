import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_button.dart';
import '../../../../design_system/components/app_card.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/repositories/attendance_history_repository.dart';
import '../controllers/attendance_history_controller.dart';
import '../widgets/attendance_day_tile.dart';
import '../widgets/attendance_month_switcher.dart';
import '../widgets/attendance_summary_pie_chart.dart';

class AttendanceHistoryPage extends StatefulWidget {
  const AttendanceHistoryPage({super.key});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  static const _tag = 'attendance_history_page';
  late final AttendanceHistoryController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(
      AttendanceHistoryController(
        repository: Get.find<AttendanceHistoryRepository>(),
      ),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<AttendanceHistoryController>(tag: _tag)) {
      Get.delete<AttendanceHistoryController>(tag: _tag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const AppTopAppBar(
        title: 'List Presensi',
        variant: AppTopAppBarVariant.withBack,
        centerTitle: false,
      ),
      body: Obx(() {
        final summary = _controller.summary.value;
        final isInitialLoading =
            _controller.isLoading.value && _controller.items.isEmpty;
        final hasError = _controller.errorMessage.value != null &&
            _controller.items.isEmpty;

        if (isInitialLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (hasError) {
          return _buildErrorState(context);
        }

        return RefreshIndicator(
          onRefresh: _controller.loadMonth,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s16.w,
              AppSpacing.s12.h,
              AppSpacing.s16.w,
              AppSpacing.s32.h,
            ),
            children: [
              AttendanceMonthSwitcher(
                label: _controller.monthLabel,
                canGoPrev: _controller.canGoPrev,
                canGoNext: _controller.canGoNext,
                onPrev: _controller.goToPrevMonth,
                onNext: _controller.goToNextMonth,
              ),
              SizedBox(height: AppSpacing.s12.h),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tanggal Bulan Ini',
                      style: typography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4.h),
                    Text(
                      'Menampilkan tanggal 1 sampai akhir bulan dalam tahun berjalan ${_controller.currentYear}.',
                      style: typography.bodySmall.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.64),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.s12.h),
              ..._controller.items.map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.s8.h),
                  child: AttendanceDayTile(item: item),
                ),
              ),
              SizedBox(height: AppSpacing.s12.h),
              if (summary != null) AttendanceSummaryPieChart(summary: summary),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.s16.w),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 44.sp,
                color: colors.error,
              ),
              SizedBox(height: AppSpacing.s12.h),
              Text(
                'Riwayat presensi gagal dimuat',
                style: typography.titleSmall.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.s8.h),
              Text(
                _controller.errorMessage.value ?? 'Terjadi kesalahan.',
                style: typography.bodySmall.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.62),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.s16.h),
              AppButton(
                label: 'Coba Lagi',
                onPressed: _controller.loadMonth,
                icon: Icons.refresh_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
