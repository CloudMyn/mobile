import 'package:get/get.dart';
import '../../data/models/notification_item.dart';
import 'home_controller.dart';

/// Controller untuk halaman notifikasi.
///
/// Mengelola daftar notifikasi, mark all as read, dan delete all.
/// Juga menyinkronkan [HomeController.unreadNotifications] agar badge
/// di icon bell tetap terupdate.
class NotificationController extends GetxController {
  // =========================================================================
  //  Reactive State
  // =========================================================================

  /// Daftar notifikasi.
  final notifications = <NotificationItem>[].obs;

  /// Loading state saat memuat data.
  final isLoading = false.obs;

  // =========================================================================
  //  Computed
  // =========================================================================

  /// Jumlah notifikasi yang belum dibaca.
  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  // =========================================================================
  //  Lifecycle
  // =========================================================================

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  // =========================================================================
  //  Actions
  // =========================================================================

  /// Memuat data notifikasi (mock).
  Future<void> loadNotifications() async {
    isLoading.value = true;

    // Simulasi delay network
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();

    notifications.value = [
      NotificationItem(
        id: '1',
        title: 'Presensi Masuk',
        body: 'Anda telah check-in pukul 07:30',
        createdAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
        type: 'attendance',
      ),
      NotificationItem(
        id: '2',
        title: 'Pengajuan Cuti Disetujui',
        body: 'Pengajuan cuti Anda pada 10-12 Mei telah disetujui',
        createdAt: now.subtract(const Duration(hours: 5)),
        isRead: true,
        type: 'submission',
      ),
      NotificationItem(
        id: '3',
        title: 'Jadwal Presensi Besok',
        body: 'Shift: Pagi (07:30 - 16:00)',
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
        type: 'system',
      ),
      NotificationItem(
        id: '4',
        title: 'TPP Bulan April Dirilis',
        body: 'TPP bulan April 2026 telah dirilis. Cek detailnya sekarang.',
        createdAt: now.subtract(const Duration(days: 3)),
        isRead: false,
        type: 'system',
      ),
      NotificationItem(
        id: '5',
        title: 'Rapat Koordinasi',
        body: 'Rapat koordinasi besok pukul 09:00 di Aula Kantor.',
        createdAt: now.subtract(const Duration(days: 4)),
        isRead: true,
        type: 'system',
      ),
      NotificationItem(
        id: '6',
        title: 'Pengumuman Libur Nasional',
        body: 'Tanggal 1 Juni 2026 libur nasional (Hari Lahir Pancasila).',
        createdAt: now.subtract(const Duration(days: 7)),
        isRead: false,
        type: 'system',
      ),
    ];

    _syncUnreadToHomeController();

    isLoading.value = false;
  }

  /// Menandai semua notifikasi sebagai sudah dibaca.
  void markAllAsRead() {
    notifications.value = notifications
        .map((n) => n.copyWith(isRead: true))
        .toList();
    _syncUnreadToHomeController();
  }

  /// Menghapus semua notifikasi.
  void deleteAllNotifications() {
    notifications.clear();
    _syncUnreadToHomeController();
  }

  // =========================================================================
  //  Internal
  // =========================================================================

  /// Sinkronisasi jumlah notifikasi belum dibaca ke [HomeController].
  void _syncUnreadToHomeController() {
    final homeController = Get.find<HomeController>();
    homeController.unreadNotifications.value = unreadCount;
  }
}
