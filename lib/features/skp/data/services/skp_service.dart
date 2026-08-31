import 'dart:math';
import '../models/skp_report_model.dart';

abstract class SkpService {
  Future<List<SkpReportModel>> getReports();
  Future<List<SkpReportModel>> getSubordinateReports();
  Future<SkpReportModel> saveReport(SkpReportModel report);
  Future<bool> deleteReport(int id);
  Future<bool> approveReport(int id, bool isApproved);
}

class MockSkpService implements SkpService {
  final List<SkpReportModel> _mockData = [
    SkpReportModel(
      id: 1,
      filename: 'SKP_Januari_2026.pdf',
      uploadDate: DateTime.now().subtract(const Duration(days: 30)),
      periodMonth: 1,
      periodYear: 2026,
      status: 'disetujui',
      items: [
        SkpItem(
          kegiatan: 'Menyusun laporan bulanan kinerja dinas',
          target: '1 Laporan',
          realisasi: '1 Laporan',
        ),
        SkpItem(
          kegiatan: 'Mengikuti rapat evaluasi mingguan',
          target: '4 Kali',
          realisasi: '4 Kali',
        ),
      ],
    ),
  ];

  final List<SkpReportModel> _mockSubordinateData = [
    SkpReportModel(
      id: 101,
      filename: 'SKP_Budi_Februari_2026.pdf',
      uploadDate: DateTime.now().subtract(const Duration(days: 2)),
      periodMonth: 2,
      periodYear: 2026,
      status: 'pending',
      pegawaiName: 'Budi Pratama, S.Kom',
      items: [
        SkpItem(
          kegiatan: 'Melakukan rekapitulasi data absensi',
          target: '1 Dokumen',
          realisasi: '1 Dokumen',
        ),
      ],
    ),
    SkpReportModel(
      id: 102,
      filename: 'SKP_Andi_Januari_2026.pdf',
      uploadDate: DateTime.now().subtract(const Duration(days: 28)),
      periodMonth: 1,
      periodYear: 2026,
      status: 'disetujui',
      pegawaiName: 'Andi Firmansyah, S.STP',
      items: [
        SkpItem(
          kegiatan: 'Penyusunan draft SOP layanan',
          target: '2 Dokumen',
          realisasi: '2 Dokumen',
        ),
      ],
    ),
  ];

  @override
  Future<List<SkpReportModel>> getReports() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [..._mockData];
  }

  @override
  Future<List<SkpReportModel>> getSubordinateReports() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [..._mockSubordinateData];
  }

  @override
  Future<SkpReportModel> saveReport(SkpReportModel report) async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Validasi 1 file SKP hanya berlaku untuk 1 periode bulan
    final alreadyExists = _mockData.any((r) =>
        r.id != report.id &&
        r.periodMonth == report.periodMonth &&
        r.periodYear == report.periodYear);

    if (alreadyExists) {
      throw Exception(
        'Laporan SKP untuk periode ${report.periodMonth}/${report.periodYear} sudah ada. '
        'Silakan hapus laporan sebelumnya terlebih dahulu jika ingin mengunggah laporan baru.',
      );
    }
    
    final isNew = report.id == null;
    final savedReport = report.copyWith(
      id: isNew ? Random().nextInt(1000) + 10 : report.id,
      status: 'pending', // Selalu pending menunggu verifikasi atasan
    );
    
    if (isNew) {
      _mockData.insert(0, savedReport);
    } else {
      final index = _mockData.indexWhere((e) => e.id == savedReport.id);
      if (index != -1) {
        _mockData[index] = savedReport;
      }
    }
    
    return savedReport;
  }

  @override
  Future<bool> deleteReport(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final initialLength = _mockData.length;
    _mockData.removeWhere((r) => r.id == id);
    return _mockData.length < initialLength;
  }

  @override
  Future<bool> approveReport(int id, bool isApproved) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _mockSubordinateData.indexWhere((r) => r.id == id);
    if (index != -1) {
      _mockSubordinateData[index] = _mockSubordinateData[index].copyWith(
        status: isApproved ? 'disetujui' : 'ditolak',
      );
      return true;
    }
    return false;
  }
}
