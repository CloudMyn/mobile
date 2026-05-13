import 'dart:async';
import 'package:get/get.dart';
import '../../../../design_system/components/feedback/app_dialog.dart';
import '../../../presensi/data/models/attendance_submission.dart';
import '../../data/models/attendance_schedule.dart';
import '../../data/models/leave_quota.dart';
import '../../data/models/monthly_attendance.dart';
import '../../data/models/tpp_statistic.dart';

/// Status alur presensi dalam satu hari kerja
enum AttendanceStatus { checkIn, break_, breakReturn, checkOut, completed }

class HomeController extends GetxController {
  // =========================================================================
  //  Reactive State
  // =========================================================================

  final currentDateTime = DateTime.now().obs;
  final unreadNotifications = 3.obs;
  final tppStatistic = Rx<TppStatistic?>(null);
  final schedule = Rx<AttendanceSchedule?>(null);
  final attendanceStatus = AttendanceStatus.checkIn.obs;
  final checkInTime = Rx<DateTime?>(null);
  final checkOutTime = Rx<DateTime?>(null);
  final monthlyAttendance = Rx<MonthlyAttendance?>(null);
  final leaveQuota = Rx<LeaveQuota?>(null);
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  Timer? _clockTimer;

  @override
  void onInit() {
    super.onInit();
    _startClock();
    loadAllData();
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
  //  Data Loading (Mock — ganti dengan API nyata)
  // =========================================================================

  Future<void> loadAllData() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      tppStatistic.value = const TppStatistic(
        totalAmount: 5_000_000,
        totalDeduction: 750_000,
        netResult: 4_250_000,
        period: 'Mei 2026',
      );

      schedule.value = const AttendanceSchedule(
        shiftName: 'Pagi',
        checkInTime: '07:30',
        checkOutTime: '16:00',
        status: ScheduleStatus.active,
      );

      monthlyAttendance.value = const MonthlyAttendance(
        present: 18,
        permission: 2,
        leave: 1,
        absent: 0,
        total: 22,
        month: 'Mei 2026',
      );

      leaveQuota.value = LeaveQuota(
        yearlyQuota: 12,
        usedThisYear: 5,
        prevYearQuota: 12,
        prevYearRemaining: 3,
        year: '2026',
        recentUsages: [
          LeaveUsage(
            type: 'Cuti Tahunan',
            days: 3,
            startDate: DateTime(2026, 3, 10),
            endDate: DateTime(2026, 3, 12),
            status: 'approved',
          ),
          LeaveUsage(
            type: 'Cuti Sakit',
            days: 2,
            startDate: DateTime(2026, 4, 22),
            endDate: DateTime(2026, 4, 23),
            status: 'approved',
          ),
        ],
      );
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() async {
    attendanceStatus.value = AttendanceStatus.checkIn;
    checkInTime.value = null;
    checkOutTime.value = null;
    await loadAllData();
  }

  // =========================================================================
  //  Presensi Success — dipanggil oleh AttendanceCard setelah flow selesai
  // =========================================================================

  void onPresensiSuccess(AttendanceType type) {
    final now = DateTime.now();
    switch (type) {
      case AttendanceType.checkIn:
        checkInTime.value = now;
        attendanceStatus.value = AttendanceStatus.break_;
      case AttendanceType.checkOut:
        checkOutTime.value = now;
        attendanceStatus.value = AttendanceStatus.completed;
    }
  }

  // =========================================================================
  //  Break — tidak memerlukan alur presensi penuh
  // =========================================================================

  void onBreakPressed() {
    if (attendanceStatus.value == AttendanceStatus.break_) {
      _confirmBreak(
        'Mulai Istirahat',
        'Apakah Anda ingin memulai waktu istirahat?',
        AttendanceStatus.breakReturn,
      );
    } else if (attendanceStatus.value == AttendanceStatus.breakReturn) {
      _confirmBreak(
        'Kembali dari Istirahat',
        'Apakah Anda sudah kembali dari istirahat?',
        AttendanceStatus.checkOut,
      );
    }
  }

  Future<void> _confirmBreak(
    String title,
    String message,
    AttendanceStatus nextStatus,
  ) async {
    final confirmed = await AppDialog.confirm(
      title: title,
      message: message,
      confirmLabel: 'Ya',
      cancelLabel: 'Batal',
    );
    if (confirmed == true) {
      attendanceStatus.value = nextStatus;
    }
  }
}
