import 'package:flutter_test/flutter_test.dart';
import 'package:presensi/features/kinerja/data/models/activity_item.dart';
import 'package:presensi/features/kinerja/data/services/kinerja_service.dart';

void main() {
  group('ActivityItem Status Mapping & Getters', () {
    test('maps draft status correctly', () {
      final item = ActivityItem.fromJson({
        'id': 1,
        'activity_type_id': 10,
        'activity_type': {'name': 'Rapat'},
        'description': 'Rapat koordinasi draft',
        'status': 'draft',
      });

      expect(item.status, 'Draft');
      expect(item.rawStatus, 'draft');
      expect(item.isDraft, isTrue);
      expect(item.isPending, isFalse);
      expect(item.isApproved, isFalse);
      expect(item.isEditable, isTrue);
      expect(item.isDeletable, isTrue);
    });

    test('maps submitted status to Pending', () {
      final item = ActivityItem.fromJson({
        'id': 2,
        'activity_type_id': 10,
        'activity_type': {'name': 'Rapat'},
        'description': 'Rapat koordinasi submitted',
        'status': 'submitted',
      });

      expect(item.status, 'Pending');
      expect(item.rawStatus, 'submitted');
      expect(item.isDraft, isFalse);
      expect(item.isPending, isTrue);
      expect(item.isApproved, isFalse);
      expect(item.isEditable, isFalse);
    });

    test('maps approved status to Disetujui', () {
      final item = ActivityItem.fromJson({
        'id': 3,
        'activity_type_id': 10,
        'activity_type': {'name': 'Rapat'},
        'description': 'Rapat koordinasi approved',
        'status': 'approved',
      });

      expect(item.status, 'Disetujui');
      expect(item.rawStatus, 'approved');
      expect(item.isApproved, isTrue);
      expect(item.isDraft, isFalse);
      expect(item.isEditable, isFalse);
    });

    test('maps rejected status to Ditolak', () {
      final item = ActivityItem.fromJson({
        'id': 4,
        'activity_type_id': 10,
        'activity_type': {'name': 'Rapat'},
        'description': 'Rapat koordinasi rejected',
        'status': 'rejected',
        'reject_reason': 'Data tidak lengkap',
      });

      expect(item.status, 'Ditolak');
      expect(item.rawStatus, 'rejected');
      expect(item.isRejected, isTrue);
      expect(item.rejectReason, 'Data tidak lengkap');
    });
  });

  group('MockKinerjaService Draft & Submit', () {
    late MockKinerjaService service;

    setUp(() {
      service = MockKinerjaService();
    });

    test('createActivity with autoSubmit: false creates Draft item', () async {
      final types = await service.fetchTypes();
      final item = await service.createActivity(
        typeId: types.first.id,
        description: 'Tugas harian masih dikerjakan',
        autoSubmit: false,
      );

      expect(item.status, 'Draft');
      expect(item.isDraft, isTrue);
      expect(item.isPending, isFalse);
    });

    test('createActivity with autoSubmit: true creates Pending item', () async {
      final types = await service.fetchTypes();
      final item = await service.createActivity(
        typeId: types.first.id,
        description: 'Tugas harian sudah selesai dan diajukan',
        autoSubmit: true,
      );

      expect(item.status, 'Pending');
      expect(item.isDraft, isFalse);
      expect(item.isPending, isTrue);
    });

    test('submitActivity transitions item to Pending status', () async {
      final types = await service.fetchTypes();
      final draftItem = await service.createActivity(
        typeId: types.first.id,
        description: 'Draft untuk diajukan kemudian',
        autoSubmit: false,
      );

      expect(draftItem.isDraft, isTrue);

      final submittedItem = await service.submitActivity(draftItem.id);
      expect(submittedItem.status, 'Pending');
      expect(submittedItem.isPending, isTrue);
      expect(submittedItem.isDraft, isFalse);
    });
  });
}
