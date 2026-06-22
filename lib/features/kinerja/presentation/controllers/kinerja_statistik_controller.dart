import 'package:get/get.dart';
import '../../data/models/monthly_activity_stats.dart';
import '../../data/services/kinerja_service.dart';

import '../../../../design_system/components/app_feedback.dart';

class KinerjaStatistikController extends GetxController {
  final KinerjaService _service;

  KinerjaStatistikController({required KinerjaService service}) : _service = service;

  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;

  final isLoading = false.obs;
  final stats = Rxn<MonthlyActivityStats>();

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    isLoading.value = true;
    try {
      final result = await _service.fetchMonthlyStats(
        month: selectedMonth.value,
        year: selectedYear.value,
      );
      stats.value = result;
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal memuat statistik: $e',
        type: FeedbackType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void updateFilter(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
    loadStats();
  }
}
