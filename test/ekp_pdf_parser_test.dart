import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:presensi/features/skp/data/services/ekp_pdf_parser.dart';

void main() {
  test('EkpPdfParser successfully parses and validates ekp-dokumen.pdf', () async {
    final file = File('../ekp-dokumen.pdf');
    expect(file.existsSync(), isTrue);

    final data = await EkpPdfParser.parseFile(file);

    expect(data.judulDokumen, 'DOKUMEN EVALUASI KINERJA PEGAWAI');
    expect(data.pegawaiNama, contains('JEMMA'));
    expect(data.pegawaiNip, '198107252011011009');
    expect(data.pegawaiJabatan, contains('Pranata Komputer'));
    expect(data.penilaiNama, contains('MUH. NURHATIP'));
    expect(data.penilaiNip, '198001312011011002');
    expect(data.atasanNama, contains('SYAMSUDDIN'));
    expect(data.atasanNip, '197101191991011002');
    expect(data.capaianOrganisasi, '-');
    expect(data.predikatKinerja, 'Baik');
    expect(data.periodYear, 2026);
    expect(data.periodStartMonth, 1);
    expect(data.periodEndMonth, 3);

    // Test period matching
    expect(data.isPeriodCovered(1, 2026), isTrue);
    expect(data.isPeriodCovered(2, 2026), isTrue);
    expect(data.isPeriodCovered(3, 2026), isTrue);
    expect(data.isPeriodCovered(4, 2026), isFalse);
    expect(data.isPeriodCovered(1, 2025), isFalse);

    // Test map output
    final map = data.toMap();
    expect(map['capaian_kinerja_organisasi'], '-');
    expect(map['predikat_kinerja_pegawai'], 'Baik');
    expect(map['pegawai_dinilai']['nip'], '198107252011011009');
  });

  test('EkpPdfParser throws EkpPdfValidationException on non-EKP text', () {
    expect(
      () => EkpPdfParser.parseText('SURAT KEPUTUSAN BUPATI'),
      throwsA(isA<EkpPdfValidationException>()),
    );
  });
}
