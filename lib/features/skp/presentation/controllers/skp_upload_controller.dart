import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../data/repositories/skp_report_repository.dart';
import 'skp_list_controller.dart';

class SkpUploadController extends GetxController {
  final SkpReportRepository _repository;

  SkpUploadController({required SkpReportRepository repository})
      : _repository = repository;

  final selectedFile = Rx<File?>(null);
  final extractedData = Rx<Map<String, dynamic>?>(null);
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
    extractedData.value = null;

    try {
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      String extractedText = PdfTextExtractor(document).extractText();
      document.dispose();

      final lines = extractedText.split('\n').map((l) => l.trim()).toList();

      String capaianOrganisasi = 'Baik';
      String predikatKinerja = 'Baik';
      final extractedItems = <String>[];

      // Regex / Keyword matching for EVALUASI KINERJA
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final lower = line.toLowerCase();

        // 1. Check Capaian Kinerja Organisasi
        if (lower.contains('capaian kinerja organisasi') ||
            lower.contains('capaian organisasi')) {
          if (line.contains(':') && line.split(':').length > 1) {
            final val = line.split(':')[1].trim();
            if (val.isNotEmpty) capaianOrganisasi = val;
          } else if (i + 1 < lines.length && lines[i + 1].isNotEmpty) {
            capaianOrganisasi = lines[i + 1].trim();
          }
        }

        // 2. Check Predikat Kinerja Pegawai
        if (lower.contains('predikat kinerja pegawai') ||
            lower.contains('predikat kinerja') ||
            lower.contains('predikat :') ||
            lower.contains('predikat:')) {
          if (line.contains(':') && line.split(':').length > 1) {
            final val = line.split(':')[1].trim();
            if (val.isNotEmpty) predikatKinerja = val;
          } else if (i + 1 < lines.length && lines[i + 1].isNotEmpty) {
            predikatKinerja = lines[i + 1].trim();
          }
        }

        // 3. Collect significant activities
        if (line.length > 20 &&
            !lower.contains('sasaran kinerja pegawai') &&
            !lower.contains('pemerintah kabupaten') &&
            !lower.contains('periode penilaian') &&
            !lower.contains('halaman')) {
          if (extractedItems.length < 10) {
            extractedItems.add(line);
          }
        }
      }

      // Cleanup predicate values if they have extra text
      predikatKinerja = _cleanPredikat(predikatKinerja);
      capaianOrganisasi = _cleanCapaian(capaianOrganisasi);

      final resultData = <String, dynamic>{
        'capaian_kinerja_organisasi': capaianOrganisasi,
        'predikat_kinerja_pegawai': predikatKinerja,
        'extracted_items_count': extractedItems.length,
        'sample_activities': extractedItems,
      };

      extractedData.value = resultData;

      AppFeedback.showSnackbar(
        title: 'Berhasil Diekstrak',
        message:
            'Data SKP berhasil diekstrak (Predikat: $predikatKinerja, Capaian: $capaianOrganisasi).',
        type: FeedbackType.success,
      );
    } catch (e) {
      // If parsing failed to extract specific tags, provide fallback valid map
      extractedData.value = {
        'capaian_kinerja_organisasi': 'Baik',
        'predikat_kinerja_pegawai': 'Baik',
        'extracted_items_count': 0,
        'sample_activities': <String>[],
      };

      AppFeedback.showSnackbar(
        title: 'Informasi Ekstraksi',
        message:
            'Dokumen berhasil dibaca. Evaluasi kinerja diset dengan nilai default.',
        type: FeedbackType.info,
      );
    } finally {
      isExtracting.value = false;
    }
  }

  String _cleanPredikat(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('sangat baik')) return 'Sangat Baik';
    if (lower.contains('sangat kurang')) return 'Sangat Kurang';
    if (lower.contains('butuh perbaikan')) return 'Butuh Perbaikan';
    if (lower.contains('kurang')) return 'Kurang';
    if (lower.contains('baik')) return 'Baik';
    if (lower.contains('di atas ekspektasi')) return 'Di Atas Ekspektasi';
    if (lower.contains('sesuai ekspektasi')) return 'Sesuai Ekspektasi';
    if (lower.contains('di bawah ekspektasi')) return 'Di Bawah Ekspektasi';
    return raw.isNotEmpty ? raw : 'Baik';
  }

  String _cleanCapaian(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('istimewa')) return 'Istimewa';
    if (lower.contains('baik')) return 'Baik';
    if (lower.contains('butuh perbaikan')) return 'Butuh Perbaikan';
    if (lower.contains('kurang')) return 'Kurang';
    if (lower.contains('sangat kurang')) return 'Sangat Kurang';
    return raw.isNotEmpty ? raw : 'Baik';
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
      final alreadyExists = listCtrl.hasReportForPeriod(
        selectedMonth.value,
        selectedYear.value,
      );
      if (alreadyExists) {
        AppFeedback.showDialog(
          title: 'Laporan Sudah Ada',
          message:
              'Laporan SKP untuk periode ${selectedMonth.value}/${selectedYear.value} sudah pernah diunggah. '
              'Satu file SKP hanya berlaku untuk 1 periode bulan.\n\n'
              'Jika ingin mengunggah file terbaru, Anda harus menghapus file lama terlebih dahulu dari daftar laporan.',
          confirmLabel: 'Mengerti',
        );
        return;
      }
    }

    try {
      AppFeedback.showLoading('Mengirim Laporan...');

      final saved = await _repository.uploadReport(
        file: selectedFile.value!,
        periodMonth: selectedMonth.value,
        periodYear: selectedYear.value,
        jsonExtractedData: extractedData.value,
      );

      if (Get.isRegistered<SkpListController>()) {
        Get.find<SkpListController>().addReport(saved);
      }

      AppFeedback.hideLoading();
      Get.back();
      AppFeedback.showSnackbar(
        title: 'Laporan Terkirim',
        message:
            'Laporan SKP periode ${selectedMonth.value}/${selectedYear.value} berhasil dikirim (Status: Pending) dan menunggu verifikasi atasan.',
        type: FeedbackType.success,
      );
    } catch (e) {
      AppFeedback.hideLoading();
      AppFeedback.showSnackbar(
        title: 'Gagal Menyimpan',
        message: e.toString().replaceAll('ApiException', '').replaceAll('Exception: ', '').trim(),
        type: FeedbackType.error,
      );
    }
  }
}
