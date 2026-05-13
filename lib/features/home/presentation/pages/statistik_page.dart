import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../design_system/components/organisms/app_top_app_bar.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../widgets/cuti_stat_card.dart';
import '../widgets/monthly_stats_card.dart';
import '../widgets/tpp_stat_card.dart';

class StatistikPage extends StatelessWidget {
  const StatistikPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopAppBar(
        title: 'Statistik',
        variant: AppTopAppBarVariant.withBack,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s16.w,
          vertical: AppSpacing.s16.h,
        ),
        child: Column(
          children: [
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
  }
}
