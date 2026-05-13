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

/// Halaman daftar notifikasi.
///
/// Menampilkan semua notifikasi dengan kemampuan:
/// - Menandai semua sebagai dibaca
/// - Menghapus semua notifikasi
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationController());
    final colors = Theme.of(context).extension<AppColors>()!;
    final typography = Theme.of(context).extension<AppTypography>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        centerTitle: true,
        actions: [
          // Tombol: Tandai Semua Dibaca
          Obx(
            () => IconButton(
              icon: const Icon(Icons.done_all_rounded),
              iconSize: AppIconSize.lg,
              tooltip: 'Tandai semua dibaca',
              onPressed: controller.notifications.isEmpty ||
                      controller.unreadCount == 0
                  ? null
                  : () => controller.markAllAsRead(),
            ),
          ),
          // Tombol: Hapus Semua
          Obx(
            () => IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              iconSize: AppIconSize.lg,
              tooltip: 'Hapus semua',
              onPressed: controller.notifications.isEmpty
                  ? null
                  : () => _confirmDeleteAll(controller, colors),
            ),
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.notifications.isEmpty) {
            return _buildEmptyState(colors, typography);
          }

          return _buildNotificationList(controller, colors, typography);
        },
      ),
    );
  }

  /// Tampilan ketika tidak ada notifikasi.
  Widget _buildEmptyState(AppColors colors, AppTypography typography) {
    return Center(
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
            'Notifikasi akan muncul di sini',
            style: typography.bodySmall.copyWith(
              color: colors.onSurface.withValues(alpha: 0.35),
            ),
          ),
        ],
      ),
    );
  }

  /// Daftar notifikasi.
  Widget _buildNotificationList(
    NotificationController controller,
    AppColors colors,
    AppTypography typography,
  ) {
    return ListView.separated(
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
          colors: colors,
          typography: typography,
        );
      },
    );
  }

  /// Menampilkan dialog konfirmasi hapus semua notifikasi.
  Future<void> _confirmDeleteAll(
    NotificationController controller,
    AppColors colors,
  ) async {
    final confirmed = await AppDialog.confirm(
      title: 'Hapus Semua Notifikasi',
      message:
          'Apakah Anda yakin ingin menghapus semua notifikasi? Tindakan ini tidak dapat dibatalkan.',
      confirmLabel: 'Hapus',
      cancelLabel: 'Batal',
      isDestructive: true,
    );

    if (confirmed == true) {
      controller.deleteAllNotifications();
    }
  }
}

/// Widget untuk satu item notifikasi.
class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;
  final AppColors colors;
  final AppTypography typography;

  const _NotificationTile({
    required this.notification,
    required this.colors,
    required this.typography,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s4,
        vertical: AppSpacing.s12.h,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indikator belum dibaca (dot hijau)
          Padding(
            padding: EdgeInsets.only(top: AppSpacing.s4.h),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: notification.isRead
                    ? Colors.transparent
                    : colors.success,
                shape: BoxShape.circle,
              ),
            ),
          ),
          SizedBox(width: AppSpacing.s12.w),

          // Konten notifikasi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul
                Text(
                  notification.title,
                  style: typography.titleSmall.copyWith(
                    color: colors.onSurface,
                    fontWeight:
                        notification.isRead
                            ? FontWeight.w500
                            : FontWeight.bold,
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),

                // Body
                Text(
                  notification.body,
                  style: typography.bodySmall.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                SizedBox(height: AppSpacing.s4.h),

                // Timestamp relatif
                Text(
                  _formatRelativeTime(notification.createdAt),
                  style: typography.caption.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format timestamp menjadi teks relatif (misal: "2 jam lalu").
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
