import 'package:get/get.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../../submission/data/models/submission_item.dart';
import '../../../submission/data/models/submission_type.dart';
import '../../../submission/data/services/submission_lookup_service.dart';
import '../../../submission/presentation/controllers/submission_controller.dart';
import '../../../submission/presentation/pages/submission_detail_page.dart';
import '../../data/models/notification_item.dart';
import '../../data/services/notification_service.dart';
import 'home_controller.dart';

class NotificationController extends GetxController {
  NotificationController({
    required NotificationService service,
    required SubmissionLookupService submissionLookupService,
  }) : _service = service,
       _submissionLookupService = submissionLookupService;

  final NotificationService _service;
  final SubmissionLookupService _submissionLookupService;

  final notifications = <NotificationItem>[].obs;
  final isLoading = false.obs;
  final isMarkingAllRead = false.obs;
  final isDeletingAll = false.obs;
  final processingNotificationIds = <String>{}.obs;
  final errorMessage = Rx<String?>(null);

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  bool isProcessing(String id) => processingNotificationIds.contains(id);

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _service.fetchNotifications();
      notifications.assignAll(result);
      _syncUnreadToHomeController();
    } on NetworkException catch (e) {
      errorMessage.value = e.message;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'Gagal memuat notifikasi.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    if (notifications.isEmpty || unreadCount == 0 || isMarkingAllRead.value) {
      return;
    }

    isMarkingAllRead.value = true;
    try {
      await _service.markAllAsRead();
      notifications.value = notifications
          .map((item) => item.copyWith(isRead: true))
          .toList();
      _syncUnreadToHomeController();
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Semua notifikasi telah ditandai dibaca.',
      );
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } finally {
      isMarkingAllRead.value = false;
    }
  }

  Future<void> deleteAllNotifications() async {
    if (notifications.isEmpty || isDeletingAll.value) return;

    isDeletingAll.value = true;
    try {
      await _service.deleteAll();
      notifications.clear();
      _syncUnreadToHomeController();
      AppFeedback.showSnackbar(
        title: 'Berhasil',
        message: 'Semua notifikasi berhasil dihapus.',
      );
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } finally {
      isDeletingAll.value = false;
    }
  }

  Future<void> openNotification(NotificationItem notification) async {
    if (isProcessing(notification.id)) return;

    processingNotificationIds.add(notification.id);
    try {
      NotificationItem activeNotification = notification;

      if (!notification.isRead) {
        activeNotification = await _service.markAsRead(notification.id);
        _replaceNotification(activeNotification);
        _syncUnreadToHomeController();
      }

      await _handleNavigation(activeNotification);
    } on ApiException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } on NetworkException catch (e) {
      AppFeedback.showSnackbar(
        title: 'Gagal',
        message: e.message,
        isError: true,
      );
    } finally {
      processingNotificationIds.remove(notification.id);
    }
  }

  Future<void> _handleNavigation(NotificationItem notification) async {
    if (notification.action == 'download') {
      AppFeedback.showSnackbar(
        title: 'Belum Didukung',
        message:
            'Aksi unduh dari notifikasi belum tersedia di aplikasi mobile.',
        isError: true,
      );
      return;
    }

    final href = notification.href.trim();
    if (href.isEmpty || href == '/notifications') {
      return;
    }

    final submissionId = _extractSubmissionId(href);
    if (submissionId != null) {
      final submission = await _submissionLookupService.fetchSubmissionDetail(
        submissionId,
      );
      final type = _resolveSubmissionType(submission.typeId, submission);

      await Get.to(
        () => SubmissionDetailPage(item: submission, type: type),
        transition: Transition.rightToLeft,
      );
      return;
    }

    AppFeedback.showSnackbar(
      title: 'Belum Didukung',
      message: 'Tujuan notifikasi ini belum tersedia di aplikasi mobile.',
      isError: true,
    );
  }

  SubmissionType _resolveSubmissionType(int typeId, SubmissionItem submission) {
    final submissionController = Get.find<SubmissionController>();
    final knownType = submissionController.types.firstWhereOrNull(
      (item) => item.id == typeId || item.code == submission.typeCode,
    );

    if (knownType != null) {
      return knownType;
    }

    return SubmissionType(
      id: typeId,
      code: submission.typeCode,
      name: submission.typeName,
      description: submission.reason ?? submission.description,
      deductsLeaveBalance: false,
      approverName: '-',
      approverPosition: '-',
      maxDays: submission.totalDays,
      allowDateRange: submission.endDate != null,
      allowTimeRange:
          submission.startTime != null || submission.endTime != null,
      defaultYearlyQuota: 0,
      allowCarryForward: false,
      isActive: true,
    );
  }

  int? _extractSubmissionId(String href) {
    final match = RegExp(r'^/?submissions/(\d+)$').firstMatch(href);
    if (match == null) return null;
    return int.tryParse(match.group(1) ?? '');
  }

  void _replaceNotification(NotificationItem updated) {
    final index = notifications.indexWhere((item) => item.id == updated.id);
    if (index == -1) return;
    notifications[index] = updated;
  }

  void _syncUnreadToHomeController() {
    if (!Get.isRegistered<HomeController>()) return;
    Get.find<HomeController>().unreadNotifications.value = unreadCount;
  }
}
