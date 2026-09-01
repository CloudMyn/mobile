import 'package:get/get.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../data/models/skp_report_model.dart';
import '../../data/repositories/skp_report_repository.dart';

class SkpListController extends GetxController {
  final SkpReportRepository _repository;

  SkpListController({required SkpReportRepository repository})
      : _repository = repository;

  final reports = <SkpReportModel>[].obs;
  final subReports = <SkpReportModel>[].obs;

  final isLoading = false.obs;
  final isLoadingSub = false.obs;

  final isLoadingMoreReports = false.obs;
  final isLoadingMoreSubReports = false.obs;

  final reportsPage = 1.obs;
  final subReportsPage = 1.obs;

  final hasMoreReports = true.obs;
  final hasMoreSubReports = true.obs;

  final currentTabIndex = 0.obs;

  final selectedMonth = Rx<int?>(null);
  final selectedYear = Rx<int?>(DateTime.now().year);
  final selectedStatus = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchReports();
    fetchSubordinateReports();
  }

  Future<void> fetchReports({bool refresh = false}) async {
    if (refresh) {
      reportsPage.value = 1;
      hasMoreReports.value = true;
    }

    try {
      isLoading.value = true;
      final result = await _repository.getReports(
        page: 1,
        month: selectedMonth.value,
        year: selectedYear.value,
        status: selectedStatus.value,
      );

      reports.assignAll(result.items);
      reportsPage.value = 1;
      hasMoreReports.value = result.meta.hasNextPage;
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal memuat laporan SKP: $e',
        type: FeedbackType.error,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreReports() async {
    if (isLoadingMoreReports.value || !hasMoreReports.value || isLoading.value) {
      return;
    }

    try {
      isLoadingMoreReports.value = true;
      final nextPage = reportsPage.value + 1;
      final result = await _repository.getReports(
        page: nextPage,
        month: selectedMonth.value,
        year: selectedYear.value,
        status: selectedStatus.value,
      );

      reports.addAll(result.items);
      reportsPage.value = nextPage;
      hasMoreReports.value = result.meta.hasNextPage;
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal memuat laporan berikutnya: $e',
        type: FeedbackType.error,
      );
    } finally {
      isLoadingMoreReports.value = false;
    }
  }

  Future<void> fetchSubordinateReports({bool refresh = false}) async {
    if (refresh) {
      subReportsPage.value = 1;
      hasMoreSubReports.value = true;
    }

    try {
      isLoadingSub.value = true;
      final result = await _repository.getSubordinateReports(
        page: 1,
        month: selectedMonth.value,
        year: selectedYear.value,
        status: selectedStatus.value,
      );

      subReports.assignAll(result.items);
      subReportsPage.value = 1;
      hasMoreSubReports.value = result.meta.hasNextPage;
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal memuat laporan bawahan: $e',
        type: FeedbackType.error,
      );
    } finally {
      isLoadingSub.value = false;
    }
  }

  Future<void> loadMoreSubordinateReports() async {
    if (isLoadingMoreSubReports.value ||
        !hasMoreSubReports.value ||
        isLoadingSub.value) {
      return;
    }

    try {
      isLoadingMoreSubReports.value = true;
      final nextPage = subReportsPage.value + 1;
      final result = await _repository.getSubordinateReports(
        page: nextPage,
        month: selectedMonth.value,
        year: selectedYear.value,
        status: selectedStatus.value,
      );

      subReports.addAll(result.items);
      subReportsPage.value = nextPage;
      hasMoreSubReports.value = result.meta.hasNextPage;
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal memuat laporan bawahan berikutnya: $e',
        type: FeedbackType.error,
      );
    } finally {
      isLoadingMoreSubReports.value = false;
    }
  }

  void addReport(SkpReportModel report) {
    reports.removeWhere((r) =>
        r.periodMonth == report.periodMonth &&
        r.periodYear == report.periodYear);
    reports.insert(0, report);
  }

  Future<void> deleteReport(int id) async {
    try {
      AppFeedback.showLoading('Menghapus Laporan...');
      await _repository.deleteReport(id);
      AppFeedback.hideLoading();

      reports.removeWhere((r) => r.id == id);
      AppFeedback.showSnackbar(
        title: 'Berhasil Dihapus',
        message:
            'Laporan SKP berhasil dihapus. Anda dapat mengunggah file baru untuk periode tersebut.',
        type: FeedbackType.success,
      );
    } catch (e) {
      AppFeedback.hideLoading();
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal menghapus laporan: $e',
        type: FeedbackType.error,
      );
    }
  }

  Future<void> verifySubordinateReport(
    int id, {
    required String status,
    String? rejectionNote,
  }) async {
    final isApproved = status.toLowerCase() == 'disetujui';
    try {
      AppFeedback.showLoading(
        isApproved ? 'Menyetujui Laporan...' : 'Menolak Laporan...',
      );
      final updated = await _repository.verifyReport(
        id,
        status: status,
        rejectionNote: rejectionNote,
      );
      AppFeedback.hideLoading();

      final index = subReports.indexWhere((r) => r.id == id);
      if (index != -1) {
        subReports[index] = updated;
      }
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: isApproved
            ? 'Laporan bawahan berhasil disetujui.'
            : 'Laporan bawahan telah ditolak.',
        type: FeedbackType.success,
      );
    } catch (e) {
      AppFeedback.hideLoading();
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal memperbarui status: $e',
        type: FeedbackType.error,
      );
    }
  }

  void onTabChanged(int index) {
    currentTabIndex.value = index;
  }

  void applyFilter({int? month, int? year, String? status}) {
    selectedMonth.value = month;
    selectedYear.value = year;
    selectedStatus.value = status;

    fetchReports(refresh: true);
    fetchSubordinateReports(refresh: true);
  }

  void resetFilter() {
    selectedMonth.value = null;
    selectedYear.value = DateTime.now().year;
    selectedStatus.value = null;

    fetchReports(refresh: true);
    fetchSubordinateReports(refresh: true);
  }

  bool hasReportForPeriod(int month, int year) {
    return reports.any((r) => r.periodMonth == month && r.periodYear == year);
  }
}
