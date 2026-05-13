import 'package:get/get.dart';
import '../../data/models/attendance_history_item.dart';
import '../../data/models/attendance_history_summary.dart';
import '../../data/repositories/attendance_history_repository.dart';

class AttendanceHistoryController extends GetxController {
  AttendanceHistoryController({
    required AttendanceHistoryRepository repository,
  }) : _repository = repository;

  final AttendanceHistoryRepository _repository;

  final int currentYear = DateTime.now().year;
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;
  final items = <AttendanceHistoryItem>[].obs;
  final summary = Rx<AttendanceHistorySummary?>(null);
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void onInit() {
    super.onInit();
    loadMonth();
  }

  String get monthLabel => '${_monthNames[selectedMonth.value - 1]} ${selectedYear.value}';

  bool get canGoPrev => selectedMonth.value > 1;
  bool get canGoNext => selectedMonth.value < 12;

  Future<void> loadMonth() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final month = selectedMonth.value;
      final year = selectedYear.value;

      final results = await Future.wait<dynamic>([
        _repository.fetchMonthlyHistory(month: month, year: year),
        _repository.fetchMonthlySummary(month: month, year: year),
      ]);

      final history = results[0] as List<AttendanceHistoryItem>;
      final monthlySummary = results[1] as AttendanceHistorySummary;

      items.assignAll(_normalizeMonthItems(history));
      summary.value = monthlySummary;
    } catch (e) {
      errorMessage.value = 'Gagal memuat riwayat presensi: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> goToPrevMonth() async {
    if (!canGoPrev) return;
    selectedMonth.value -= 1;
    await loadMonth();
  }

  Future<void> goToNextMonth() async {
    if (!canGoNext) return;
    selectedMonth.value += 1;
    await loadMonth();
  }

  List<AttendanceHistoryItem> _normalizeMonthItems(
    List<AttendanceHistoryItem> source,
  ) {
    final normalized = <AttendanceHistoryItem>[];
    final mapped = {
      for (final item in source) item.date.day: item,
    };

    final month = selectedMonth.value;
    final year = selectedYear.value;
    final lastDay = DateTime(year, month + 1, 0).day;

    for (var day = 1; day <= lastDay; day++) {
      final existing = mapped[day];
      if (existing != null) {
        normalized.add(existing);
        continue;
      }

      final date = DateTime(year, month, day);
      final fallbackStatus = _fallbackStatus(date);
      normalized.add(
        AttendanceHistoryItem(
          date: date,
          status: fallbackStatus,
          label: _labelOf(fallbackStatus),
          note: fallbackStatus == AttendanceDayStatus.weekend
              ? 'Hari libur akhir pekan'
              : 'Tidak ada jadwal shift',
        ),
      );
    }

    return normalized;
  }

  AttendanceDayStatus _fallbackStatus(DateTime date) {
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      return AttendanceDayStatus.weekend;
    }
    return AttendanceDayStatus.noSchedule;
  }

  String _labelOf(AttendanceDayStatus status) {
    return switch (status) {
      AttendanceDayStatus.present => 'Hadir',
      AttendanceDayStatus.absent => 'Alpha',
      AttendanceDayStatus.weekend => 'Weekend',
      AttendanceDayStatus.holiday => 'Libur',
      AttendanceDayStatus.noSchedule => 'Tidak Ada Jadwal',
      AttendanceDayStatus.permission => 'Izin',
      AttendanceDayStatus.leave => 'Cuti',
    };
  }
}
