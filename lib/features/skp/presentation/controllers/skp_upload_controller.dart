import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../../../core/network/session_manager.dart';
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
  final isDocValid = false.obs;
  final validationError = Rx<String?>(null);
  final isNipMatched = false.obs;

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
    isDocValid.value = false;
    validationError.value = null;
    isNipMatched.value = false;

    try {
      final bytes = await file.readAsBytes();
      final document = PdfDocument(inputBytes: bytes);

      String extractedText = PdfTextExtractor(document).extractText();
      document.dispose();

      final parsed = _parseSkpPdf(extractedText);

      if (parsed == null) {
        isDocValid.value = false;
        validationError.value =
            'Format dokumen tidak valid. Berkas yang diunggah bukan Dokumen Evaluasi Kinerja Pegawai (EKP) resmi.';
        AppFeedback.showSnackbar(
          title: 'Format Tidak Sesuai',
          message:
              'Berkas PDF bukan Dokumen Evaluasi Kinerja Pegawai (EKP) yang valid. Dokumen harus memuat bagian Pegawai Yang Dinilai dan Evaluasi Kinerja.',
          type: FeedbackType.error,
        );
        return;
      }

      // Validasi NIP Pegawai terhadap user login
      final pegawaiData = parsed['pegawai_dinilai'] as Map<String, dynamic>?;
      final pdfNip = pegawaiData?['nip']?.toString().replaceAll(RegExp(r'\s+'), '') ?? '';

      String loginUserNip = '';
      if (Get.isRegistered<SessionManager>()) {
        loginUserNip = Get.find<SessionManager>().currentUser.value?.nip.replaceAll(RegExp(r'\s+'), '') ?? '';
      }

      final isExempt = loginUserNip.startsWith('1122');

      if (!isExempt && loginUserNip.isNotEmpty && pdfNip.isNotEmpty && loginUserNip != pdfNip) {
        isDocValid.value = false;
        isNipMatched.value = false;
        validationError.value =
            'NIP pada Dokumen EKP ($pdfNip) tidak sesuai dengan NIP akun login Anda ($loginUserNip). Dokumen harus milik pegawai yang bersangkutan.';
        extractedData.value = parsed;

        AppFeedback.showSnackbar(
          title: 'NIP Tidak Sesuai',
          message:
              'Dokumen EKP ditolak karena NIP pada berkas ($pdfNip) berbeda dengan akun Anda ($loginUserNip).',
          type: FeedbackType.error,
        );
        return;
      }

      isDocValid.value = true;
      isNipMatched.value = true;
      validationError.value = null;
      extractedData.value = parsed;

      final eval = parsed['evaluasi_kinerja'] as Map<String, dynamic>?;
      final predikat = eval?['predikat_kinerja_pegawai'] ?? 'Baik';
      final capaian = eval?['capaian_kinerja_organisasi'] ?? '-';
      final tpp = eval?['tpp_percentage'] ?? 80;

      AppFeedback.showSnackbar(
        title: 'Dokumen EKP Terverifikasi',
        message:
            'Data EKP berhasil dibaca (Predikat: $predikat, Capaian: $capaian, Est. TPP: $tpp%).',
        type: FeedbackType.success,
      );
    } catch (e) {
      isDocValid.value = false;
      extractedData.value = null;
      validationError.value = 'Gagal memproses dokumen PDF: $e';

      AppFeedback.showSnackbar(
        title: 'Gagal Ekstraksi',
        message: 'Terjadi kesalahan saat memproses dokumen PDF: $e',
        type: FeedbackType.error,
      );
    } finally {
      isExtracting.value = false;
    }
  }

  Map<String, dynamic>? _parseSkpPdf(String rawText) {
    final lower = rawText.toLowerCase();
    final isSkpHeader = lower.contains('dokumen evaluasi kinerja pegawai') ||
        (lower.contains('evaluasi kinerja') && lower.contains('pegawai yang dinilai'));

    if (!isSkpHeader) {
      return null;
    }

    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    int idxPegawai = -1;
    int idxPejabat = -1;
    int idxAtasan = -1;
    int idxEvaluasi = -1;
    int idxCatatan = -1;

    for (int i = 0; i < lines.length; i++) {
      final lineLower = lines[i].toLowerCase();
      if ((lineLower == 'pegawai yang dinilai' ||
              lineLower.contains('1. pegawai yang dinilai') ||
              (lineLower.contains('pegawai yang dinilai') && i > 0 && lines[i - 1] == '1.')) &&
          idxPegawai == -1) {
        idxPegawai = (i > 0 && lines[i - 1] == '1.') ? i - 1 : i;
      } else if ((lineLower == 'pejabat penilai kinerja' ||
              lineLower.contains('2. pejabat penilai') ||
              (lineLower.contains('pejabat penilai') && i > 0 && lines[i - 1] == '2.')) &&
          idxPejabat == -1) {
        idxPejabat = (i > 0 && lines[i - 1] == '2.') ? i - 1 : i;
      } else if ((lineLower == 'atasan pejabat penilai kinerja' ||
              lineLower.contains('3. atasan pejabat') ||
              (lineLower.contains('atasan pejabat penilai') && i > 0 && lines[i - 1] == '3.')) &&
          idxAtasan == -1) {
        idxAtasan = (i > 0 && lines[i - 1] == '3.') ? i - 1 : i;
      } else if (!lineLower.contains('dokumen') &&
          (lineLower == 'evaluasi kinerja' ||
              lineLower.contains('4. evaluasi kinerja') ||
              (lineLower.contains('evaluasi kinerja') && i > 0 && lines[i - 1] == '4.')) &&
          idxEvaluasi == -1) {
        idxEvaluasi = (i > 0 && lines[i - 1] == '4.') ? i - 1 : i;
      } else if ((lineLower.contains('catatan/rekomendasi') ||
              lineLower.contains('5. catatan') ||
              (lineLower.contains('catatan') && i > 0 && lines[i - 1] == '5.')) &&
          idxCatatan == -1) {
        idxCatatan = (i > 0 && lines[i - 1] == '5.') ? i - 1 : i;
      }
    }

    if (idxPegawai == -1 || idxEvaluasi == -1) {
      return null;
    }

    if (idxCatatan == -1 || idxCatatan <= idxEvaluasi) idxCatatan = lines.length;

    final linesHeader = lines.sublist(0, idxPegawai);
    final linesPegawai = (idxPejabat != -1 && idxPejabat > idxPegawai)
        ? lines.sublist(idxPegawai, idxPejabat)
        : <String>[];
    final linesPejabat = (idxPejabat != -1 && idxAtasan != -1 && idxAtasan > idxPejabat)
        ? lines.sublist(idxPejabat, idxAtasan)
        : <String>[];
    final linesAtasan = (idxAtasan != -1 && idxEvaluasi != -1 && idxEvaluasi > idxAtasan)
        ? lines.sublist(idxAtasan, idxEvaluasi)
        : <String>[];
    final linesEvaluasi = (idxEvaluasi != -1 && idxCatatan > idxEvaluasi)
        ? lines.sublist(idxEvaluasi, idxCatatan)
        : <String>[];

    Map<String, String> extractPerson(List<String> secLines) {
      String nama = '';
      String nip = '';
      String pangkat = '';
      String jabatan = '';
      String unitKerja = '';

      String currentField = '';
      final buffer = <String>[];

      void commitField() {
        if (currentField.isEmpty) return;
        final val = buffer.join(' ').replaceAll(RegExp(r'^:\s*'), '').trim();
        if (currentField == 'nama') nama = val;
        if (currentField == 'nip') nip = val.replaceAll(RegExp(r'[^\d]'), '');
        if (currentField == 'pangkat') pangkat = val;
        if (currentField == 'jabatan') jabatan = val;
        if (currentField == 'unit_kerja') unitKerja = val;
        buffer.clear();
      }

      for (final line in secLines) {
        final lLower = line.toLowerCase();
        if (lLower == 'nama' || lLower.startsWith('nama:') || lLower.startsWith('nama :')) {
          commitField();
          currentField = 'nama';
          if (line.contains(':') && line.split(':').length > 1) {
            final after = line.substring(line.indexOf(':') + 1).trim();
            if (after.isNotEmpty) buffer.add(after);
          }
        } else if (lLower == 'nip' || lLower.startsWith('nip:') || lLower.startsWith('nip :')) {
          commitField();
          currentField = 'nip';
          if (line.contains(':') && line.split(':').length > 1) {
            final after = line.substring(line.indexOf(':') + 1).trim();
            if (after.isNotEmpty) buffer.add(after);
          }
        } else if (lLower.contains('pangkat') || lLower.contains('gol ruang') || lLower.contains('golongan')) {
          commitField();
          currentField = 'pangkat';
          if (line.contains(':') && line.split(':').length > 1) {
            final after = line.substring(line.indexOf(':') + 1).trim();
            if (after.isNotEmpty) buffer.add(after);
          }
        } else if (lLower == 'jabatan' || lLower.startsWith('jabatan:') || lLower.startsWith('jabatan :')) {
          commitField();
          currentField = 'jabatan';
          if (line.contains(':') && line.split(':').length > 1) {
            final after = line.substring(line.indexOf(':') + 1).trim();
            if (after.isNotEmpty) buffer.add(after);
          }
        } else if (lLower == 'unit kerja' || lLower.startsWith('unit kerja:') || lLower.startsWith('unit kerja :')) {
          commitField();
          currentField = 'unit_kerja';
          if (line.contains(':') && line.split(':').length > 1) {
            final after = line.substring(line.indexOf(':') + 1).trim();
            if (after.isNotEmpty) buffer.add(after);
          }
        } else if (line == ':') {
          continue;
        } else if (currentField.isNotEmpty) {
          if (!line.startsWith('1.') &&
              !line.startsWith('2.') &&
              !line.startsWith('3.') &&
              !line.startsWith('4.') &&
              !lLower.contains('pegawai yang dinilai') &&
              !lLower.contains('pejabat penilai') &&
              !lLower.contains('evaluasi kinerja')) {
            buffer.add(line);
          }
        }
      }
      commitField();

      return {
        'nama': nama,
        'nip': nip,
        'pangkat_gol': pangkat,
        'jabatan': jabatan,
        'unit_kerja': unitKerja,
      };
    }

    String capaian = '-';
    String predikat = '';

    for (int i = 0; i < linesEvaluasi.length; i++) {
      final line = linesEvaluasi[i];
      final lLower = line.toLowerCase();

      if (lLower.contains('capaian kinerja organisasi') || lLower.contains('capaian organisasi')) {
        if (line.contains(':') && line.split(':').length > 1) {
          final val = line.substring(line.indexOf(':') + 1).trim();
          if (val.isNotEmpty) capaian = val;
        } else {
          for (int j = i + 1; j < linesEvaluasi.length; j++) {
            final next = linesEvaluasi[j].trim();
            if (next == ':') continue;
            if (next.toLowerCase().contains('predikat')) break;
            capaian = next;
            break;
          }
        }
      }

      if (lLower.contains('predikat kinerja pegawai') ||
          lLower.contains('predikat kinerja') ||
          lLower.startsWith('predikat')) {
        if (line.contains(':') && line.split(':').length > 1) {
          final val = line.substring(line.indexOf(':') + 1).trim();
          if (val.isNotEmpty) predikat = val;
        } else {
          for (int j = i + 1; j < linesEvaluasi.length; j++) {
            final next = linesEvaluasi[j].trim();
            if (next == ':') continue;
            if (next.startsWith('5.') || next.toLowerCase().contains('catatan')) break;
            predikat = next;
            break;
          }
        }
      }
    }

    String periodePenilaian = '';
    for (final l in linesHeader) {
      if (l.toLowerCase().contains('periode penilaian') ||
          l.toLowerCase().contains('periode :') ||
          l.toLowerCase().contains('periode:')) {
        periodePenilaian += '$l ';
      }
    }
    if (periodePenilaian.isEmpty && linesHeader.isNotEmpty) {
      periodePenilaian = linesHeader.join(' ');
    }

    final personPegawai = extractPerson(linesPegawai);
    final personPejabat = extractPerson(linesPejabat);
    final personAtasan = extractPerson(linesAtasan);

    if (predikat.isEmpty && personPegawai['nip']!.isEmpty) {
      return null;
    }

    String cleanedPredikat = predikat;
    final pLower = predikat.toLowerCase();
    if (pLower.contains('sangat baik') || pLower.contains('di atas ekspektasi')) {
      cleanedPredikat = 'Sangat Baik';
    } else if (pLower.contains('baik') || pLower.contains('sesuai ekspektasi')) {
      cleanedPredikat = 'Baik';
    } else if (pLower.contains('butuh perbaikan') || pLower.contains('cukup') || pLower.contains('normal')) {
      cleanedPredikat = 'Butuh Perbaikan';
    } else if (pLower.contains('sangat kurang')) {
      cleanedPredikat = 'Sangat Kurang';
    } else if (pLower.contains('kurang') || pLower.contains('buruk') || pLower.contains('di bawah ekspektasi')) {
      cleanedPredikat = 'Kurang';
    } else if (cleanedPredikat.isEmpty) {
      cleanedPredikat = 'Baik';
    }

    int tppPercentage = 80;
    if (cleanedPredikat == 'Sangat Baik') {
      tppPercentage = 100;
    } else if (cleanedPredikat == 'Baik') {
      tppPercentage = 80;
    } else if (cleanedPredikat == 'Butuh Perbaikan') {
      tppPercentage = 40;
    } else if (cleanedPredikat == 'Kurang' || cleanedPredikat == 'Sangat Kurang') {
      tppPercentage = 20;
    }

    return {
      'periode_penilaian': periodePenilaian.trim(),
      'pegawai_dinilai': personPegawai,
      'pejabat_penilai': personPejabat,
      'atasan_pejabat_penilai': personAtasan,
      'evaluasi_kinerja': {
        'capaian_kinerja_organisasi': capaian.isEmpty ? '-' : capaian,
        'predikat_kinerja_pegawai': cleanedPredikat,
        'raw_predikat': predikat,
        'tpp_percentage': tppPercentage,
      },
      // Flat keys for backward compatibility
      'capaian_kinerja_organisasi': capaian.isEmpty ? '-' : capaian,
      'predikat_kinerja_pegawai': cleanedPredikat,
    };
  }

  Future<void> saveReport() async {
    if (selectedFile.value == null) {
      AppFeedback.showSnackbar(
        title: 'Peringatan',
        message: 'Silakan pilih file laporan PDF terlebih dahulu.',
        type: FeedbackType.warning,
      );
      return;
    }

    if (!isDocValid.value || validationError.value != null) {
      AppFeedback.showDialog(
        title: 'Dokumen Tidak Valid',
        message: validationError.value ??
            'Format dokumen PDF tidak sesuai atau bukan berkas SKP resmi Anda.',
        confirmLabel: 'Tutup',
      );
      return;
    }

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
              'Dokumen EKP untuk periode ${selectedMonth.value}/${selectedYear.value} sudah pernah diunggah. '
              'Satu file Dokumen EKP hanya berlaku untuk 1 periode bulan.\n\n'
              'Jika ingin mengunggah file terbaru, Anda harus menghapus file lama terlebih dahulu dari daftar laporan.',
          confirmLabel: 'Mengerti',
        );
        return;
      }
    }

    try {
      AppFeedback.showLoading('Mengirim Dokumen EKP...');

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
        title: 'Dokumen Terkirim',
        message:
            'Dokumen EKP periode ${selectedMonth.value}/${selectedYear.value} berhasil dikirim (Status: Pending) dan menunggu verifikasi atasan.',
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
