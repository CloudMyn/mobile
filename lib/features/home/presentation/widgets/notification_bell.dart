import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_icon_size.dart';
import '../controllers/home_controller.dart';
import '../pages/notification_page.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    final colors = Theme.of(context).extension<AppColors>()!;

    return Obx(
      () => Stack(
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            iconSize: AppIconSize.lg,
            color: colors.onSurface,
            onPressed: () {
              Get.to(() => const NotificationPage());
            },
          ),
          if (controller.unreadNotifications.value > 0)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 14),
                child: Text(
                  controller.unreadNotifications.value > 9
                      ? '9+'
                      : '${controller.unreadNotifications.value}',
                  style: TextStyle(
                    color: colors.onError,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
