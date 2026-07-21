import 'dart:io';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/session_manager.dart';
import '../../data/services/statistik_service.dart';

enum ReportType { attendance, tpp }

class ReportViewerController extends GetxController {
  ReportViewerController({StatistikService? service})
      : _service = service ?? Get.find<StatistikService>();

  final StatistikService _service;

  final reportType = ReportType.attendance.obs;
  final selectedYear = DateTime.now().year.obs;
  final selectedMonth = DateTime.now().month.obs;
  final selectedScope = 'monthly'.obs;
  final selectedDate = RxnString();

  final isLoading = false.obs;
  final pdfFilePath = RxnString();
  final errorMessage = RxnString();

  final currentPage = 0.obs;
  final totalPages = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args['reportType'] is ReportType) {
        reportType.value = args['reportType'] as ReportType;
      }
      if (args['year'] is int) {
        selectedYear.value = args['year'] as int;
      }
      if (args['month'] is int) {
        selectedMonth.value = args['month'] as int;
      }
    }
    fetchPdf();
  }

  void setReportType(ReportType type) {
    if (reportType.value == type) return;
    reportType.value = type;
    fetchPdf();
  }

  void updateFilters({
    required int year,
    required int month,
    String? scope,
    String? date,
  }) {
    selectedYear.value = year;
    selectedMonth.value = month;
    if (scope != null) selectedScope.value = scope;
    selectedDate.value = date;
    fetchPdf();
  }

  Future<void> fetchPdf() async {
    isLoading.value = true;
    errorMessage.value = null;
    pdfFilePath.value = null;

    try {
      List<int> bytes = [];
      if (reportType.value == ReportType.attendance) {
        bytes = await _service.downloadAttendanceReportPdf(
          year: selectedYear.value,
          month: selectedMonth.value,
          scope: selectedScope.value,
          date: selectedDate.value,
        );
      } else {
        final userId = Get.isRegistered<SessionManager>()
            ? Get.find<SessionManager>().currentUser.value?.id
            : null;
        if (userId == null) {
          throw ApiException(
            statusCode: 401,
            message: 'User ID tidak ditemukan. Silakan login ulang.',
          );
        }

        bytes = await _service.downloadTppReportPdf(
          year: selectedYear.value,
          month: selectedMonth.value,
          userId: userId,
        );
      }

      if (bytes.isEmpty) {
        throw ApiException(
          statusCode: 404,
          message: 'Data PDF kosong atau tidak ditemukan.',
        );
      }

      final tempDir = await getTemporaryDirectory();
      final fileName =
          'laporan_${reportType.value.name}_${selectedYear.value}_${selectedMonth.value}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      pdfFilePath.value = file.path;
    } catch (e) {
      if (e is ApiException) {
        errorMessage.value = e.message;
      } else if (e is NetworkException) {
        errorMessage.value = e.message;
      } else {
        errorMessage.value = 'Gagal memuat file PDF: ${e.toString()}';
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openDownloadedFile() async {
    final path = pdfFilePath.value;
    if (path == null || !File(path).existsSync()) {
      Get.snackbar('Error', 'File PDF belum tersedia untuk dibuka.');
      return;
    }

    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done) {
      Get.snackbar(
        'Info',
        'Gagal membuka berkas: ${result.message}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
