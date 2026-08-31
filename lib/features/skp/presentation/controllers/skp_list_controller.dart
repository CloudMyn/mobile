import 'package:get/get.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../data/models/skp_report_model.dart';
import '../../data/services/skp_service.dart';

class SkpListController extends GetxController {
  final SkpService _service;

  SkpListController({required SkpService service}) : _service = service;

  final reports = <SkpReportModel>[].obs;
  final subReports = <SkpReportModel>[].obs;
  
  final isLoading = false.obs;
  final isLoadingSub = false.obs;

  final currentTabIndex = 0.obs;
  
  final selectedMonth = Rx<int?>(null);
  final selectedStatus = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchReports();
    fetchSubordinateReports();
  }

  Future<void> fetchReports() async {
    try {
      isLoading.value = true;
      final data = await _service.getReports();
      reports.value = data;
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

  Future<void> fetchSubordinateReports() async {
    try {
      isLoadingSub.value = true;
      final data = await _service.getSubordinateReports();
      subReports.value = data;
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

  void addReport(SkpReportModel report) {
    reports.removeWhere((r) => r.periodMonth == report.periodMonth && r.periodYear == report.periodYear);
    reports.insert(0, report);
  }

  Future<void> deleteReport(int id) async {
    try {
      AppFeedback.showLoading('Menghapus Laporan...');
      final success = await _service.deleteReport(id);
      AppFeedback.hideLoading();
      if (success) {
        reports.removeWhere((r) => r.id == id);
        AppFeedback.showSnackbar(
          title: 'Berhasil Dihapus',
          message: 'Laporan SKP berhasil dihapus. Anda dapat mengunggah file baru untuk periode tersebut.',
          type: FeedbackType.success,
        );
      } else {
        AppFeedback.showSnackbar(
          title: 'Gagal',
          message: 'Laporan SKP tidak ditemukan atau gagal dihapus.',
          type: FeedbackType.error,
        );
      }
    } catch (e) {
      AppFeedback.hideLoading();
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal menghapus laporan: $e',
        type: FeedbackType.error,
      );
    }
  }

  Future<void> approveSubordinateReport(int id, bool isApproved) async {
    try {
      AppFeedback.showLoading(isApproved ? 'Menyetujui Laporan...' : 'Menolak Laporan...');
      final success = await _service.approveReport(id, isApproved);
      AppFeedback.hideLoading();
      if (success) {
        final index = subReports.indexWhere((r) => r.id == id);
        if (index != -1) {
          subReports[index] = subReports[index].copyWith(
            status: isApproved ? 'disetujui' : 'ditolak',
          );
        }
        AppFeedback.showSnackbar(
          title: 'Berhasil',
          message: isApproved ? 'Laporan bawahan berhasil disetujui.' : 'Laporan bawahan telah ditolak.',
          type: FeedbackType.success,
        );
      }
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
  
  void applyFilter({int? month, String? status}) {
    selectedMonth.value = month;
    selectedStatus.value = status;
  }
  
  List<SkpReportModel> get filteredReports {
    return _applyFilterToList(reports);
  }
  
  List<SkpReportModel> get filteredSubordinateReports {
    return _applyFilterToList(subReports);
  }

  List<SkpReportModel> _applyFilterToList(List<SkpReportModel> source) {
    return source.where((report) {
      bool matchMonth = true;
      if (selectedMonth.value != null) {
        matchMonth = report.periodMonth == selectedMonth.value;
      }
      
      bool matchStatus = true;
      if (selectedStatus.value != null && selectedStatus.value!.isNotEmpty) {
        matchStatus = report.status.toLowerCase() == selectedStatus.value!.toLowerCase();
      }
      
      return matchMonth && matchStatus;
    }).toList();
  }

  bool hasReportForPeriod(int month, int year) {
    return reports.any((r) => r.periodMonth == month && r.periodYear == year);
  }
}
