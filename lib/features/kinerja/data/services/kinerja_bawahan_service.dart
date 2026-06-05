import '../models/subordinate_activity_item.dart';

abstract class KinerjaBawahanService {
  Future<int> fetchPendingCount();
  Future<List<SubordinateActivityItem>> fetchSubordinateActivities({
    required ActivityStatus status,
    int page = 1,
    int pageSize = 15,
  });
  Future<SubordinateActivityItem> approveActivity(String id);
  Future<SubordinateActivityItem> rejectActivity(String id, String reason);
}

class MockKinerjaBawahanService implements KinerjaBawahanService {
  static const _delay = Duration(milliseconds: 600);

  final _activities = <SubordinateActivityItem>[
    SubordinateActivityItem(
      id: 'sub_k_001',
      typeId: 'kedinasan',
      typeName: 'Kegiatan Kedinasan',
      description: 'Melakukan rekapitulasi data penduduk bulan Mei',
      date: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      subordinateName: 'Budi Santoso',
      subordinateNip: '198001012005011001',
      subordinateAvatar: 'BS',
      status: ActivityStatus.pending,
    ),
    SubordinateActivityItem(
      id: 'sub_k_002',
      typeId: 'pelayanan',
      typeName: 'Pelayanan Masyarakat',
      description: 'Verifikasi berkas permohonan KTP warga',
      date: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      subordinateName: 'Siti Aminah',
      subordinateNip: '198502022010012002',
      subordinateAvatar: 'SA',
      status: ActivityStatus.pending,
      attachmentUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf', // Mock PDF
    ),
    SubordinateActivityItem(
      id: 'sub_k_003',
      typeId: 'rakor',
      typeName: 'Rapat Koordinasi',
      description: 'Mengikuti rapat koordinasi evaluasi program kerja',
      date: DateTime.now().subtract(const Duration(days: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
      subordinateName: 'Andi Wijaya',
      subordinateNip: '199003032015011003',
      subordinateAvatar: 'AW',
      status: ActivityStatus.approved,
    ),
    SubordinateActivityItem(
      id: 'sub_k_004',
      typeId: 'bimtek',
      typeName: 'Bimbingan Teknis',
      description: 'Bimtek pengelolaan arsip digital',
      date: DateTime.now().subtract(const Duration(days: 3)),
      createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
      subordinateName: 'Budi Santoso',
      subordinateNip: '198001012005011001',
      subordinateAvatar: 'BS',
      status: ActivityStatus.rejected,
      rejectReason: 'Lampiran tidak relevan dengan kegiatan, mohon diperbaiki.',
    ),
    SubordinateActivityItem(
      id: 'sub_k_005',
      typeId: 'kedinasan',
      typeName: 'Kegiatan Kedinasan',
      description: 'Penyusunan laporan akhir bulan',
      date: DateTime.now().subtract(const Duration(days: 4)),
      createdAt: DateTime.now().subtract(const Duration(days: 4, hours: 2)),
      subordinateName: 'Siti Aminah',
      subordinateNip: '198502022010012002',
      subordinateAvatar: 'SA',
      status: ActivityStatus.pending,
    ),
    // Additional items to test pagination
    for (var i = 6; i <= 25; i++)
      SubordinateActivityItem(
        id: 'sub_k_00$i',
        typeId: 'lainnya',
        typeName: 'Kegiatan Lainnya',
        description: 'Kegiatan tambahan bawahan $i',
        date: DateTime.now().subtract(Duration(days: i)),
        createdAt: DateTime.now().subtract(Duration(days: i, hours: 3)),
        subordinateName: i % 2 == 0 ? 'Andi Wijaya' : 'Budi Santoso',
        subordinateNip: i % 2 == 0 ? '199003032015011003' : '198001012005011001',
        subordinateAvatar: i % 2 == 0 ? 'AW' : 'BS',
        status: ActivityStatus.pending,
      ),
  ];

  @override
  Future<int> fetchPendingCount() async {
    await Future.delayed(_delay);
    return _activities.where((a) => a.status == ActivityStatus.pending).length;
  }

  @override
  Future<List<SubordinateActivityItem>> fetchSubordinateActivities({
    required ActivityStatus status,
    int page = 1,
    int pageSize = 15,
  }) async {
    await Future.delayed(_delay);
    final filtered = _activities
        .where((a) => a.status == status)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final start = (page - 1) * pageSize;
    if (start >= filtered.length) return [];
    
    final end = start + pageSize > filtered.length
        ? filtered.length
        : start + pageSize;
        
    return filtered.sublist(start, end);
  }

  @override
  Future<SubordinateActivityItem> approveActivity(String id) async {
    await Future.delayed(_delay);
    final index = _activities.indexWhere((a) => a.id == id);
    if (index == -1) throw Exception('Activity not found');
    
    final updated = _activities[index].copyWith(
      status: ActivityStatus.approved,
    );
    _activities[index] = updated;
    return updated;
  }

  @override
  Future<SubordinateActivityItem> rejectActivity(String id, String reason) async {
    await Future.delayed(_delay);
    final index = _activities.indexWhere((a) => a.id == id);
    if (index == -1) throw Exception('Activity not found');
    
    if (reason.trim().isEmpty) {
      throw Exception('Alasan penolakan wajib diisi');
    }
    
    final updated = _activities[index].copyWith(
      status: ActivityStatus.rejected,
      rejectReason: reason,
    );
    _activities[index] = updated;
    return updated;
  }
}
