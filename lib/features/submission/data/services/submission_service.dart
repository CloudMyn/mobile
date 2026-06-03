import '../models/submission_item.dart';
import '../models/submission_type.dart';

abstract class SubmissionService {
  Future<List<SubmissionType>> fetchTypes();
  Future<List<SubmissionItem>> fetchSubmissions(int typeId);
  Future<SubmissionItem> createSubmission({
    required int typeId,
    required String title,
    required String description,
    required DateTime startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    Map<String, String?>? attachments,
  });
  Future<void> deleteSubmission(int id);
}

class MockSubmissionService implements SubmissionService {
  static const _delay = Duration(milliseconds: 600);

  static final _types = <SubmissionType>[
    const SubmissionType(
      id: 1,
      code: 'izin',
      name: 'Izin',
      description: 'Pengajuan izin tidak masuk kerja untuk keperluan pribadi atau keluarga.',
      deductsLeaveBalance: false,
      approverName: 'Drs. Ahmad Fauzi, M.Si.',
      approverPosition: 'Kepala Bagian SDM',
      maxDays: 3,
      allowDateRange: false,
      allowTimeRange: true,
      defaultYearlyQuota: 0,
      allowCarryForward: false,
      isActive: true,
      attachmentFields: [
        AttachmentFieldConfig(id: 'surat_izin', name: 'Surat Izin', isRequired: false),
      ],
    ),
    const SubmissionType(
      id: 2,
      code: 'cuti_tahunan',
      name: 'Cuti Tahunan',
      description: 'Hak cuti tahunan pegawai sesuai ketentuan yang berlaku.',
      deductsLeaveBalance: true,
      approverName: 'Hj. Siti Rahmawati, S.E., M.M.',
      approverPosition: 'Kepala Dinas',
      maxDays: 12,
      allowDateRange: true,
      allowTimeRange: false,
      defaultYearlyQuota: 12,
      allowCarryForward: true,
      isActive: true,
      attachmentFields: [],
    ),
    const SubmissionType(
      id: 3,
      code: 'sakit',
      name: 'Sakit',
      description: 'Pengajuan izin sakit dengan melampirkan surat keterangan dokter.',
      deductsLeaveBalance: false,
      approverName: 'Drs. Ahmad Fauzi, M.Si.',
      approverPosition: 'Kepala Bagian SDM',
      maxDays: 14,
      allowDateRange: true,
      allowTimeRange: false,
      defaultYearlyQuota: 0,
      allowCarryForward: false,
      isActive: true,
      attachmentFields: [
        AttachmentFieldConfig(id: 'surat_sakit', name: 'Surat Keterangan Sakit', isRequired: true),
      ],
    ),
    const SubmissionType(
      id: 4,
      code: 'dinas_luar',
      name: 'Dinas Luar',
      description: 'Perjalanan dinas ke luar kantor atas perintah pimpinan.',
      deductsLeaveBalance: false,
      approverName: 'Hj. Siti Rahmawati, S.E., M.M.',
      approverPosition: 'Kepala Dinas',
      maxDays: 30,
      allowDateRange: true,
      allowTimeRange: true,
      defaultYearlyQuota: 0,
      allowCarryForward: false,
      isActive: true,
      attachmentFields: [
        AttachmentFieldConfig(id: 'spt', name: 'Surat Perintah Tugas (SPT)', isRequired: true),
        AttachmentFieldConfig(id: 'sppd', name: 'Surat Perjalanan Dinas (SPPD)', isRequired: false),
      ],
    ),
  ];

  final _submissionsMap = <int, List<SubmissionItem>>{
    1: [
      SubmissionItem(
        id: 101,
        typeId: 1,
        typeCode: 'izin',
        typeName: 'Izin',
        title: 'Izin acara keluarga',
        description: 'Menghadiri acara pernikahan saudara kandung di Makassar.',
        startDate: DateTime(2026, 5, 10),
        startTime: '08:00',
        endTime: '17:00',
        status: SubmissionStatus.approved,
        createdAt: DateTime(2026, 5, 8),
        attachments: const [], // Mock handles attachments separately or we can omit it for now
        approvalNote: 'Pengajuan disetujui. Pastikan pekerjaan sudah didelegasikan kepada rekan sebelum meninggalkan kantor.',
      ),
      SubmissionItem(
        id: 102,
        typeId: 1,
        typeCode: 'izin',
        typeName: 'Izin',
        title: 'Izin keperluan pribadi',
        description: 'Mengurus dokumen administrasi kependudukan.',
        startDate: DateTime(2026, 5, 20),
        status: SubmissionStatus.pending,
        createdAt: DateTime(2026, 5, 13),
      ),
    ],
    2: [
      SubmissionItem(
        id: 201,
        typeId: 2,
        typeCode: 'cuti_tahunan',
        typeName: 'Cuti Tahunan',
        title: 'Cuti lebaran',
        description: 'Cuti tahunan dalam rangka hari raya Idul Fitri.',
        startDate: DateTime(2026, 3, 28),
        endDate: DateTime(2026, 4, 5),
        status: SubmissionStatus.approved,
        createdAt: DateTime(2026, 3, 20),
        approvalNote: 'Disetujui. Saldo cuti dikurangi 9 hari. Sisa saldo cuti: 3 hari.',
      ),
      SubmissionItem(
        id: 202,
        typeId: 2,
        typeCode: 'cuti_tahunan',
        typeName: 'Cuti Tahunan',
        title: 'Cuti akhir tahun',
        description: 'Cuti tahunan untuk merayakan pergantian tahun bersama keluarga.',
        startDate: DateTime(2026, 12, 29),
        endDate: DateTime(2026, 12, 31),
        status: SubmissionStatus.rejected,
        createdAt: DateTime(2026, 5, 10),
        approvalNote: 'Ditolak karena bertepatan dengan periode tutup buku akhir tahun. Silakan ajukan kembali di luar periode tersebut.',
      ),
    ],
    3: [],
    4: [
      SubmissionItem(
        id: 401,
        typeId: 4,
        typeCode: 'dinas_luar',
        typeName: 'Dinas Luar',
        title: 'Bimtek pengelolaan keuangan daerah',
        description: 'Mengikuti bimbingan teknis pengelolaan keuangan daerah di Jakarta.',
        startDate: DateTime(2026, 6, 2),
        endDate: DateTime(2026, 6, 5),
        startTime: '07:00',
        endTime: '17:00',
        status: SubmissionStatus.pending,
        createdAt: DateTime(2026, 5, 12),
      ),
    ],
  };

  @override
  Future<List<SubmissionType>> fetchTypes() async {
    await Future.delayed(_delay);
    return _types;
  }

  @override
  Future<List<SubmissionItem>> fetchSubmissions(int typeId) async {
    await Future.delayed(_delay);
    return List.unmodifiable(_submissionsMap[typeId] ?? []);
  }

  @override
  Future<SubmissionItem> createSubmission({
    required int typeId,
    required String title,
    required String description,
    required DateTime startDate,
    DateTime? endDate,
    String? startTime,
    String? endTime,
    Map<String, String?>? attachments,
  }) async {
    await Future.delayed(_delay);
    final type = _types.firstWhere((t) => t.id == typeId);
    final item = SubmissionItem(
      id: DateTime.now().millisecondsSinceEpoch,
      typeId: typeId,
      typeCode: type.code,
      typeName: type.name,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      status: SubmissionStatus.pending,
      createdAt: DateTime.now(),
    );
    _submissionsMap.putIfAbsent(typeId, () => []);
    _submissionsMap[typeId]!.insert(0, item);
    return item;
  }

  @override
  Future<void> deleteSubmission(int id) async {
    await Future.delayed(_delay);
    for (final list in _submissionsMap.values) {
      list.removeWhere((item) => item.id == id);
    }
  }
}
