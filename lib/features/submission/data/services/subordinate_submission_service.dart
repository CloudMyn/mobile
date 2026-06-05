import '../models/subordinate_submission_item.dart';
import '../models/submission_item.dart';
import '../models/submission_attachment.dart';

abstract class SubordinateSubmissionService {
  Future<List<SubordinateSubmissionItem>> fetchSubordinateSubmissions({
    required SubmissionStatus status,
  });
  Future<SubordinateSubmissionItem> approveSubmission(int id, String? note);
  Future<SubordinateSubmissionItem> rejectSubmission(int id, String reason);
}

class MockSubordinateSubmissionService implements SubordinateSubmissionService {
  static const _delay = Duration(milliseconds: 600);

  final List<SubordinateSubmissionItem> _submissions = [
    SubordinateSubmissionItem(
      id: 501,
      typeId: 2,
      typeCode: 'cuti_tahunan',
      typeName: 'Cuti Tahunan',
      title: 'Cuti Tahunan Pernikahan',
      description: 'Mengajukan cuti tahunan untuk persiapan pernikahan keluarga dekat.',
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 8)),
      totalDays: 4,
      status: SubmissionStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      subordinateName: 'Budi Santoso',
      subordinateNip: '198001012005011001',
      subordinateAvatar: 'BS',
      attachments: const [
        SubmissionAttachment(
          id: 901,
          fileName: 'undangan_pernikahan.pdf',
          fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          fileSizeKb: 145,
          mimeType: 'application/pdf',
        ),
      ],
    ),
    SubordinateSubmissionItem(
      id: 502,
      typeId: 3,
      typeCode: 'sakit',
      typeName: 'Sakit',
      title: 'Izin Sakit Demam',
      description: 'Sakit demam dan flu berat, disarankan istirahat oleh dokter.',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now(),
      totalDays: 2,
      status: SubmissionStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      subordinateName: 'Siti Aminah',
      subordinateNip: '198502022010012002',
      subordinateAvatar: 'SA',
      attachments: const [
        SubmissionAttachment(
          id: 902,
          fileName: 'surat_keterangan_dokter.jpg',
          fileUrl: 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=800&q=80',
          fileSizeKb: 310,
          mimeType: 'image/jpeg',
        ),
      ],
    ),
    SubordinateSubmissionItem(
      id: 503,
      typeId: 1,
      typeCode: 'izin',
      typeName: 'Izin',
      title: 'Izin Keperluan Keluarga',
      description: 'Mengantar anak ke rumah sakit untuk kontrol rutin bulanan.',
      startDate: DateTime.now().add(const Duration(days: 2)),
      startTime: '08:00',
      endTime: '12:00',
      totalHours: 4,
      status: SubmissionStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      subordinateName: 'Andi Wijaya',
      subordinateNip: '199003032015011003',
      subordinateAvatar: 'AW',
    ),
    SubordinateSubmissionItem(
      id: 504,
      typeId: 4,
      typeCode: 'dinas_luar',
      typeName: 'Dinas Luar',
      title: 'Sosialisasi Sistem Presensi',
      description: 'Menghadiri sosialisasi dan koordinasi sistem presensi di kantor kabupaten.',
      startDate: DateTime.now().subtract(const Duration(days: 10)),
      endDate: DateTime.now().subtract(const Duration(days: 9)),
      totalDays: 2,
      status: SubmissionStatus.approved,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      approvedAt: DateTime.now().subtract(const Duration(days: 11)),
      approvalNote: 'Disetujui. Silakan buat laporan perjalanan dinas setelah selesai.',
      subordinateName: 'Budi Santoso',
      subordinateNip: '198001012005011001',
      subordinateAvatar: 'BS',
      attachments: const [
        SubmissionAttachment(
          id: 904,
          fileName: 'spt_sosialisasi.pdf',
          fileUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          fileSizeKb: 210,
          mimeType: 'application/pdf',
        ),
      ],
    ),
    SubordinateSubmissionItem(
      id: 505,
      typeId: 2,
      typeCode: 'cuti_tahunan',
      typeName: 'Cuti Tahunan',
      title: 'Cuti Tahunan Rekreasi',
      description: 'Cuti tahunan untuk liburan keluarga.',
      startDate: DateTime.now().subtract(const Duration(days: 20)),
      endDate: DateTime.now().subtract(const Duration(days: 16)),
      totalDays: 4,
      status: SubmissionStatus.rejected,
      createdAt: DateTime.now().subtract(const Duration(days: 25)),
      rejectedAt: DateTime.now().subtract(const Duration(days: 24)),
      approvalNote: 'Kuota petugas layanan tidak mencukupi pada tanggal tersebut. Silakan koordinasi ulang jadwal cuti.',
      subordinateName: 'Andi Wijaya',
      subordinateNip: '199003032015011003',
      subordinateAvatar: 'AW',
    ),
  ];

  @override
  Future<List<SubordinateSubmissionItem>> fetchSubordinateSubmissions({
    required SubmissionStatus status,
  }) async {
    await Future.delayed(_delay);
    return _submissions
        .where((s) => s.status == status)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<SubordinateSubmissionItem> approveSubmission(int id, String? note) async {
    await Future.delayed(_delay);
    final idx = _submissions.indexWhere((s) => s.id == id);
    if (idx == -1) throw Exception('Pengajuan tidak ditemukan');
    final item = _submissions[idx];
    final updated = item.copyWith(
      status: SubmissionStatus.approved,
      approvedAt: DateTime.now(),
      approvalNote: note ?? 'Pengajuan disetujui.',
    );
    _submissions[idx] = updated;
    return updated;
  }

  @override
  Future<SubordinateSubmissionItem> rejectSubmission(int id, String reason) async {
    await Future.delayed(_delay);
    if (reason.trim().isEmpty) throw Exception('Alasan penolakan wajib diisi');
    final idx = _submissions.indexWhere((s) => s.id == id);
    if (idx == -1) throw Exception('Pengajuan tidak ditemukan');
    final item = _submissions[idx];
    final updated = item.copyWith(
      status: SubmissionStatus.rejected,
      rejectedAt: DateTime.now(),
      approvalNote: reason,
    );
    _submissions[idx] = updated;
    return updated;
  }
}
