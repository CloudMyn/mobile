import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/molecules/app_loading_overlay.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/session_manager.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../../../design_system/components/feedback/app_dialog.dart';
import '../../data/models/dashboard_model.dart';
import '../../data/models/tpp_statistic.dart';
import '../../data/models/monthly_attendance.dart';
import '../../data/models/leave_quota.dart';
import '../../data/services/dashboard_service.dart';
import '../../../presensi/data/models/attendance_config.dart';
import '../../../presensi/presentation/controllers/presensi_controller.dart';
import '../../../presensi/presentation/pages/presence_page.dart';
import '../../../kinerja/presentation/pages/kinerja_create_page.dart';

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
      unreadNotifications.value = data.unreadNotificationsCount;

      if (data.currentTpp != null) {
        tppStatistic.value = TppStatistic.fromDashboard(data.currentTpp!);
      }

      // Update session user dengan data terkini dari dashboard
      Get.find<SessionManager>().setUser(data.user);
    } on NetworkException catch (e, st) {
      print('loadDashboard NetworkException: $e\n$st');
      errorMessage.value = 'Tidak ada koneksi internet.';
    } on ApiException catch (e, st) {
      print('loadDashboard ApiException: $e\n$st');
      errorMessage.value = e.message;
    } catch (e, st) {
      print('loadDashboard Exception: $e\n$st');
      errorMessage.value = 'Gagal memuat data.';
    } finally {
      isLoading.value = false;
      if (errorMessage.value != null) {
        AppFeedback.showSnackbar(
          title: 'Gagal Memuat Dashboard',
          message: errorMessage.value!,
          isError: true,
        );
      }
    }
  }

  Future<void> refreshData() async {
    await loadDashboard();
  }

  // =========================================================================
  //  Presensi Validation & Trigger
  // =========================================================================

  Future<void> validateAndStartPresensi(TodayRecord record) async {
    if (!record.isWindowOpen) return;

    final schedule = todaySchedule.value;
    if (schedule == null) return;

    if (!record.attendanceType.isSkippable) {
      final records = schedule.records;
      final currentIndex = records.indexWhere((r) => r.id == record.id);

      if (currentIndex > 0) {
        final hasUncompletedPrevious = records
            .take(currentIndex)
            .any((r) => !r.isCompleted && !r.attendanceType.isSkippable);

        if (hasUncompletedPrevious) {
          AppDialog.info(
            title: 'Urutan Presensi',
            message:
                'Anda harus menyelesaikan presensi sebelumnya terlebih dahulu.',
          );
          return;
        }
      }
    }

    final dashboard = dashboardData.value;
    if (dashboard == null) return;

    final config = AttendanceConfig.fromDashboard(dashboard, record);
    Get.find<PresensiController>().setConfig(
      record,
      config,
      shiftNo: schedule.shiftNo,
    );
    Get.to(() => const PresencePage());
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

  Future<void> startWfh() async {
    try {
      AppLoadingOverlay.show('Memulai WFH...');
      await _dashboardService.startWfh();
      AppLoadingOverlay.hide();
      
      Get.snackbar(
        'Berhasil',
        'Presensi WFH telah dicatat.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
      );
      
      await loadDashboard();
      Get.to(() => const KinerjaCreatePage());
    } catch (e) {
      AppLoadingOverlay.hide();
      AppFeedback.showSnackbar(
        title: 'Gagal Memulai WFH',
        message: e is ApiException ? (e as ApiException).message : 'Terjadi kesalahan.',
        isError: true,
      );
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
