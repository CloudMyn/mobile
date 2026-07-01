import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/logging/request_log_db.dart';
import '../../../../core/logging/request_log_entry.dart';
import '../../../../design_system/components/app_feedback.dart';

/// Controller untuk halaman Request Log Viewer.
class RequestLogController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────────
  final logs = <RequestLogEntry>[].obs;
  final isLoading = false.obs;
  final hasMore = true.obs;
  final totalCount = 0.obs;

  // ── Filters ────────────────────────────────────────────────────────────────
  final selectedMethod = Rx<String?>(null);
  final selectedStatus = Rx<bool?>(null); // null=all, false=error, true=success (note: inverted for isError)
  final searchQuery = ''.obs;
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  // ── Pagination ─────────────────────────────────────────────────────────────
  static const _pageSize = 30;
  int _currentOffset = 0;

  // ── DB ──────────────────────────────────────────────────────────────────────
  final RequestLogDb _db = RequestLogDb.instance;

  // ── Lifecycle ──────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    // Debounce search query to prevent lag on rapid typing
    debounce(
      searchQuery,
      (_) => loadLogs(),
      time: const Duration(milliseconds: 300),
    );
    loadLogs();
  }

  // ── Data Loading ───────────────────────────────────────────────────────────

  /// Load (atau reload) logs dari awal dengan filter aktif.
  Future<void> loadLogs() async {
    isLoading.value = true;
    _currentOffset = 0;

    try {
      final count = await _db.getCount(
        method: selectedMethod.value,
        isError: _isErrorFilter,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        startDate: startDate.value,
        endDate: endDate.value,
      );
      totalCount.value = count;

      final result = await _db.getLogs(
        method: selectedMethod.value,
        isError: _isErrorFilter,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        startDate: startDate.value,
        endDate: endDate.value,
        limit: _pageSize,
        offset: 0,
      );

      logs.assignAll(result);
      _currentOffset = result.length;
      hasMore.value = result.length >= _pageSize;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load halaman berikutnya (infinite scroll).
  Future<void> loadMore() async {
    if (isLoading.value || !hasMore.value) return;
    isLoading.value = true;

    try {
      final result = await _db.getLogs(
        method: selectedMethod.value,
        isError: _isErrorFilter,
        search: searchQuery.value.isNotEmpty ? searchQuery.value : null,
        startDate: startDate.value,
        endDate: endDate.value,
        limit: _pageSize,
        offset: _currentOffset,
      );

      logs.addAll(result);
      _currentOffset += result.length;
      hasMore.value = result.length >= _pageSize;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Filter Actions ─────────────────────────────────────────────────────────

  void setMethod(String? method) {
    selectedMethod.value = method;
    loadLogs();
  }

  void setStatus(bool? isSuccess) {
    // isSuccess: null=all, true=success(isError=false), false=error(isError=true)
    selectedStatus.value = isSuccess;
    loadLogs();
  }

  void setSearch(String query) {
    searchQuery.value = query;
    // loadLogs() will be triggered automatically by the debounce worker
  }

  void setDateRange(DateTime? start, DateTime? end) {
    startDate.value = start;
    endDate.value = end;
    loadLogs();
  }

  void clearFilters() {
    selectedMethod.value = null;
    selectedStatus.value = null;
    startDate.value = null;
    endDate.value = null;
    if (searchQuery.value.isNotEmpty) {
      searchQuery.value = ''; // Triggers debounce -> loadLogs()
    } else {
      loadLogs();
    }
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Hapus semua logs.
  Future<void> clearAllLogs() async {
    await _db.clearAll();
    logs.clear();
    totalCount.value = 0;
    AppFeedback.showSnackbar(
      title: 'Berhasil',
      message: 'Semua log telah dihapus',
    );
  }

  /// Copy log entry ke clipboard.
  Future<void> copyLogToClipboard(RequestLogEntry entry) async {
    await Clipboard.setData(ClipboardData(text: entry.toReadableText()));
    entry.printColoredToConsole();
    AppFeedback.showSnackbar(
      title: 'Disalin',
      message: 'Log berhasil disalin ke clipboard',
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Konversi selectedStatus ke parameter isError untuk DB query.
  bool? get _isErrorFilter {
    final status = selectedStatus.value;
    if (status == null) return null;
    // status == true artinya "show success" → isError = false
    // status == false artinya "show error" → isError = true
    return !status;
  }

  bool get hasActiveFilters =>
      selectedMethod.value != null ||
      selectedStatus.value != null ||
      searchQuery.value.isNotEmpty ||
      startDate.value != null ||
      endDate.value != null;
}
