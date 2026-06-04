import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../design_system/components/feedback/app_dialog.dart';
import '../../../../design_system/tokens/app_colors.dart';
import '../../../../design_system/tokens/app_icon_size.dart';
import '../../../../design_system/tokens/app_spacing.dart';
import '../../../../design_system/tokens/app_typography.dart';
import '../../data/models/notification_item.dart';
import '../controllers/notification_controller.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: controller.isMarkingAllRead.value
                  ? SizedBox(
                      width: AppIconSize.lg,
                      height: AppIconSize.lg,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.done_all_rounded),
              iconSize: AppIconSize.lg,
              tooltip: 'Tandai semua dibaca',
              onPressed:
                  controller.notifications.isEmpty ||
                      controller.unreadCount == 0 ||
                      controller.isMarkingAllRead.value
                  ? null
                  : controller.markAllAsRead,
            ),
          ),
          Obx(
            () => IconButton(
              icon: controller.isDeletingAll.value
                  ? SizedBox(
                      width: AppIconSize.lg,
                      height: AppIconSize.lg,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_sweep_outlined),
              iconSize: AppIconSize.lg,
              tooltip: 'Hapus semua',
              onPressed:
                  controller.notifications.isEmpty ||
                      controller.isDeletingAll.value
                  ? null
                  : () => _confirmDeleteAll(controller),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadNotifications,
          child: controller.notifications.isEmpty
              ? _buildEmptyState(colors, typography)
              : _buildNotificationList(controller, colors, typography),
        );
      }),
    );
  }

  Widget _buildEmptyState(AppColors colors, AppTypography typography) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 180.h),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: AppIconSize.xxl * 1.5,
                color: colors.onSurface.withValues(alpha: 0.3),
              ),
              SizedBox(height: AppSpacing.s16.h),
              Text(
                'Belum ada notifikasi',
                style: typography.titleMedium.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              SizedBox(height: AppSpacing.s8.h),
              Text(
                'Tarik ke bawah untuk memuat ulang notifikasi.',
                style: typography.bodySmall.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationList(
    NotificationController controller,
    AppColors colors,
    AppTypography typography,
  ) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s16.w,
        vertical: AppSpacing.s12.h,
      ),
      itemCount: controller.notifications.length,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        indent: AppSpacing.s48,
        color: colors.outline.withValues(alpha: 0.15),
      ),
      itemBuilder: (context, index) {
        final notification = controller.notifications[index];
        return _NotificationTile(
          notification: notification,
          isProcessing: controller.isProcessing(notification.id),
          onTap: () => controller.openNotification(notification),
          colors: colors,
          typography: typography,
        );
      },
    );
  }

  Future<void> _confirmDeleteAll(NotificationController controller) async {
    final confirmed = await AppDialog.confirm(
      title: 'Hapus Semua Notifikasi',
      message:
          'Apakah Anda yakin ingin menghapus semua notifikasi? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDestructive: true,
    );

    if (confirmed == true) {
      await controller.deleteAllNotifications();
    }
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isProcessing,
    required this.onTap,
    required this.colors,
    required this.typography,
  });

  final NotificationItem notification;
  final bool isProcessing;
  final VoidCallback onTap;
  final AppColors colors;
  final AppTypography typography;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: isProcessing ? null : onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.s4,
            vertical: AppSpacing.s12.h,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NotificationLeading(notification: notification, colors: colors),
              SizedBox(width: AppSpacing.s12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: typography.titleSmall.copyWith(
                        color: colors.onSurface,
                        fontWeight: notification.isRead
                            ? FontWeight.w500
                            : FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.s4.h),
                    Text(
                      notification.message,
                      style: typography.bodySmall.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    if ((notification.summary ?? '').isNotEmpty) ...[
                      SizedBox(height: AppSpacing.s4.h),
                      Text(
                        notification.summary!,
                        style: typography.labelSmall.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                    SizedBox(height: AppSpacing.s8.h),
                    Text(
                      _formatRelativeTime(notification.createdAt),
                      style: typography.caption.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.s8.w),
              isProcessing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colors.onSurface.withValues(alpha: 0.35),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${difference.inDays ~/ 7} minggu lalu';
    }
  }
}

class _NotificationLeading extends StatelessWidget {
  const _NotificationLeading({
    required this.notification,
    required this.colors,
  });

  final NotificationItem notification;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final iconColor = _resolveIconColor();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _resolveIconData(notification.icon, notification.category),
            size: 18,
            color: iconColor,
          ),
        ),
        if (!notification.isRead)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors.success,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }

  Color _resolveIconColor() {
    return switch (notification.category) {
      'submission' => colors.primary,
      'attendance' => colors.success,
      'system' => colors.warning,
      _ => colors.onSurface.withValues(alpha: 0.8),
    };
  }

  IconData _resolveIconData(String icon, String category) {
    final key = icon.toLowerCase();
    if (key.contains('download')) return Icons.download_rounded;
    if (key.contains('upload')) return Icons.upload_rounded;
    if (key.contains('triangle-alert') || key.contains('alert')) {
      return Icons.warning_amber_rounded;
    }
    if (key.contains('check-circle')) return Icons.check_circle_rounded;
    if (key.contains('bell')) return Icons.notifications_rounded;

    return switch (category) {
      'submission' => Icons.description_rounded,
      'attendance' => Icons.fingerprint_rounded,
      'system' => Icons.notifications_rounded,
      _ => Icons.notifications_rounded,
    };
  }
}
