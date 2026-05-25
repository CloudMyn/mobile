import 'dart:async';
import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/session_manager.dart';
import '../../../../design_system/components/feedback/app_dialog.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/models/tpp_statistic.dart';
import '../../data/models/monthly_attendance.dart';
import '../../data/models/leave_quota.dart';
import '../../data/services/dashboard_service.dart';

class HomeController extends GetxController {
  HomeController({required DashboardService dashboardService})
      : _dashboardService = dashboardService;

  final DashboardService _dashboardService;

  // =========================================================================
  //  Reactive State
  // =========================================================================

  final currentDateTime = DateTime.now().obs;
  final unreadNotifications = 0.obs;

  // Dashboard data dari API
  final dashboardData = Rx<DashboardModel?>(null);
  final todaySchedule = Rx<TodaySchedule?>(null);
  final attendanceTypes = <AttendanceTypeConfig>[].obs;
  final tppStatistic = Rx<TppStatistic?>(null);
  final monthlyAttendance = Rx<MonthlyAttendance?>(null);
  final pendingSubmission = Rx<DashboardPendingSubmission?>(null);

  // Kept for backward compat with CutiStatCard — populated lazily
  final leaveQuota = Rx<LeaveQuota?>(null);

  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  Timer? _clockTimer;

  @override
  void onInit() {
    super.onInit();
    _startClock();
    loadDashboard();
  }

  @override
  void onClose() {
    _clockTimer?.cancel();
    super.onClose();
  }

  // =========================================================================
  //  Clock
  // =========================================================================

  void _startClock() {
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      currentDateTime.value = DateTime.now();
    });
  }

  // =========================================================================
  //  Dashboard API
  // =========================================================================

  Future<void> loadDashboard() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final data = await _dashboardService.fetchDashboard();

      dashboardData.value = data;
      todaySchedule.value = data.todaySchedule;
      attendanceTypes.assignAll(data.attendanceTypes);
      pendingSubmission.value = data.pendingSubmission;

      if (data.currentTpp != null) {
        tppStatistic.value = TppStatistic.fromDashboard(data.currentTpp!);
      }

      // Update session user dengan data terkini dari dashboard
      Get.find<SessionManager>().setUser(data.user);
    } on NetworkException {
      errorMessage.value = 'Tidak ada koneksi internet.';
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'Gagal memuat data.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    await loadDashboard();
  }

  // =========================================================================
  //  Presensi Success — dipanggil oleh PresensiController setelah berhasil
  // =========================================================================

  /// Refresh schedule setelah presensi berhasil agar status slot diperbarui.
  Future<void> onPresensiSuccess() async {
    try {
      final updated = await _dashboardService.fetchTodayPresensi();
      todaySchedule.value = updated;
    } catch (_) {
      // Jika gagal refresh, tidak apa-apa — user bisa pull-to-refresh manual
    }
  }

  // =========================================================================
  //  Break — tidak memerlukan API call
  // =========================================================================

  Future<void> onBreakPressed(bool isStartBreak) async {
    final title = isStartBreak ? 'Mulai Istirahat' : 'Kembali dari Istirahat';
    final message = isStartBreak
        ? 'Apakah Anda ingin memulai waktu istirahat?'
        : 'Apakah Anda sudah kembali dari istirahat?';

    await AppDialog.confirm(
      title: title,
      message: message,
      confirmLabel: 'Ya',
      cancelLabel: 'Batal',
    );
  }

  // =========================================================================
  //  Convenience getters
  // =========================================================================

  List<TodayRecord> get pendingRecords =>
      todaySchedule.value?.records
          .where((r) => r.isPending && r.isWindowOpen)
          .toList() ??
      [];

  TodayRecord? get nextPendingRecord =>
      todaySchedule.value?.records.firstWhereOrNull((r) => r.isPending);
}
