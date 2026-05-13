import 'package:get/get.dart';
import '../../data/models/activity_item.dart';
import '../../data/models/activity_type.dart';
import '../../data/models/monthly_activity_stats.dart';
import '../../data/services/kinerja_service.dart';

class KinerjaController extends GetxController {
  final KinerjaService _service;

  KinerjaController({required KinerjaService service}) : _service = service;

  // ── Main Page State ────────────────────────────────────────
  final types = <ActivityType>[].obs;
  final activities = <ActivityItem>[].obs;
  final monthlyStats = Rx<MonthlyActivityStats?>(null);
  final selectedMonth = DateTime.now().month.obs;
  final selectedYear = DateTime.now().year.obs;
  final isLoadingTypes = true.obs;
  final isLoadingActivities = false.obs;
  final isLoadingStats = false.obs;
  final errorMessage = Rx<String?>(null);

  // ── Detail Page (Full Page) State ──────────────────────────
  final allActivities = <ActivityItem>[].obs;
  final currentDetailMonth = DateTime.now().month.obs;
  final currentDetailYear = DateTime.now().year.obs;
  final detailPage = 1.obs;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadTypes();
    loadActivities();
    loadMonthlyStats();
  }

  // ── Load Methods ───────────────────────────────────────────

  Future<void> loadTypes() async {
    isLoadingTypes.value = true;
    errorMessage.value = null;
    try {
      final result = await _service.fetchTypes();
      types.assignAll(result);
    } catch (e) {
      errorMessage.value = 'Gagal memuat jenis kegiatan: $e';
    } finally {
      isLoadingTypes.value = false;
    }
  }

  Future<void> loadActivities() async {
    isLoadingActivities.value = true;
    try {
      final result = await _service.fetchActivities(
        month: selectedMonth.value,
        year: selectedYear.value,
      );
      activities.assignAll(result);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data kinerja: $e');
    } finally {
      isLoadingActivities.value = false;
    }
  }

  Future<void> loadMonthlyStats() async {
    isLoadingStats.value = true;
    try {
      final result = await _service.fetchMonthlyStats(
        month: selectedMonth.value,
        year: selectedYear.value,
      );
      monthlyStats.value = result;
    } catch (_) {
      // Non-blokir error untuk stats
    } finally {
      isLoadingStats.value = false;
    }
  }

  // ── Pagination untuk Halaman Detail ───────────────────────

  Future<void> loadDetailActivities({bool refresh = false}) async {
    if (refresh) {
      detailPage.value = 1;
      hasMore.value = true;
      allActivities.clear();
    }

    if (!hasMore.value || isLoadingMore.value) return;

    isLoadingMore.value = true;
    try {
      final result = await _service.fetchActivities(
        month: currentDetailMonth.value,
        year: currentDetailYear.value,
        page: detailPage.value,
        pageSize: 20,
      );

      if (result.length < 20) {
        hasMore.value = false;
      }

      allActivities.addAll(result);
      detailPage.value++;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  void resetPagination() {
    detailPage.value = 1;
    hasMore.value = true;
    allActivities.clear();
  }

  void changeDetailMonth(int month) {
    currentDetailMonth.value = month;
    currentDetailYear.value = DateTime.now().year;
    resetPagination();
    loadDetailActivities();
  }

  // ── Actions ───────────────────────────────────────────────

  void changeMonth(int month) {
    selectedMonth.value = month;
    selectedYear.value = DateTime.now().year;
    loadActivities();
    loadMonthlyStats();
  }

  void addActivity(ActivityItem item) {
    activities.insert(0, item);
    activities.refresh();
    loadMonthlyStats();
    // Juga tambahkan ke allActivities untuk halaman detail
    if (item.date.month == currentDetailMonth.value &&
        item.date.year == currentDetailYear.value) {
      allActivities.insert(0, item);
      allActivities.refresh();
    }
  }

  Future<void> deleteActivity(String id) async {
    try {
      await _service.deleteActivity(id);
      activities.removeWhere((a) => a.id == id);
      allActivities.removeWhere((a) => a.id == id);
      loadMonthlyStats();
      Get.snackbar(
        'Berhasil',
        'Kinerja berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menghapus kinerja: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void updateActivityInList(ActivityItem updated) {
    final idx = activities.indexWhere((a) => a.id == updated.id);
    if (idx != -1) {
      activities[idx] = updated;
      activities.refresh();
    }
    final idx2 = allActivities.indexWhere((a) => a.id == updated.id);
    if (idx2 != -1) {
      allActivities[idx2] = updated;
      allActivities.refresh();
    }
    loadMonthlyStats();
  }

  String get currentMonthName {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return months[selectedMonth.value - 1];
  }

  String get currentDetailMonthName {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return months[currentDetailMonth.value - 1];
  }

  /// Mendapatkan nama bulan pendek (Jan, Feb, Mar, ...)
  static String shortMonthName(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return names[month - 1];
  }

  /// Mendapatkan daftar bulan yang memiliki data aktivitas (dari tahun berjalan)
  List<int> get availableMonths {
    final months = activities.map((a) => a.date.month).toSet().toList();
    months.sort();
    return months;
  }

  /// Mendapatkan daftar bulan yang memiliki data di allActivities
  List<int> get availableDetailMonths {
    final months = allActivities.map((a) => a.date.month).toSet().toList();
    months.sort();
    return months;
  }

  /// Filter aktivitas untuk 3 hari terakhir
  List<ActivityItem> get last3DaysActivities {
    final now = DateTime.now();
    final threeDaysAgo = DateTime(now.year, now.month, now.day - 3);
    return activities
        .where((item) =>
            item.date.isAfter(threeDaysAgo.subtract(const Duration(days: 1))) &&
            item.date.isBefore(now.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Group activities by date (untuk main page).
  /// Returns a map sorted descending by date.
  Map<DateTime, List<ActivityItem>> get groupedByDate {
    final map = <DateTime, List<ActivityItem>>{};
    for (final item in activities) {
      final dateKey = DateTime(item.date.year, item.date.month, item.date.day);
      map.putIfAbsent(dateKey, () => []);
      map[dateKey]!.add(item);
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: map[k]!};
  }

  /// Group allActivities by date (untuk halaman detail).
  /// Returns a map sorted descending by date.
  Map<DateTime, List<ActivityItem>> get groupedByDateDetail {
    final map = <DateTime, List<ActivityItem>>{};
    for (final item in allActivities) {
      final dateKey = DateTime(item.date.year, item.date.month, item.date.day);
      map.putIfAbsent(dateKey, () => []);
      map[dateKey]!.add(item);
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: map[k]!};
  }
}
