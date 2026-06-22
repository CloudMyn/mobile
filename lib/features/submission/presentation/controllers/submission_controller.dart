import 'package:get/get.dart';
import '../../data/models/submission_item.dart';
import '../../data/models/submission_type.dart';
import '../../data/services/submission_service.dart';

class SubmissionController extends GetxController {
  final SubmissionService _service;

  SubmissionController({required SubmissionService service}) : _service = service;

  final types = <SubmissionType>[].obs;
  final submissionsMap = <int, List<SubmissionItem>>{}.obs;
  final isLoadingTypes = true.obs;
  final isLoadingList = false.obs;
  final currentTypeIndex = 0.obs;
  final errorMessage = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadTypes();
  }

  Future<void> loadTypes() async {
    isLoadingTypes.value = true;
    errorMessage.value = null;
    try {
      final result = await _service.fetchTypes();
      types.assignAll(result);
      if (result.isNotEmpty) {
        await loadSubmissions(result[0].id);
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat jenis pengajuan: $e';
    } finally {
      isLoadingTypes.value = false;
    }
  }

  Future<void> loadSubmissions(int typeId) async {
    if (submissionsMap.containsKey(typeId)) return;
    isLoadingList.value = true;
    try {
      final result = await _service.fetchSubmissions(typeId: typeId);
      submissionsMap[typeId] = result;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
    } finally {
      isLoadingList.value = false;
    }
  }

  void onTabChanged(int index) {
    currentTypeIndex.value = index;
    if (index < types.length) {
      loadSubmissions(types[index].id);
    }
  }

  Future<void> deleteSubmission(int id, int typeId) async {
    try {
      await _service.deleteSubmission(id);
      final list = List<SubmissionItem>.from(submissionsMap[typeId] ?? []);
      list.removeWhere((item) => item.id == id);
      submissionsMap[typeId] = list;
      submissionsMap.refresh();
      Get.snackbar('Berhasil', 'Pengajuan berhasil dihapus');
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus pengajuan: $e');
    }
  }

  void addSubmission(SubmissionItem item) {
    final list = List<SubmissionItem>.from(submissionsMap[item.typeId] ?? []);
    list.insert(0, item);
    submissionsMap[item.typeId] = list;
    submissionsMap.refresh();
  }

  void updateSubmissionItem(SubmissionItem updatedItem) {
    final list = List<SubmissionItem>.from(submissionsMap[updatedItem.typeId] ?? []);
    final index = list.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      list[index] = updatedItem;
      submissionsMap[updatedItem.typeId] = list;
      submissionsMap.refresh();
    }
  }

  Future<void> submitDraft(int id, int typeId) async {
    try {
      final result = await _service.submitDraft(id);
      updateSubmissionItem(result);
      Get.snackbar('Berhasil', 'Draft berhasil diajukan');
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengajukan draft: $e');
      rethrow;
    }
  }

  SubmissionType? get currentType {
    if (currentTypeIndex.value >= types.length) return null;
    return types[currentTypeIndex.value];
  }

  List<SubmissionItem> submissionsFor(int typeId) =>
      submissionsMap[typeId] ?? [];
}
