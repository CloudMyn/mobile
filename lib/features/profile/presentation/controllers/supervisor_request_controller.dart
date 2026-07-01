import 'package:get/get.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../data/models/supervisor_request_model.dart';
import '../../data/repositories/supervisor_request_repository.dart';

class SupervisorRequestController extends GetxController {
  final SupervisorRequestRepository _repository;

  SupervisorRequestController({required SupervisorRequestRepository repository})
      : _repository = repository;

  final isLoadingHistory = false.obs;
  final isLoadingApprovals = false.obs;
  final isSubmitting = false.obs;

  final historyList = <SupervisorRequestModel>[].obs;
  final approvalList = <SupervisorRequestModel>[].obs;

  int _historyPage = 1;
  int _approvalsPage = 1;
  bool _hasMoreHistory = true;
  bool _hasMoreApprovals = true;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
    fetchApprovals();
  }

  Future<void> fetchHistory({bool refresh = false}) async {
    if (refresh) {
      _historyPage = 1;
      _hasMoreHistory = true;
      historyList.clear();
    }

    if (!_hasMoreHistory || isLoadingHistory.value) return;

    isLoadingHistory.value = true;
    try {
      final response = await _repository.getHistory(page: _historyPage);
      if (response.data != null) {
        historyList.addAll(response.data!);
      }
      if (response.meta != null && response.meta!.currentPage >= response.meta!.lastPage) {
        _hasMoreHistory = false;
      } else {
        _historyPage++;
      }
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    } finally {
      isLoadingHistory.value = false;
    }
  }

  Future<void> fetchApprovals({bool refresh = false}) async {
    if (refresh) {
      _approvalsPage = 1;
      _hasMoreApprovals = true;
      approvalList.clear();
    }

    if (!_hasMoreApprovals || isLoadingApprovals.value) return;

    isLoadingApprovals.value = true;
    try {
      final response = await _repository.getApprovals(page: _approvalsPage);
      if (response.data != null) {
        approvalList.addAll(response.data!);
      }
      if (response.meta != null && response.meta!.currentPage >= response.meta!.lastPage) {
        _hasMoreApprovals = false;
      } else {
        _approvalsPage++;
      }
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    } finally {
      isLoadingApprovals.value = false;
    }
  }

  Future<bool> submitRequest(int supervisorId, String? reason) async {
    isSubmitting.value = true;
    try {
      await _repository.submitRequest(supervisorId: supervisorId, reason: reason);
      AppFeedback.showSnackbar(
        title: 'Sukses',
        message: 'Pengajuan atasan berhasil dikirim.',
        type: FeedbackType.success,
      );
      fetchHistory(refresh: true);
      return true;
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> approveRequest(int requestId) async {
    try {
      await _repository.approveRequest(requestId);
      AppFeedback.showSnackbar(
        title: 'Sukses',
        message: 'Pengajuan disetujui.',
        type: FeedbackType.success,
      );
      fetchApprovals(refresh: true);
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    }
  }

  Future<void> rejectRequest(int requestId, String? reason) async {
    try {
      await _repository.rejectRequest(requestId: requestId, reason: reason);
      AppFeedback.showSnackbar(
        title: 'Sukses',
        message: 'Pengajuan ditolak.',
        type: FeedbackType.success,
      );
      fetchApprovals(refresh: true);
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
    }
  }

  Future<bool> deleteRequest(int requestId) async {
    try {
      await _repository.deleteRequest(requestId);
      AppFeedback.showSnackbar(
        title: 'Sukses',
        message: 'Pengajuan berhasil dihapus.',
        type: FeedbackType.success,
      );
      fetchHistory(refresh: true);
      return true;
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: e.toString(),
        type: FeedbackType.error,
      );
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    try {
      return await _repository.searchUsers(query);
    } catch (e) {
      return [];
    }
  }
}
