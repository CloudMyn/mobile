import 'package:get/get.dart';
import '../../../../core/error/app_exception.dart';
import '../../data/models/statistik_model.dart';
import '../../data/services/statistik_service.dart';

class StatistikController extends GetxController {
  StatistikController({required StatistikService service})
      : _service = service;

  final StatistikService _service;

  // ── State ────────────────────────────────────────────────────────────────────
  final data = Rx<StatistikModel?>(null);
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadStatistik();
  }

  // ── API ──────────────────────────────────────────────────────────────────────

  Future<void> loadStatistik({int? month, int? year}) async {
    final m = month ?? selectedMonth.value;
    final y = year ?? selectedYear.value;

    isLoading.value = true;
    errorMessage.value = null;
    try {
      data.value = await _service.fetchStatistik(month: m, year: y);
      selectedMonth.value = m;
      selectedYear.value = y;
    } on NetworkException {
      errorMessage.value = 'Tidak ada koneksi internet.';
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Gagal memuat statistik.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() => loadStatistik();

  // ── Period navigation ────────────────────────────────────────────────────────

  void goToPreviousMonth() {
    final dt = DateTime(selectedYear.value, selectedMonth.value - 1);
    loadStatistik(month: dt.month, year: dt.year);
  }

  void goToNextMonth() {
    final now = DateTime.now();
    final next = DateTime(selectedYear.value, selectedMonth.value + 1);
    // Tidak boleh melebihi bulan saat ini
    if (next.isAfter(DateTime(now.year, now.month))) return;
    loadStatistik(month: next.month, year: next.year);
  }

  bool get canGoNext {
    final now = DateTime.now();
    return DateTime(selectedYear.value, selectedMonth.value)
        .isBefore(DateTime(now.year, now.month));
  }

  // ── Convenience getters ──────────────────────────────────────────────────────

  String get periodLabel => data.value?.period.label ?? '';

  /// Saldo cuti tahunan utama (prioritas: kode 'annual_leave', fallback: index 0)
  StatistikLeaveBalance? get primaryLeaveBalance {
    final balances = data.value?.leaveBalances ?? [];
    if (balances.isEmpty) return null;
    return balances.firstWhereOrNull((b) => b.leaveTypeCode == 'annual_leave') ??
        balances.first;
  }
}
