import 'dart:io';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class EkpPdfValidationException implements Exception {
  final String message;
  const EkpPdfValidationException(this.message);

  @override
  String toString() => message;
}

class EkpExtractedData {
  final String? judulDokumen;
  final String? rawPeriodText;
  final int? periodStartMonth;
  final int? periodEndMonth;
  final int? periodYear;

  // Pegawai yang dinilai
  final String? pegawaiNama;
  final String? pegawaiNip;
  final String? pegawaiPangkat;
  final String? pegawaiJabatan;
  final String? pegawaiUnitKerja;

  // Pejabat penilai kinerja
  final String? penilaiNama;
  final String? penilaiNip;
  final String? penilaiPangkat;
  final String? penilaiJabatan;
  final String? penilaiUnitKerja;

  // Atasan pejabat penilai
  final String? atasanNama;
  final String? atasanNip;
  final String? atasanPangkat;
  final String? atasanJabatan;
  final String? atasanUnitKerja;

  // Evaluasi kinerja
  final String? capaianOrganisasi;
  final String? predikatKinerja;
  final String? catatanRekomendasi;

  const EkpExtractedData({
    this.judulDokumen,
    this.rawPeriodText,
    this.periodStartMonth,
    this.periodEndMonth,
    this.periodYear,
    this.pegawaiNama,
    this.pegawaiNip,
    this.pegawaiPangkat,
    this.pegawaiJabatan,
    this.pegawaiUnitKerja,
    this.penilaiNama,
    this.penilaiNip,
    this.penilaiPangkat,
    this.penilaiJabatan,
    this.penilaiUnitKerja,
    this.atasanNama,
    this.atasanNip,
    this.atasanPangkat,
    this.atasanJabatan,
    this.atasanUnitKerja,
    this.capaianOrganisasi,
    this.predikatKinerja,
    this.catatanRekomendasi,
  });

  bool isPeriodCovered(int month, int year) {
    if (periodYear != null && periodYear != year) {
      return false;
    }
    if (periodStartMonth != null && periodEndMonth != null) {
      return month >= periodStartMonth! && month <= periodEndMonth!;
    }
    if (periodStartMonth != null) {
      return month == periodStartMonth;
    }
    return true;
  }

  Map<String, dynamic> toMap() {
    return {
      'capaian_kinerja_organisasi': capaianOrganisasi,
      'predikat_kinerja_pegawai': predikatKinerja,
      'pegawai_dinilai': {
        'nama': pegawaiNama,
        'nip': pegawaiNip,
        'pangkat_golongan': pegawaiPangkat,
        'jabatan': pegawaiJabatan,
        'unit_kerja': pegawaiUnitKerja,
      },
      'pejabat_penilai': {
        'nama': penilaiNama,
        'nip': penilaiNip,
        'pangkat_golongan': penilaiPangkat,
        'jabatan': penilaiJabatan,
        'unit_kerja': penilaiUnitKerja,
      },
      'atasan_pejabat_penilai': {
        'nama': atasanNama,
        'nip': atasanNip,
        'pangkat_golongan': atasanPangkat,
        'jabatan': atasanJabatan,
        'unit_kerja': atasanUnitKerja,
      },
      'evaluasi_kinerja': {
        'capaian_kinerja_organisasi': capaianOrganisasi,
        'predikat_kinerja_pegawai': predikatKinerja,
      },
      'periode_penilaian': {
        'raw': rawPeriodText,
        'start_month': periodStartMonth,
        'end_month': periodEndMonth,
        'year': periodYear,
      },
      if (catatanRekomendasi != null && catatanRekomendasi!.isNotEmpty)
        'catatan_rekomendasi': catatanRekomendasi,
    };
  }
}

class EkpPdfParser {
  static const _indonesianMonths = {
    'januari': 1,
    'februari': 2,
    'maret': 3,
    'april': 4,
    'mei': 5,
    'juni': 6,
    'juli': 7,
    'agustus': 8,
    'september': 9,
    'oktober': 10,
    'november': 11,
    'desember': 12,
  };

  /// Parses an EKP PDF file and returns validated [EkpExtractedData].
  /// Throws [EkpPdfValidationException] if the file is invalid or does not match EKP standard.
  static Future<EkpExtractedData> parseFile(File file) async {
    final bytes = await file.readAsBytes();
    return parseBytes(bytes);
  }

  static EkpExtractedData parseBytes(List<int> bytes) {
    PdfDocument document;
    try {
      document = PdfDocument(inputBytes: bytes);
    } catch (e) {
      throw const EkpPdfValidationException('File PDF tidak dapat dibuka atau rusak.');
    }

    String extractedText = '';
    try {
      extractedText = PdfTextExtractor(document).extractText();
    } catch (e) {
      throw const EkpPdfValidationException('Gagal mengekstrak teks dari dokumen PDF.');
    } finally {
      document.dispose();
    }

    if (extractedText.trim().isEmpty) {
      throw const EkpPdfValidationException(
        'Dokumen PDF tidak memuat teks yang dapat dibaca (PDF hasil scan gambar tanpa OCR tidak didukung).',
      );
    }

    return parseText(extractedText);
  }

  static EkpExtractedData parseText(String fullText) {
    final upper = fullText.toUpperCase();

    // 1. Validasi Judul Dokumen
    if (!upper.contains('DOKUMEN EVALUASI KINERJA PEGAWAI') &&
        !upper.contains('EVALUASI KINERJA PEGAWAI')) {
      throw const EkpPdfValidationException(
        'Dokumen bukan Dokumen Evaluasi Kinerja Pegawai (EKP) yang valid. '
        'Pastikan judul dokumen adalah "DOKUMEN EVALUASI KINERJA PEGAWAI".',
      );
    }

    // 2. Validasi Keberadaan Bagian Pokok
    if (!upper.contains('PEGAWAI YANG DINILAI')) {
      throw const EkpPdfValidationException(
        'Format dokumen tidak sesuai: Bagian "1. PEGAWAI YANG DINILAI" tidak ditemukan.',
      );
    }
    if (!upper.contains('PEJABAT PENILAI KINERJA')) {
      throw const EkpPdfValidationException(
        'Format dokumen tidak sesuai: Bagian "2. PEJABAT PENILAI KINERJA" tidak ditemukan.',
      );
    }
    if (!upper.contains('EVALUASI KINERJA')) {
      throw const EkpPdfValidationException(
        'Format dokumen tidak sesuai: Bagian "4. EVALUASI KINERJA" tidak ditemukan.',
      );
    }

    final rawLines = fullText.split(RegExp(r'\r?\n')).map((l) => l.trim()).toList();

    // 3. Ekstraksi Periode
    final periodData = _extractPeriod(rawLines, fullText);

    // 4. Pisahkan teks per bagian (Section 1, 2, 3, 4, dst)
    final section1Lines = _extractSectionLines(rawLines, 'PEGAWAI YANG DINILAI', 'PEJABAT PENILAI KINERJA');
    final section2Lines = _extractSectionLines(rawLines, 'PEJABAT PENILAI KINERJA', 'ATASAN PEJABAT PENILAI KINERJA', fallbackNextHeading: 'EVALUASI KINERJA');
    final section3Lines = _extractSectionLines(rawLines, 'ATASAN PEJABAT PENILAI KINERJA', 'EVALUASI KINERJA');
    final section4Lines = _extractSectionLines(rawLines, 'EVALUASI KINERJA', 'CATATAN/REKOMENDASI');

    // 5. Ekstraksi Profil Pegawai Yang Dinilai
    final pegawaiNama = _findFieldValue(section1Lines, ['NAMA']);
    final pegawaiNip = _findCleanNip(section1Lines);
    final pegawaiPangkat = _findFieldValue(section1Lines, ['PANGKAT/GOL RUANG', 'PANGKAT/GOL', 'PANGKAT']);
    final pegawaiJabatan = _findFieldValue(section1Lines, ['JABATAN']);
    final pegawaiUnitKerja = _findFieldValue(section1Lines, ['UNIT KERJA']);

    // 6. Ekstraksi Pejabat Penilai Kinerja
    final penilaiNama = _findFieldValue(section2Lines, ['NAMA']);
    final penilaiNip = _findCleanNip(section2Lines);
    final penilaiPangkat = _findFieldValue(section2Lines, ['PANGKAT/GOL RUANG', 'PANGKAT/GOL', 'PANGKAT']);
    final penilaiJabatan = _findFieldValue(section2Lines, ['JABATAN']);
    final penilaiUnitKerja = _findFieldValue(section2Lines, ['UNIT KERJA']);

    // 7. Ekstraksi Atasan Pejabat Penilai Kinerja
    String? atasanNama;
    String? atasanNip;
    String? atasanPangkat;
    String? atasanJabatan;
    String? atasanUnitKerja;
    if (section3Lines.isNotEmpty) {
      atasanNama = _findFieldValue(section3Lines, ['NAMA']);
      atasanNip = _findCleanNip(section3Lines);
      atasanPangkat = _findFieldValue(section3Lines, ['PANGKAT/GOL RUANG', 'PANGKAT/GOL', 'PANGKAT']);
      atasanJabatan = _findFieldValue(section3Lines, ['JABATAN']);
      atasanUnitKerja = _findFieldValue(section3Lines, ['UNIT KERJA']);
    }

    // 8. Ekstraksi Evaluasi Kinerja
    final capaianRaw = _findFieldValue(
      section4Lines.isNotEmpty ? section4Lines : rawLines,
      ['CAPAIAN KINERJA ORGANISASI', 'CAPAIAN ORGANISASI'],
    );
    final predikatRaw = _findFieldValue(
      section4Lines.isNotEmpty ? section4Lines : rawLines,
      ['PREDIKAT KINERJA PEGAWAI', 'PREDIKAT KINERJA', 'PREDIKAT'],
    );

    if (predikatRaw == null || predikatRaw.trim().isEmpty) {
      throw const EkpPdfValidationException(
        'Format tidak valid: Predikat Kinerja Pegawai tidak ditemukan pada bagian EVALUASI KINERJA dokumen EKP.',
      );
    }

    // Format capaian: jika '-' simpan sebagai '-' atau null jika kosong
    final cleanCapaian = (capaianRaw == null || capaianRaw.trim().isEmpty) ? '-' : capaianRaw.trim();
    final cleanPredikat = _cleanPredikat(predikatRaw.trim());

    return EkpExtractedData(
      judulDokumen: 'DOKUMEN EVALUASI KINERJA PEGAWAI',
      rawPeriodText: periodData['raw'],
      periodStartMonth: periodData['start_month'],
      periodEndMonth: periodData['end_month'],
      periodYear: periodData['year'],
      pegawaiNama: pegawaiNama,
      pegawaiNip: pegawaiNip,
      pegawaiPangkat: pegawaiPangkat,
      pegawaiJabatan: pegawaiJabatan,
      pegawaiUnitKerja: pegawaiUnitKerja,
      penilaiNama: penilaiNama,
      penilaiNip: penilaiNip,
      penilaiPangkat: penilaiPangkat,
      penilaiJabatan: penilaiJabatan,
      penilaiUnitKerja: penilaiUnitKerja,
      atasanNama: atasanNama,
      atasanNip: atasanNip,
      atasanPangkat: atasanPangkat,
      atasanJabatan: atasanJabatan,
      atasanUnitKerja: atasanUnitKerja,
      capaianOrganisasi: cleanCapaian,
      predikatKinerja: cleanPredikat,
    );
  }

  static List<String> _extractSectionLines(
    List<String> allLines,
    String startKeyword,
    String endKeyword, {
    String? fallbackNextHeading,
  }) {
    final startUpper = startKeyword.toUpperCase();
    final endUpper = endKeyword.toUpperCase();
    final fallbackUpper = fallbackNextHeading?.toUpperCase();

    int startIndex = -1;
    int endIndex = -1;

    for (int i = 0; i < allLines.length; i++) {
      final lineUpper = allLines[i].toUpperCase();
      if (startIndex == -1 && lineUpper.contains(startUpper)) {
        startIndex = i;
      } else if (startIndex != -1) {
        if (lineUpper.contains(endUpper) ||
            (fallbackUpper != null && lineUpper.contains(fallbackUpper))) {
          endIndex = i;
          break;
        }
      }
    }

    if (startIndex == -1) return [];
    if (endIndex == -1) endIndex = allLines.length;

    return allLines.sublist(startIndex, endIndex);
  }

  static String? _findFieldValue(List<String> lines, List<String> fieldKeys) {
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineUpper = line.toUpperCase();

      for (final key in fieldKeys) {
        if (lineUpper.contains(key)) {
          // Kasus 1: "NAMA : JEMMA, S.Kom" dalam 1 baris
          if (line.contains(':')) {
            final parts = line.split(':');
            if (parts.length > 1) {
              final val = parts.sublist(1).join(':').trim();
              if (val.isNotEmpty && val != ':') {
                return _cleanMultiLineValue(lines, i, val);
              }
            }
          }

          // Kasus 2: Multi-line dari PdfTextExtractor
          // Baris 1: NAMA
          // Baris 2: :
          // Baris 3: JEMMA, S.Kom
          int searchIndex = i + 1;
          while (searchIndex < lines.length &&
              (lines[searchIndex].isEmpty || lines[searchIndex] == ':')) {
            searchIndex++;
          }
          if (searchIndex < lines.length && lines[searchIndex].isNotEmpty) {
            final val = lines[searchIndex].trim();
            // Pastikan bukan field lain berikutnya
            if (!_isFieldLabel(val)) {
              return _cleanMultiLineValue(lines, searchIndex, val);
            }
          }
        }
      }
    }
    return null;
  }

  static String? _findCleanNip(List<String> lines) {
    final raw = _findFieldValue(lines, ['NIP']);
    if (raw == null) return null;
    final digitsOnly = raw.replaceAll(RegExp(r'\D'), '');
    return digitsOnly.isNotEmpty ? digitsOnly : raw.trim();
  }

  static String _cleanMultiLineValue(List<String> lines, int currentIndex, String initialValue) {
    var result = initialValue;
    // Cek baris berikutnya jika nilai bersambung (seperti Nama atau Unit Kerja panjang)
    for (int j = currentIndex + 1; j < lines.length && j <= currentIndex + 2; j++) {
      final nextLine = lines[j].trim();
      if (nextLine.isEmpty) continue;
      if (_isFieldLabel(nextLine) ||
          nextLine.startsWith(RegExp(r'^\d+\.')) ||
          nextLine == ':') {
        break;
      }
      result += ' $nextLine';
    }
    return result.trim();
  }

  static bool _isFieldLabel(String line) {
    final upper = line.toUpperCase();
    return upper.contains('NAMA') ||
        upper.contains('NIP') ||
        upper.contains('PANGKAT') ||
        upper.contains('JABATAN') ||
        upper.contains('UNIT KERJA') ||
        upper.contains('CAPAIAN') ||
        upper.contains('PREDIKAT') ||
        upper.contains('PEGAWAI YANG DINILAI') ||
        upper.contains('PEJABAT PENILAI') ||
        upper.contains('EVALUASI KINERJA') ||
        upper.contains('CATATAN');
  }

  static Map<String, dynamic> _extractPeriod(List<String> lines, String fullText) {
    // Cari teks periode, misal:
    // "1 JANUARI SD 31 MARET TAHUN 2026"
    // "PERIODE JANUARI 2026 S/D MARET 2026"
    String? rawPeriod;
    for (final line in lines) {
      final upper = line.toUpperCase();
      if (upper.contains('PERIODE PENILAIAN:') ||
          upper.contains('PERIODE :') ||
          upper.contains('PERIODE PENILAIAN')) {
        rawPeriod = line.replaceAll(RegExp(r'PERIODE PENILAIAN:?', caseSensitive: false), '')
            .replaceAll(RegExp(r'PERIODE\s*:', caseSensitive: false), '')
            .trim();
        if (rawPeriod.isEmpty) {
          // Cek baris berikutnya
          final idx = lines.indexOf(line);
          if (idx + 1 < lines.length) {
            rawPeriod = lines[idx + 1].trim();
          }
        }
        if (rawPeriod.isNotEmpty) break;
      }
    }

    if (rawPeriod == null || rawPeriod.isEmpty) {
      final match = RegExp(r'(\d{1,2}\s+[A-Za-z]+\s+(?:SD|S/D)\s+\d{1,2}\s+[A-Za-z]+\s+TAHUN\s+\d{4})', caseSensitive: false)
          .firstMatch(fullText);
      if (match != null) {
        rawPeriod = match.group(1);
      }
    }

    int? startMonth;
    int? endMonth;
    int? year;

    if (rawPeriod != null) {
      final lower = rawPeriod.toLowerCase();

      // Cari tahun (4 digit angka)
      final yearMatch = RegExp(r'\b(20\d\d)\b').firstMatch(rawPeriod);
      if (yearMatch != null) {
        year = int.tryParse(yearMatch.group(1)!);
      }

      // Cari nama-nama bulan yang muncul
      final foundMonths = <int>[];
      for (final entry in _indonesianMonths.entries) {
        if (lower.contains(entry.key)) {
          foundMonths.add(entry.value);
        }
      }

      if (foundMonths.isNotEmpty) {
        foundMonths.sort();
        startMonth = foundMonths.first;
        endMonth = foundMonths.last;
      }
    }

    return {
      'raw': rawPeriod,
      'start_month': startMonth,
      'end_month': endMonth,
      'year': year,
    };
  }

  static String _cleanPredikat(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('sangat baik')) return 'Sangat Baik';
    if (lower.contains('sangat kurang')) return 'Sangat Kurang';
    if (lower.contains('butuh perbaikan')) return 'Butuh Perbaikan';
    if (lower.contains('kurang')) return 'Kurang';
    if (lower.contains('baik')) return 'Baik';
    if (lower.contains('di atas ekspektasi')) return 'Di Atas Ekspektasi';
    if (lower.contains('sesuai ekspektasi')) return 'Sesuai Ekspektasi';
    if (lower.contains('di bawah ekspektasi')) return 'Di Bawah Ekspektasi';
    return raw.trim().toUpperCase();
  }
}
