import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../data/models/subordinate_activity_item.dart';
import '../../data/services/kinerja_bawahan_service.dart';

class KinerjaBawahanController extends GetxController {
  final KinerjaBawahanService _service;

  KinerjaBawahanController({required KinerjaBawahanService service}) : _service = service;

  final pendingCount = 0.obs;

  // Lists per status
  final pendingActivities = <SubordinateActivityItem>[].obs;
  final approvedActivities = <SubordinateActivityItem>[].obs;
  final rejectedActivities = <SubordinateActivityItem>[].obs;

  // Loading states
  final isLoadingPending = false.obs;
  final isLoadingApproved = false.obs;
  final isLoadingRejected = false.obs;

  // Pagination states
  final hasMorePending = true.obs;
  final hasMoreApproved = true.obs;
  final hasMoreRejected = true.obs;

  int _pagePending = 1;
  int _pageApproved = 1;
  int _pageRejected = 1;

  @override
  void onInit() {
    super.onInit();
    loadPendingCount();
  }

  Future<void> loadPendingCount() async {
    try {
      final count = await _service.fetchPendingCount();
      pendingCount.value = count;
    } catch (e) {
      debugPrint('Error fetchPendingCount: $e');
    }
  }

  Future<void> loadActivities(ActivityStatus status, {bool refresh = false}) async {
    if (status == ActivityStatus.pending) {
      await _loadPending(refresh: refresh);
    } else if (status == ActivityStatus.approved) {
      await _loadApproved(refresh: refresh);
    } else if (status == ActivityStatus.rejected) {
      await _loadRejected(refresh: refresh);
    }
  }

  Future<void> _loadPending({bool refresh = false}) async {
    if (refresh) {
      _pagePending = 1;
      hasMorePending.value = true;
      pendingActivities.clear();
    }
    if (!hasMorePending.value || isLoadingPending.value) return;

    isLoadingPending.value = true;
    try {
      final result = await _service.fetchSubordinateActivities(
        status: ActivityStatus.pending,
        page: _pagePending,
      );
      if (result.length < 15) hasMorePending.value = false;
      pendingActivities.addAll(result);
      _pagePending++;
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal memuat data pending: $e',
        isError: true,
      );
    } finally {
      isLoadingPending.value = false;
    }
  }

  Future<void> _loadApproved({bool refresh = false}) async {
    if (refresh) {
      _pageApproved = 1;
      hasMoreApproved.value = true;
      approvedActivities.clear();
    }
    if (!hasMoreApproved.value || isLoadingApproved.value) return;

    isLoadingApproved.value = true;
    try {
      final result = await _service.fetchSubordinateActivities(
        status: ActivityStatus.approved,
        page: _pageApproved,
      );
      if (result.length < 15) hasMoreApproved.value = false;
      approvedActivities.addAll(result);
      _pageApproved++;
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal memuat data disetujui: $e',
        isError: true,
      );
    } finally {
      isLoadingApproved.value = false;
    }
  }

  Future<void> _loadRejected({bool refresh = false}) async {
    if (refresh) {
      _pageRejected = 1;
      hasMoreRejected.value = true;
      rejectedActivities.clear();
    }
    if (!hasMoreRejected.value || isLoadingRejected.value) return;

    isLoadingRejected.value = true;
    try {
      final result = await _service.fetchSubordinateActivities(
        status: ActivityStatus.rejected,
        page: _pageRejected,
      );
      if (result.length < 15) hasMoreRejected.value = false;
      rejectedActivities.addAll(result);
      _pageRejected++;
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal memuat data ditolak: $e',
        isError: true,
      );
    } finally {
      isLoadingRejected.value = false;
    }
  }

  Future<void> approveActivity(String id) async {
    try {
      final updated = await _service.approveActivity(id);
      
      // Update lists
      pendingActivities.removeWhere((a) => a.id == id);
      rejectedActivities.removeWhere((a) => a.id == id);
      
      // Add to approved if we have loaded it, and sort
      approvedActivities.insert(0, updated);
      approvedActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      loadPendingCount();
      
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Kinerja bawahan berhasil disetujui',
      );
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal menyetujui: $e',
        isError: true,
      );
    }
  }

  Future<void> rejectActivity(String id, String reason) async {
    try {
      final updated = await _service.rejectActivity(id, reason);
      
      // Update lists
      pendingActivities.removeWhere((a) => a.id == id);
      approvedActivities.removeWhere((a) => a.id == id);
      
      // Add to rejected
      rejectedActivities.insert(0, updated);
      rejectedActivities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      loadPendingCount();
      
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Kinerja bawahan telah ditolak',
      );
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal menolak: $e',
        isError: true,
      );
    }
  }

  // Helper for grouping by created_at (Date only)
  Map<DateTime, List<SubordinateActivityItem>> groupActivities(List<SubordinateActivityItem> list) {
    final map = <DateTime, List<SubordinateActivityItem>>{};
    for (final item in list) {
      final dateKey = DateTime(item.createdAt.year, item.createdAt.month, item.createdAt.day);
      map.putIfAbsent(dateKey, () => []);
      map[dateKey]!.add(item);
    }
    final sortedKeys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (final k in sortedKeys) k: map[k]!};
  }
}
