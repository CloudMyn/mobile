import 'package:get/get.dart';
import '../../data/models/subordinate_submission_item.dart';
import '../../data/models/submission_item.dart';
import '../../data/services/subordinate_submission_service.dart';

class SubordinateSubmissionController extends GetxController {
  final SubordinateSubmissionService _service;

  SubordinateSubmissionController({required SubordinateSubmissionService service})
      : _service = service;

  final pendingSubmissions = <SubordinateSubmissionItem>[].obs;
  final approvedSubmissions = <SubordinateSubmissionItem>[].obs;
  final rejectedSubmissions = <SubordinateSubmissionItem>[].obs;

  final isLoading = false.obs;
  final errorMessage = RxnString();

  // Search & Filter
  final searchQuery = ''.obs;
  final selectedTypeId = RxnInt();
  final selectedMonth = 0.obs; // 0 means All
  final selectedYear = 0.obs; // 0 means All

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _service.fetchSubordinateSubmissions(status: SubmissionStatus.pending),
        _service.fetchSubordinateSubmissions(status: SubmissionStatus.approved),
        _service.fetchSubordinateSubmissions(status: SubmissionStatus.rejected),
      ]);

      pendingSubmissions.assignAll(results[0]);
      approvedSubmissions.assignAll(results[1]);
      rejectedSubmissions.assignAll(results[2]);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  List<SubordinateSubmissionItem> get filteredPending => _filter(pendingSubmissions);
  List<SubordinateSubmissionItem> get filteredApproved => _filter(approvedSubmissions);
  List<SubordinateSubmissionItem> get filteredRejected => _filter(rejectedSubmissions);

  List<SubordinateSubmissionItem> _filter(List<SubordinateSubmissionItem> list) {
    return list.where((item) {
      final query = searchQuery.value.toLowerCase().trim();
      if (query.isNotEmpty) {
        final matchesName = item.subordinateName.toLowerCase().contains(query);
        final matchesNip = item.subordinateNip.contains(query);
        if (!matchesName && !matchesNip) return false;
      }

      if (selectedTypeId.value != null && item.typeId != selectedTypeId.value) {
        return false;
      }

      if (selectedMonth.value != 0 && item.startDate.month != selectedMonth.value) {
        return false;
      }

      if (selectedYear.value != 0 && item.startDate.year != selectedYear.value) {
        return false;
      }

      return true;
    }).toList();
  }

  void resetFilters() {
    searchQuery.value = '';
    selectedTypeId.value = null;
    selectedMonth.value = 0;
    selectedYear.value = 0;
  }

  Future<void> approve(int id, String? note) async {
    isLoading.value = true;
    try {
      final updated = await _service.approveSubmission(id, note);
      
      // Update local lists
      pendingSubmissions.removeWhere((s) => s.id == id);
      approvedSubmissions.removeWhere((s) => s.id == id);
      rejectedSubmissions.removeWhere((s) => s.id == id);
      
      approvedSubmissions.insert(0, updated);
      Get.back(); // Close detail page
      Get.snackbar('Berhasil', 'Pengajuan berhasil disetujui');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reject(int id, String reason) async {
    isLoading.value = true;
    try {
      final updated = await _service.rejectSubmission(id, reason);
      
      // Update local lists
      pendingSubmissions.removeWhere((s) => s.id == id);
      approvedSubmissions.removeWhere((s) => s.id == id);
      rejectedSubmissions.removeWhere((s) => s.id == id);
      
      rejectedSubmissions.insert(0, updated);
      Get.back(); // Close detail page
      Get.snackbar('Berhasil', 'Pengajuan berhasil ditolak');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
