import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../../../core/network/session_manager.dart';
import '../../../../design_system/components/app_feedback.dart';
import '../../data/repositories/skp_report_repository.dart';
import '../../data/services/ekp_pdf_parser.dart';
import 'skp_list_controller.dart';

class SkpUploadController extends GetxController {
  final SkpReportRepository _repository;

  SkpUploadController({required SkpReportRepository repository})
      : _repository = repository;

  final selectedFile = Rx<File?>(null);
  final extractedData = Rx<Map<String, dynamic>?>(null);
  final parsedEkp = Rx<EkpExtractedData?>(null);
  final isExtracting = false.obs;

  final selectedMonth = RxInt(DateTime.now().month);
  final selectedYear = RxInt(DateTime.now().year);

  void setPeriod(int month, int year) {
    selectedMonth.value = month;
    selectedYear.value = year;

    // Jika file sudah pernah dipilih, validasi ulang terhadap periode baru
    if (parsedEkp.value != null) {
      _validatePeriodAgainstEkp(parsedEkp.value!, month, year);
    }
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
    parsedEkp.value = null;

    try {
      final parsed = await EkpPdfParser.parseFile(file);

      // 1. Validasi Kepemilikan Dokumen (Kecocokan NIP Pegawai)
      if (Get.isRegistered<SessionManager>()) {
        final session = Get.find<SessionManager>();
        final currentUser = session.currentUser.value;
        if (currentUser != null && currentUser.nip.isNotEmpty) {
          final userNip = currentUser.nip.replaceAll(RegExp(r'\D'), '');
          final pdfNip = (parsed.pegawaiNip ?? '').replaceAll(RegExp(r'\D'), '');

          // Dikecualikan jika NIP berawalan 1122 (akun test/developer)
          final isExempt = userNip.startsWith('1122');
          if (!isExempt && pdfNip.isNotEmpty && pdfNip != userNip) {
            _resetFileSelection();
            AppFeedback.showDialog(
              title: 'Dokumen Bukan Milik Anda',
              message:
                  'NIP pada dokumen EKP (${parsed.pegawaiNip}) tidak sesuai dengan NIP akun Anda ($userNip).\n\n'
                  'Pastikan Anda mengunggah Dokumen Evaluasi Kinerja Pegawai (EKP) milik Anda sendiri.',
              confirmLabel: 'Tutup',
            );
            return;
          }
        }
      }

      // 2. Validasi Periode Dokumen vs Periode yang Dipilih
      final periodValid = _validatePeriodAgainstEkp(
        parsed,
        selectedMonth.value,
        selectedYear.value,
      );
      if (!periodValid) {
        return;
      }

      // 3. Simpan data hasil ekstraksi riil tanpa fallback default dummy
      parsedEkp.value = parsed;
      extractedData.value = parsed.toMap();

      AppFeedback.showSnackbar(
        title: 'Dokumen EKP Valid',
        message:
            'Dokumen EKP berhasil dibaca. Predikat: ${parsed.predikatKinerja}, Capaian: ${parsed.capaianOrganisasi}.',
        type: FeedbackType.success,
      );
    } on EkpPdfValidationException catch (e) {
      _resetFileSelection();
      AppFeedback.showDialog(
        title: 'Format Dokumen Tidak Sesuai',
        message: e.message,
        confirmLabel: 'Tutup',
      );
    } catch (e) {
      _resetFileSelection();
      AppFeedback.showDialog(
        title: 'Gagal Membaca Dokumen',
        message: 'Terjadi kesalahan saat memproses dokumen PDF: $e',
        confirmLabel: 'Tutup',
      );
    } finally {
      isExtracting.value = false;
    }
  }

  bool _validatePeriodAgainstEkp(EkpExtractedData parsed, int month, int year) {
    if (!parsed.isPeriodCovered(month, year)) {
      _resetFileSelection();
      final periodText = parsed.rawPeriodText ??
          'Bulan ${parsed.periodStartMonth}-${parsed.periodEndMonth} ${parsed.periodYear}';
      AppFeedback.showDialog(
        title: 'Periode Tidak Sesuai',
        message:
            'Periode laporan yang dipilih ($month/$year) tidak tercakup dalam periode penilaian dokumen EKP ($periodText).\n\n'
            'Silakan sesuaikan pilihan periode bulan & tahun atau unggah dokumen EKP yang sesuai.',
        confirmLabel: 'Tutup',
      );
      return false;
    }
    return true;
  }

  void _resetFileSelection() {
    selectedFile.value = null;
    extractedData.value = null;
    parsedEkp.value = null;
  }

  Future<void> saveReport() async {
    // Validasi 1: Dokumen terpilih & terverifikasi
    if (selectedFile.value == null || extractedData.value == null) {
      AppFeedback.showSnackbar(
        title: 'Peringatan',
        message: 'Silakan pilih dan pastikan dokumen EKP telah tervalidasi terlebih dahulu.',
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
              'Laporan EKP untuk periode ${selectedMonth.value}/${selectedYear.value} sudah pernah diunggah. '
              'Satu file EKP hanya berlaku untuk 1 periode bulan.\n\n'
              'Jika ingin mengunggah file terbaru, Anda harus menghapus file lama terlebih dahulu dari daftar laporan.',
          confirmLabel: 'Mengerti',
        );
        return;
      }
    }

    try {
      AppFeedback.showLoading('Mengirim Laporan EKP...');

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
            'Laporan EKP periode ${selectedMonth.value}/${selectedYear.value} berhasil dikirim (Status: Pending) dan menunggu verifikasi atasan.',
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
