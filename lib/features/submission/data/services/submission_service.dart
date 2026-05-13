import 'package:flutter/material.dart';
import '../models/submission_item.dart';
import '../models/submission_type.dart';

abstract class SubmissionService {
  Future<List<SubmissionType>> fetchTypes();
  Future<List<SubmissionItem>> fetchSubmissions(String typeId);
  Future<SubmissionItem> createSubmission({
    required String typeId,
    required String title,
    required String description,
    required DateTime startDate,
    DateTime? endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Map<String, String?>? attachments,
  });
  Future<void> deleteSubmission(String id);
}

class MockSubmissionService implements SubmissionService {
  static const _delay = Duration(milliseconds: 600);

  static final _types = <SubmissionType>[
    const SubmissionType(
      id: 'izin',
      name: 'Izin',
      description: 'Pengajuan izin tidak masuk kerja untuk keperluan pribadi atau keluarga.',
      deductsLeaveBalance: false,
      approverName: 'Drs. Ahmad Fauzi, M.Si.',
      approverPosition: 'Kepala Bagian SDM',
      maxDays: 3,
      allowDateRange: false,
      allowTimeRange: true,
      attachmentFields: [
        AttachmentFieldConfig(id: 'surat_izin', name: 'Surat Izin', isRequired: false),
      ],
      icon: Icons.event_busy_rounded,
    ),
    const SubmissionType(
      id: 'cuti_tahunan',
      name: 'Cuti Tahunan',
      description: 'Hak cuti tahunan pegawai sesuai ketentuan yang berlaku.',
      deductsLeaveBalance: true,
      approverName: 'Hj. Siti Rahmawati, S.E., M.M.',
      approverPosition: 'Kepala Dinas',
      maxDays: 12,
      allowDateRange: true,
      allowTimeRange: false,
      attachmentFields: [],
      icon: Icons.beach_access_rounded,
    ),
    const SubmissionType(
      id: 'sakit',
      name: 'Sakit',
      description: 'Pengajuan izin sakit dengan melampirkan surat keterangan dokter.',
      deductsLeaveBalance: false,
      approverName: 'Drs. Ahmad Fauzi, M.Si.',
      approverPosition: 'Kepala Bagian SDM',
      maxDays: 14,
      allowDateRange: true,
      allowTimeRange: false,
      attachmentFields: [
        AttachmentFieldConfig(id: 'surat_sakit', name: 'Surat Keterangan Sakit', isRequired: true),
      ],
      icon: Icons.local_hospital_rounded,
    ),
    const SubmissionType(
      id: 'dinas_luar',
      name: 'Dinas Luar',
      description: 'Perjalanan dinas ke luar kantor atas perintah pimpinan.',
      deductsLeaveBalance: false,
      approverName: 'Hj. Siti Rahmawati, S.E., M.M.',
      approverPosition: 'Kepala Dinas',
      maxDays: 30,
      allowDateRange: true,
      allowTimeRange: true,
      attachmentFields: [
        AttachmentFieldConfig(id: 'spt', name: 'Surat Perintah Tugas (SPT)', isRequired: true),
        AttachmentFieldConfig(id: 'sppd', name: 'Surat Perjalanan Dinas (SPPD)', isRequired: false),
      ],
      icon: Icons.flight_rounded,
    ),
  ];

  final _submissionsMap = <String, List<SubmissionItem>>{
    'izin': [
      SubmissionItem(
        id: 'izin_1',
        typeId: 'izin',
        typeName: 'Izin',
        title: 'Izin acara keluarga',
        description: 'Menghadiri acara pernikahan saudara kandung di Makassar.',
        startDate: DateTime(2026, 5, 10),
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
        status: SubmissionStatus.approved,
        createdAt: DateTime(2026, 5, 8),
        attachmentNames: ['surat_izin.pdf'],
        approvalNote: 'Pengajuan disetujui. Pastikan pekerjaan sudah didelegasikan kepada rekan sebelum meninggalkan kantor.',
      ),
      SubmissionItem(
        id: 'izin_2',
        typeId: 'izin',
        typeName: 'Izin',
        title: 'Izin keperluan pribadi',
        description: 'Mengurus dokumen administrasi kependudukan.',
        startDate: DateTime(2026, 5, 20),
        status: SubmissionStatus.pending,
        createdAt: DateTime(2026, 5, 13),
      ),
    ],
    'cuti_tahunan': [
      SubmissionItem(
        id: 'cuti_1',
        typeId: 'cuti_tahunan',
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
        id: 'cuti_2',
        typeId: 'cuti_tahunan',
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
    'sakit': [],
    'dinas_luar': [
      SubmissionItem(
        id: 'dinas_1',
        typeId: 'dinas_luar',
        typeName: 'Dinas Luar',
        title: 'Bimtek pengelolaan keuangan daerah',
        description: 'Mengikuti bimbingan teknis pengelolaan keuangan daerah di Jakarta.',
        startDate: DateTime(2026, 6, 2),
        endDate: DateTime(2026, 6, 5),
        startTime: const TimeOfDay(hour: 7, minute: 0),
        endTime: const TimeOfDay(hour: 17, minute: 0),
        status: SubmissionStatus.pending,
        createdAt: DateTime(2026, 5, 12),
        attachmentNames: ['SPT_001.pdf'],
      ),
    ],
  };

  @override
  Future<List<SubmissionType>> fetchTypes() async {
    await Future.delayed(_delay);
    return _types;
  }

  @override
  Future<List<SubmissionItem>> fetchSubmissions(String typeId) async {
    await Future.delayed(_delay);
    return List.unmodifiable(_submissionsMap[typeId] ?? []);
  }

  @override
  Future<SubmissionItem> createSubmission({
    required String typeId,
    required String title,
    required String description,
    required DateTime startDate,
    DateTime? endDate,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    Map<String, String?>? attachments,
  }) async {
    await Future.delayed(_delay);
    final type = _types.firstWhere((t) => t.id == typeId);
    final item = SubmissionItem(
      id: '${typeId}_${DateTime.now().millisecondsSinceEpoch}',
      typeId: typeId,
      typeName: type.name,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      status: SubmissionStatus.pending,
      createdAt: DateTime.now(),
      attachmentNames: attachments?.values.whereType<String>().toList() ?? [],
    );
    _submissionsMap.putIfAbsent(typeId, () => []);
    _submissionsMap[typeId]!.insert(0, item);
    return item;
  }

  @override
  Future<void> deleteSubmission(String id) async {
    await Future.delayed(_delay);
    for (final list in _submissionsMap.values) {
      list.removeWhere((item) => item.id == id);
    }
  }
}
