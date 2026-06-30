import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/api_response.dart';
import '../models/activity_item.dart';
import '../models/activity_type.dart';
import '../models/monthly_activity_stats.dart';

abstract class KinerjaService {
  Future<List<ActivityType>> fetchTypes();
  Future<List<ActivityItem>> fetchActivities({
    required int month,
    required int year,
    int page = 1,
    int pageSize = 20,
  });
  Future<MonthlyActivityStats> fetchMonthlyStats({
    required int month,
    required int year,
  });
  Future<ActivityItem> createActivity({
    required String typeId,
    required String description,
    String? imagePath,
    String? startTime,
    String? endTime,
    String? status,
    DateTime? date,
  });
  Future<ActivityItem> updateActivity({
    required String id,
    required String typeId,
    required String description,
    String? imagePath,
    String? startTime,
    String? endTime,
    String? status,
    DateTime? date,
  });
  Future<void> deleteActivity(String id);
  Future<String?> fetchAttendanceByDate(DateTime date);
}

class MockKinerjaService implements KinerjaService {
  static const _delay = Duration(milliseconds: 600);

  static final _types = <ActivityType>[
    const ActivityType(
      id: 'kedinasan',
      name: 'Kegiatan Kedinasan',
      description: 'Kegiatan operasional dan administrasi kedinasan sehari-hari.',
      icon: Icons.work_history_rounded,
    ),
    const ActivityType(
      id: 'bimtek',
      name: 'Bimbingan Teknis',
      description: 'Pelatihan, workshop, dan bimbingan teknis peningkatan kompetensi.',
      icon: Icons.school_rounded,
    ),
    const ActivityType(
      id: 'rakor',
      name: 'Rapat Koordinasi',
      description: 'Rapat koordinasi internal maupun lintas sektor/instansi.',
      icon: Icons.groups_rounded,
    ),
    const ActivityType(
      id: 'pelayanan',
      name: 'Pelayanan Masyarakat',
      description: 'Kegiatan pelayanan langsung kepada masyarakat.',
      icon: Icons.handshake_rounded,
    ),
    const ActivityType(
      id: 'lainnya',
      name: 'Kegiatan Lainnya',
      description: 'Kegiatan lain yang menunjang tugas dan fungsi.',
      icon: Icons.assignment_rounded,
    ),
  ];

  final _activities = <ActivityItem>[
    // ── Mei 2026 ─────────────────────────────────────────────
    ActivityItem(
      id: 'k_001',
      typeId: 'kedinasan',
      typeName: 'Kegiatan Kedinasan',
      description: 'Menyusun laporan capaian kinerja triwulan II',
      date: DateTime(2026, 5, 13),
      createdAt: DateTime(2026, 5, 13, 8, 30),
      startTime: '08:00',
      endTime: '12:00',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_002',
      typeId: 'rakor',
      typeName: 'Rapat Koordinasi',
      description: 'Rapat koordinasi lintas sektor program pembangunan infrastruktur',
      date: DateTime(2026, 5, 12),
      createdAt: DateTime(2026, 5, 12, 9, 0),
      startTime: '09:00',
      endTime: '11:30',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_003',
      typeId: 'pelayanan',
      typeName: 'Pelayanan Masyarakat',
      description: 'Melayani pengaduan masyarakat terkait layanan administrasi',
      date: DateTime(2026, 5, 12),
      createdAt: DateTime(2026, 5, 12, 10, 15),
      startTime: '10:00',
      endTime: '14:00',
      status: 'Belum Selesai',
    ),
    ActivityItem(
      id: 'k_004',
      typeId: 'kedinasan',
      typeName: 'Kegiatan Kedinasan',
      description: 'Verifikasi berkas usulan kenaikan pangkat',
      date: DateTime(2026, 5, 11),
      createdAt: DateTime(2026, 5, 11, 8, 0),
      startTime: '08:00',
      endTime: '10:30',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_005',
      typeId: 'bimtek',
      typeName: 'Bimbingan Teknis',
      description: 'Bimtek pengelolaan Sistem Informasi Pemerintahan Daerah (SIPD)',
      date: DateTime(2026, 5, 10),
      createdAt: DateTime(2026, 5, 10, 7, 45),
      startTime: '08:00',
      endTime: '16:00',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_006',
      typeId: 'rakor',
      typeName: 'Rapat Koordinasi',
      description: 'Rapat persiapan evaluasi kinerja tengah tahun',
      date: DateTime(2026, 5, 8),
      createdAt: DateTime(2026, 5, 8, 9, 30),
      startTime: '09:30',
      endTime: '12:00',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_007',
      typeId: 'pelayanan',
      typeName: 'Pelayanan Masyarakat',
      description: 'Sosialisasi program layanan administrasi terpadu',
      date: DateTime(2026, 5, 7),
      createdAt: DateTime(2026, 5, 7, 13, 0),
      startTime: '13:00',
      endTime: '15:30',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_008',
      typeId: 'lainnya',
      typeName: 'Kegiatan Lainnya',
      description: 'Mengikuti upacara bendera Hari Kebangkitan Nasional',
      date: DateTime(2026, 5, 6),
      createdAt: DateTime(2026, 5, 6, 7, 0),
      startTime: '07:00',
      endTime: '08:30',
      status: 'Selesai',
    ),
    // ── April 2026 ────────────────────────────────────────────
    ActivityItem(
      id: 'k_009',
      typeId: 'kedinasan',
      typeName: 'Kegiatan Kedinasan',
      description: 'Menyusun rencana kebutuhan anggaran bulanan',
      date: DateTime(2026, 4, 30),
      createdAt: DateTime(2026, 4, 30, 8, 15),
      startTime: '08:15',
      endTime: '11:00',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_010',
      typeId: 'rakor',
      typeName: 'Rapat Koordinasi',
      description: 'Rapat koordinasi persiapan kegiatan hari jadi kabupaten',
      date: DateTime(2026, 4, 28),
      createdAt: DateTime(2026, 4, 28, 10, 0),
      startTime: '10:00',
      endTime: '13:00',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_011',
      typeId: 'bimtek',
      typeName: 'Bimbingan Teknis',
      description: 'Workshop penyusunan Standar Operasional Prosedur (SOP)',
      date: DateTime(2026, 4, 25),
      createdAt: DateTime(2026, 4, 25, 8, 0),
      startTime: '08:00',
      endTime: '15:00',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_012',
      typeId: 'pelayanan',
      typeName: 'Pelayanan Masyarakat',
      description: 'Pelayanan pembuatan dokumen kependudukan',
      date: DateTime(2026, 4, 24),
      createdAt: DateTime(2026, 4, 24, 13, 30),
      startTime: '13:30',
      endTime: '16:00',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_013',
      typeId: 'lainnya',
      typeName: 'Kegiatan Lainnya',
      description: 'Gotong royong pembersihan lingkungan kantor',
      date: DateTime(2026, 4, 22),
      createdAt: DateTime(2026, 4, 22, 7, 30),
      startTime: '07:30',
      endTime: '09:30',
      status: 'Selesai',
    ),
    // ── Maret 2026 ────────────────────────────────────────────
    ActivityItem(
      id: 'k_014',
      typeId: 'kedinasan',
      typeName: 'Kegiatan Kedinasan',
      description: 'Penginputan data capaian kinerja bulan Maret',
      date: DateTime(2026, 3, 31),
      createdAt: DateTime(2026, 3, 31, 9, 0),
      startTime: '09:00',
      endTime: '12:00',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_015',
      typeId: 'rakor',
      typeName: 'Rapat Koordinasi',
      description: 'Rapat evaluasi program kerja triwulan I',
      date: DateTime(2026, 3, 28),
      createdAt: DateTime(2026, 3, 28, 10, 0),
      startTime: '10:00',
      endTime: '12:30',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_016',
      typeId: 'pelayanan',
      typeName: 'Pelayanan Masyarakat',
      description: 'Pelayanan pembuatan KTP dan KK',
      date: DateTime(2026, 3, 25),
      createdAt: DateTime(2026, 3, 25, 8, 30),
      startTime: '08:30',
      endTime: '14:30',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_017',
      typeId: 'bimtek',
      typeName: 'Bimbingan Teknis',
      description: 'Bimtek penggunaan aplikasi e-office',
      date: DateTime(2026, 3, 20),
      createdAt: DateTime(2026, 3, 20, 9, 0),
      startTime: '09:00',
      endTime: '16:00',
      status: 'Selesai',
    ),
    ActivityItem(
      id: 'k_018',
      typeId: 'lainnya',
      typeName: 'Kegiatan Lainnya',
      description: 'Apel pagi gabungan seluruh SKPD',
      date: DateTime(2026, 3, 17),
      createdAt: DateTime(2026, 3, 17, 7, 0),
      startTime: '07:00',
      endTime: '08:00',
      status: 'Selesai',
    ),
  ];

  @override
  Future<List<ActivityType>> fetchTypes() async {
    await Future.delayed(_delay);
    return List.unmodifiable(_types);
  }

  @override
  Future<List<ActivityItem>> fetchActivities({
    required int month,
    required int year,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(_delay);
    final filtered = _activities
        .where((a) => a.date.month == month && a.date.year == year)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final start = (page - 1) * pageSize;
    if (start >= filtered.length) return [];
    final end = start + pageSize > filtered.length
        ? filtered.length
        : start + pageSize;
    return filtered.sublist(start, end);
  }

  @override
  Future<MonthlyActivityStats> fetchMonthlyStats({
    required int month,
    required int year,
  }) async {
    await Future.delayed(_delay);

    final monthlyActivities = _activities
        .where((a) => a.date.month == month && a.date.year == year)
        .toList();

    final byCategory = <String, int>{};
    for (final a in monthlyActivities) {
      byCategory[a.typeName] = (byCategory[a.typeName] ?? 0) + 1;
    }

    final target = switch (month) {
      1 => 20, // Januari
      2 => 18, // Februari
      3 => 22, // Maret
      4 => 20, // April
      5 => 22, // Mei
      6 => 20, // Juni
      7 => 22, // Juli
      8 => 22, // Agustus
      9 => 20, // September
      10 => 22, // Oktober
      11 => 20, // November
      12 => 20, // Desember
      _ => 20,
    };

    return MonthlyActivityStats(
      totalActivities: monthlyActivities.length,
      activitiesByCategory: Map.from(byCategory),
      target: target,
      month: month,
      year: year,
    );
  }

  @override
  Future<ActivityItem> createActivity({
    required String typeId,
    required String description,
    String? imagePath,
    String? startTime,
    String? endTime,
    String? status,
    DateTime? date,
  }) async {
    await Future.delayed(_delay);

    final type = _types.firstWhere((t) => t.id == typeId);
    final item = ActivityItem(
      id: 'k_${DateTime.now().millisecondsSinceEpoch}',
      typeId: typeId,
      typeName: type.name,
      description: description,
      date: date ?? DateTime.now(),
      imageUrl: imagePath,
      createdAt: DateTime.now(),
      startTime: startTime,
      endTime: endTime,
      status: status,
    );

    _activities.insert(0, item);
    return item;
  }

  @override
  Future<ActivityItem> updateActivity({
    required String id,
    required String typeId,
    required String description,
    String? imagePath,
    String? startTime,
    String? endTime,
    String? status,
    DateTime? date,
  }) async {
    await Future.delayed(_delay);

    final type = _types.firstWhere((t) => t.id == typeId);
    final index = _activities.indexWhere((a) => a.id == id);

    if (index == -1) {
      throw Exception('Aktivitas dengan id $id tidak ditemukan');
    }

    final updated = _activities[index].copyWith(
      typeId: typeId,
      typeName: type.name,
      description: description,
      imageUrl: imagePath,
      startTime: startTime,
      endTime: endTime,
      status: status,
      date: date,
    );
    _activities[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteActivity(String id) async {
    await Future.delayed(_delay);
    _activities.removeWhere((a) => a.id == id);
  }

  @override
  Future<String?> fetchAttendanceByDate(DateTime date) async {
    await Future.delayed(_delay);
    // Mock clock in time
    return '08:00';
  }
}

class ApiKinerjaService implements KinerjaService {
  final Dio _dio;

  ApiKinerjaService(this._dio);

  @override
  Future<List<ActivityType>> fetchTypes() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/activity-types');
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => (data as List)
            .map((e) => ActivityType.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return envelope.data?.where((t) => t.id.isNotEmpty).toList() ?? [];
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat jenis kegiatan');
    }
  }

  @override
  Future<List<ActivityItem>> fetchActivities({
    required int month,
    required int year,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/activities',
        queryParameters: {
          'month': month,
          'year': year,
          'page': page,
          'per_page': pageSize,
        },
      );
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) {
          final list = (data as Map<String, dynamic>)['data'] as List;
          return list.map((e) => ActivityItem.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
      return envelope.data ?? [];
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat daftar kinerja');
    }
  }

  @override
  Future<MonthlyActivityStats> fetchMonthlyStats({
    required int month,
    required int year,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/activities/stats',
        queryParameters: {
          'month': month,
          'year': year,
        },
      );
      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => MonthlyActivityStats.fromJson(data as Map<String, dynamic>),
      );
      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memuat statistik bulanan');
    }
  }

  @override
  Future<ActivityItem> createActivity({
    required String typeId,
    required String description,
    String? imagePath,
    String? startTime,
    String? endTime,
    String? status,
    DateTime? date,
  }) async {
    try {
      final activityDate = date ?? DateTime.now();
      final dateStr = '${activityDate.year}-${activityDate.month.toString().padLeft(2, '0')}-${activityDate.day.toString().padLeft(2, '0')}';
      
      final Map<String, dynamic> fields = {
        'activity_type_id': typeId,
        'activity_date': dateStr,
        'description': description,
        'auto_submit': status == 'Selesai' ? 'true' : 'false',
      };
      
      if (startTime != null && startTime.isNotEmpty) {
        fields['start_at'] = startTime;
      }
      if (endTime != null && endTime.isNotEmpty) {
        fields['end_at'] = endTime;
      }

      FormData formData;
      if (imagePath != null && imagePath.isNotEmpty) {
        formData = FormData.fromMap({
          ...fields,
          'file_attachments[]': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        });
      } else {
        formData = FormData.fromMap(fields);
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/activities',
        data: formData,
      );

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => ActivityItem.fromJson(data as Map<String, dynamic>),
      );
      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal mencatat kinerja');
    }
  }

  @override
  Future<ActivityItem> updateActivity({
    required String id,
    required String typeId,
    required String description,
    String? imagePath,
    String? startTime,
    String? endTime,
    String? status,
    DateTime? date,
  }) async {
    try {
      final activityDate = date ?? DateTime.now();
      final dateStr = '${activityDate.year}-${activityDate.month.toString().padLeft(2, '0')}-${activityDate.day.toString().padLeft(2, '0')}';

      final Map<String, dynamic> fields = {
        'activity_type_id': typeId,
        'activity_date': dateStr,
        'description': description,
        'auto_submit': status == 'Selesai' ? 'true' : 'false',
        '_method': 'PUT',
      };

      if (startTime != null && startTime.isNotEmpty) {
        fields['start_at'] = startTime;
      }
      if (endTime != null && endTime.isNotEmpty) {
        fields['end_at'] = endTime;
      }

      FormData formData;
      if (imagePath != null && imagePath.isNotEmpty && !imagePath.startsWith('http')) {
        formData = FormData.fromMap({
          ...fields,
          'file_attachments[]': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        });
      } else {
        formData = FormData.fromMap(fields);
      }

      final response = await _dio.post<Map<String, dynamic>>(
        '/activities/$id',
        data: formData,
      );

      final envelope = ApiResponse.fromJson(
        response.data!,
        (data) => ActivityItem.fromJson(data as Map<String, dynamic>),
      );
      return envelope.data!;
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal memperbarui kinerja');
    }
  }

  @override
  Future<void> deleteActivity(String id) async {
    try {
      await _dio.delete<void>('/activities/$id');
    } on DioException catch (e) {
      throw _mapDioError(e, 'Gagal menghapus kinerja');
    }
  }

  @override
  Future<String?> fetchAttendanceByDate(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _dio.get<Map<String, dynamic>>('/mobile/presensi/date/$dateStr');
      final data = response.data?['data'];
      
      if (data != null && data['records'] != null) {
        final records = data['records'] as List;
        for (var record in records) {
          if (record['status'] != 'pending' && record['status'] != 'absent') {
            final attendedAt = record['attended_at'];
            if (attendedAt != null) {
              final dt = DateTime.parse(attendedAt.toString()).toUtc().add(const Duration(hours: 8));
              return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
            }
          }
        }
      }
      return null;
    } catch (e) {
      // Don't throw error, just return null if fail to fetch attendance
      return null;
    }
  }

  Exception _mapDioError(DioException e, String fallbackMessage) {
    final err = e.error;
    if (err is ApiException) return err;
    if (err is NetworkException) return err;

    return ApiException(
      statusCode: e.response?.statusCode ?? 0,
      message: e.message ?? fallbackMessage,
    );
  }
}
