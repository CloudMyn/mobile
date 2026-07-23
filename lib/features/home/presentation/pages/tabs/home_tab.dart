import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../design_system/tokens/app_spacing.dart';
import '../../controllers/home_controller.dart';
import '../../widgets/attendance_card.dart';
import '../../widgets/date_time_widget.dart';
import '../../widgets/notification_bell.dart';
import '../../widgets/quick_action_grid.dart';
import '../../widgets/running_text_link_card.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return RefreshIndicator(
      onRefresh: () => homeController.refreshData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s12.w,
          vertical: AppSpacing.s12.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const NotificationBell(),
                const DateTimeWidget(),
              ],
            ),
            SizedBox(height: AppSpacing.s8.h),
            const AttendanceCard(),
            SizedBox(height: AppSpacing.s16.h),
            const QuickActionGrid(),
            SizedBox(height: AppSpacing.s24.h),
            // ── Running Text Link Card ───────────────────────────
            const RunningTextLinkCard(),
            SizedBox(height: AppSpacing.s32.h),
          ],
        ),
      ),
    );
  }
}

