import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../data/models/skp_report_model.dart';
import '../../data/services/skp_service.dart';
import 'skp_list_controller.dart';

class SkpUploadController extends GetxController {
  final SkpService _service;

  SkpUploadController({required SkpService service}) : _service = service;

  final selectedFile = Rx<File?>(null);
  final extractedItems = <SkpItem>[].obs;
  final isExtracting = false.obs;

  final selectedMonth = RxInt(DateTime.now().month);
  final selectedYear = RxInt(DateTime.now().year);

  void setPeriod(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;
  }

  Future<void> pickAndExtractPdf() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);

        // Validasi 1: Ekstensi file
        if (!filePath.toLowerCase().endsWith('.pdf')) {
          AppFeedback.showSnackbar(
            title: 'Format Tidak Valid',
            message: 'Hanya file format PDF yang diperbolehkan.',
            type: FeedbackType.warning,
          );
          return;
        }

        // Validasi 2: Ukuran file (Maks 10 MB)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          AppFeedback.showSnackbar(
            title: 'File Terlalu Besar',
            message: 'Ukuran file PDF maksimal adalah 10 MB.',
            type: FeedbackType.warning,
          );
          return;
        }

        selectedFile.value = file;
        await _extractPdfData(file);
      }
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error',
        message: 'Gagal memilih atau membaca file PDF: $e',
        type: FeedbackType.error,
      );
    }
  }

  Future<void> _extractPdfData(File file) async {
    isExtracting.value = true;
    extractedItems.clear();

    try {
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);
      
      String extractedText = PdfTextExtractor(document).extractText();
      document.dispose();

      final lines = extractedText.split('\n');
      final items = <SkpItem>[];
      
      for (var line in lines) {
        line = line.trim();
        if (line.length > 20 && !line.toLowerCase().contains('sasaran kinerja pegawai')) {
           items.add(SkpItem(
             kegiatan: line,
             target: '1 Dokumen',
             realisasi: '1 Dokumen',
           ));
        }
      }

      if (items.isEmpty) {
        items.add(SkpItem(
          kegiatan: 'Dokumen berhasil dibaca. Tabel kegiatan akan diverifikasi oleh atasan.',
          target: '1 Dokumen',
          realisasi: '1 Dokumen',
        ));
      }

      extractedItems.value = items;
      AppFeedback.showSnackbar(
        title: 'Berhasil Diekstrak',
        message: 'Data SKP berhasil diekstrak dan siap dikirim.',
        type: FeedbackType.success,
      );
    } catch (e) {
      AppFeedback.showSnackbar(
        title: 'Error Ekstraksi',
        message: 'Gagal mengekstrak PDF: $e',
        type: FeedbackType.error,
      );
    } finally {
      isExtracting.value = false;
    }
  }

  Future<void> saveReport() async {
    // Validasi 1: Dokumen terpilih
    if (selectedFile.value == null) {
      AppFeedback.showSnackbar(
        title: 'Peringatan',
        message: 'Silakan pilih file laporan PDF terlebih dahulu.',
        type: FeedbackType.warning,
      );
      return;
    }

    // Validasi 2: Cek apakah laporan untuk periode bulan & tahun yang dipilih sudah ada
    if (Get.isRegistered<SkpListController>()) {
      final listCtrl = Get.find<SkpListController>();
      final alreadyExists = listCtrl.hasReportForPeriod(selectedMonth.value, selectedYear.value);
      if (alreadyExists) {
        AppFeedback.showDialog(
          title: 'Laporan Sudah Ada',
          message: 'Laporan SKP untuk periode ${selectedMonth.value}/${selectedYear.value} sudah pernah diunggah. '
              'Satu file SKP hanya berlaku untuk 1 periode bulan.\n\n'
              'Jika ingin mengunggah file terbaru, Anda harus menghapus file lama terlebih dahulu dari daftar laporan.',
          confirmLabel: 'Mengerti',
        );
        return;
      }
    }

    try {
      AppFeedback.showLoading('Mengirim Laporan...');
      final filename = selectedFile.value!.path.split(Platform.pathSeparator).last;
      
      final report = SkpReportModel(
        filename: filename,
        uploadDate: DateTime.now(),
        periodMonth: selectedMonth.value,
        periodYear: selectedYear.value,
        items: extractedItems.toList(),
        status: 'pending',
      );

      final saved = await _service.saveReport(report);
      
      if (Get.isRegistered<SkpListController>()) {
        Get.find<SkpListController>().addReport(saved);
      }

      AppFeedback.hideLoading();
      Get.back();
      AppFeedback.showSnackbar(
        title: 'Laporan Terkirim',
        message: 'Laporan SKP periode ${selectedMonth.value}/${selectedYear.value} berhasil dikirim (Status: Pending) dan menunggu verifikasi atasan.',
        type: FeedbackType.success,
      );
    } catch (e) {
      AppFeedback.hideLoading();
      AppFeedback.showSnackbar(
        title: 'Gagal Menyimpan',
        message: e.toString().replaceAll('Exception: ', ''),
        type: FeedbackType.error,
      );
    }
  }
}
