import '../../../auth/data/models/user_model.dart';

/// Model utama response GET /mobile/dashboard.
class DashboardModel {
  const DashboardModel({
    required this.user,
    this.todaySchedule,
    this.pendingSubmission,
    this.currentTpp,
    required this.unreadNotificationsCount,
    this.institutionInfo,
    required this.attendanceTypes,
    this.settings,
  });

  final UserModel user;
  final TodaySchedule? todaySchedule;
  final DashboardPendingSubmission? pendingSubmission;
  final DashboardTpp? currentTpp;
  final int unreadNotificationsCount;
  final DashboardInstitutionInfo? institutionInfo;
  final List<AttendanceTypeConfig> attendanceTypes;
  final Map<String, dynamic>? settings;

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      todaySchedule: json['today_schedule'] != null
          ? TodaySchedule.fromJson(
              json['today_schedule'] as Map<String, dynamic>,
            )
          : null,
      pendingSubmission: json['pending_submission'] != null
          ? DashboardPendingSubmission.fromJson(
              json['pending_submission'] as Map<String, dynamic>,
            )
          : null,
      currentTpp: json['current_tpp'] != null
          ? DashboardTpp.fromJson(json['current_tpp'] as Map<String, dynamic>)
          : null,
      unreadNotificationsCount:
          int.tryParse(json['unread_notifications_count']?.toString() ?? '') ??
          0,
      institutionInfo: json['institution_info'] != null
          ? DashboardInstitutionInfo.fromJson(
              json['institution_info'] as Map<String, dynamic>,
            )
          : null,
      attendanceTypes: (json['attendance_types'] as List<dynamic>? ?? [])
          .map((e) => AttendanceTypeConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      settings: json['settings'] as Map<String, dynamic>?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Today Schedule
// ─────────────────────────────────────────────────────────────────────────────

class TodaySchedule {
  const TodaySchedule({
    required this.id,
    required this.workDate,
    required this.dayStatus,
    this.scheduledStartAt,
    this.scheduledEndAt,
    required this.isOvernight,
    required this.totalRequiredTypes,
    required this.totalCompletedTypes,
    required this.totalLateMinutes,
    required this.totalEarlyLeaveMinutes,
    required this.totalWorkMinutes,
    this.schedule,
    this.scheduledLocation,
    required this.records,
    required this.shiftNo,
  });

  final int id;
  final String workDate;
  final String dayStatus; // "Workday" | "Holiday" | "Weekend"
  final String? scheduledStartAt;
  final String? scheduledEndAt;
  final bool isOvernight;
  final int totalRequiredTypes;
  final int totalCompletedTypes;
  final int totalLateMinutes;
  final int totalEarlyLeaveMinutes;
  final int totalWorkMinutes;
  final ScheduleInfo? schedule;
  final ScheduleLocation? scheduledLocation;
  final List<TodayRecord> records;
  final int shiftNo;

  bool get isWorkday {
    final status = dayStatus.toLowerCase();
    return status == 'workday' || status == 'partial' || status == 'present';
  }

  String get dayStatusLabel {
    final status = dayStatus.toLowerCase();
    return switch (status) {
      'workday' => 'Hari Kerja',
      'partial' => 'Hari Kerja Sebagian',
      'present' => 'Hadir',
      'holiday' => 'Hari Libur',
      'weekend' => 'Akhir Pekan',
      _ => dayStatus,
    };
  }

  bool get allCompleted => totalCompletedTypes >= totalRequiredTypes;

  factory TodaySchedule.fromJson(Map<String, dynamic> json) {
    return TodaySchedule(
      id: json['id'] as int,
      workDate: json['work_date'] as String,
      dayStatus: json['day_status'] as String? ?? 'Workday',
      scheduledStartAt: json['scheduled_start_at'] as String?,
      scheduledEndAt: json['scheduled_end_at'] as String?,
      isOvernight: json['is_overnight'] as bool? ?? false,
      totalRequiredTypes: json['total_required_types'] as int? ?? 0,
      totalCompletedTypes: json['total_completed_types'] as int? ?? 0,
      totalLateMinutes: json['total_late_minutes'] as int? ?? 0,
      totalEarlyLeaveMinutes: json['total_early_leave_minutes'] as int? ?? 0,
      totalWorkMinutes: json['total_work_minutes'] as int? ?? 0,
      schedule: json['schedule'] != null
          ? ScheduleInfo.fromJson(json['schedule'] as Map<String, dynamic>)
          : null,
      scheduledLocation: json['scheduled_location'] != null
          ? ScheduleLocation.fromJson(
              json['scheduled_location'] as Map<String, dynamic>,
              )
          : null,
      records: ((json['records'] as List<dynamic>? ?? [])
              .map((e) => TodayRecord.fromJson(e as Map<String, dynamic>))
              .toList())
            ..sort((a, b) => a.attendanceType.defaultSequence
                .compareTo(b.attendanceType.defaultSequence)),
      shiftNo: json['shift_no'] as int? ?? 1,
    );
  }
}

class ScheduleInfo {
  const ScheduleInfo({
    required this.id,
    required this.name,
    required this.code,
    required this.timezone,
  });

  final int id;
  final String name;
  final String code;
  final String timezone;

  factory ScheduleInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleInfo(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      timezone: json['timezone'] as String? ?? 'Asia/Makassar',
    );
  }
}

class ScheduleLocation {
  const ScheduleLocation({required this.id, required this.name});

  final int id;
  final String name;

  factory ScheduleLocation.fromJson(Map<String, dynamic> json) {
    return ScheduleLocation(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Today Record (slot presensi)
// ─────────────────────────────────────────────────────────────────────────────

class TodayRecord {
  const TodayRecord({
    required this.id,
    required this.sequenceNo,
    required this.attendanceType,
    required this.status,
    this.expectedAt,
    this.windowOpenAt,
    this.windowCloseAt,
    this.attendedAt,
    this.photoUrl,
    this.requiredLocation,
    this.eventGeofence,
    this.effectiveGeofenceMode,
  });

  final int id;
  final int sequenceNo;
  final AttendanceTypeConfig attendanceType;

  /// Status slot: "Pending" | "OnTime" | "Late" | "EarlyLeave" | "InvalidLocation" | "Absent"
  final String status;
  final String? expectedAt;
  final String? windowOpenAt;
  final String? windowCloseAt;
  final String? attendedAt;
  final String? photoUrl;
  final RequiredLocation? requiredLocation;
  final RequiredLocation? eventGeofence;
  final String? effectiveGeofenceMode; // "override" | "additional" | "default"

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isCompleted => attendedAt != null;

  DateTime? get windowOpenDateTime =>
      windowOpenAt != null ? DateTime.tryParse(windowOpenAt!) : null;
  DateTime? get windowCloseDateTime =>
      windowCloseAt != null ? DateTime.tryParse(windowCloseAt!) : null;

  bool get isWindowOpen {
    final now = DateTime.now().toUtc();
    final open = windowOpenDateTime;
    final close = windowCloseDateTime;
    if (open == null || close == null) return false;
    return now.isAfter(open) && now.isBefore(close);
  }

  factory TodayRecord.fromJson(Map<String, dynamic> json) {
    return TodayRecord(
      id: json['id'] as int,
      sequenceNo: json['sequence_no'] as int,
      attendanceType: AttendanceTypeConfig.fromJson(
        json['attendance_type'] as Map<String, dynamic>,
      ),
      status: json['status'] as String? ?? 'Pending',
      expectedAt: json['expected_at'] as String?,
      windowOpenAt: json['window_open_at'] as String?,
      windowCloseAt: json['window_close_at'] as String?,
      attendedAt: json['attended_at'] as String?,
      photoUrl: json['photo_url'] as String?,
      requiredLocation: json['required_location'] != null
          ? RequiredLocation.fromJson(
              json['required_location'] as Map<String, dynamic>,
            )
          : null,
      eventGeofence: json['event_geofence'] != null
          ? RequiredLocation.fromJson(
              json['event_geofence'] as Map<String, dynamic>,
              source: 'event',
            )
          : null,
      effectiveGeofenceMode: json['effective_geofence_mode'] as String?,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Attendance Type Config
// ─────────────────────────────────────────────────────────────────────────────

/// Konfigurasi tipe presensi dari backend.
/// [code] dipakai sebagai URL segment: POST /mobile/presensi/{code}
class AttendanceTypeConfig {
  const AttendanceTypeConfig({
    required this.id,
    required this.code,
    required this.name,
    required this.direction,
    required this.requiresLocation,
    required this.requiresPhoto,
    required this.requiresFaceVerification,
    required this.requiresDeviceLock,
    required this.isSkippable,
    required this.isActive,
    required this.lateToleranceMinutes,
    required this.defaultSequence,
  });

  final int id;
  final String code; // e.g. "check-in", "check-out"
  final String name;
  final String direction; // "In" | "Out" | "Neutral"
  final bool requiresLocation;
  final bool requiresPhoto;
  final bool requiresFaceVerification;
  final bool requiresDeviceLock;
  final bool isSkippable;
  final bool isActive;
  final int lateToleranceMinutes;
  final int defaultSequence;

  factory AttendanceTypeConfig.fromJson(Map<String, dynamic> json) {
    return AttendanceTypeConfig(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String? ?? '',
      direction: json['direction'] as String? ?? 'Neutral',
      requiresLocation: json['requires_location'] as bool? ?? false,
      requiresPhoto: json['requires_photo'] as bool? ?? false,
      requiresFaceVerification:
          json['requires_face_verification'] as bool? ?? false,
      requiresDeviceLock: json['requires_device_lock'] as bool? ?? false,
      isSkippable: json['is_skippable'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      lateToleranceMinutes:
          int.tryParse(json['late_tolerance_minutes']?.toString() ?? '') ?? 0,
      defaultSequence: json['default_sequence'] as int? ?? 0,
    );
  }
}

class RequiredLocation {
  const RequiredLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radiusMeters,
    this.source = 'institution',
  });

  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final int? radiusMeters;
  final String source; // "institution" | "event"

  bool get isEvent => source == 'event';

  factory RequiredLocation.fromJson(Map<String, dynamic> json, {String source = 'institution'}) {
    return RequiredLocation(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      latitude: double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
      radiusMeters: int.tryParse(json['radius_meters']?.toString() ?? ''),
      source: source,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TPP & Submission summary
// ─────────────────────────────────────────────────────────────────────────────

class DashboardTpp {
  const DashboardTpp({
    required this.id,
    required this.periodDate,
    required this.amountBeforeDeduction,
    required this.amountAfterDeduction,
    required this.deductionAmount,
    required this.disciplineScore,
    required this.activityScore,
  });

  final int id;
  final String periodDate; // "2026-05"
  final double amountBeforeDeduction;
  final double amountAfterDeduction;
  final double deductionAmount;
  final double disciplineScore;
  final double activityScore;

  factory DashboardTpp.fromJson(Map<String, dynamic> json) {
    return DashboardTpp(
      id: json['id'] as int,
      periodDate: json['period_date'] as String? ?? '',
      amountBeforeDeduction:
          double.tryParse(json['amount_before_deduction']?.toString() ?? '') ??
          0.0,
      amountAfterDeduction:
          double.tryParse(json['amount_after_deduction']?.toString() ?? '') ??
          0.0,
      deductionAmount:
          double.tryParse(json['deduction_amount']?.toString() ?? '') ?? 0.0,
      disciplineScore:
          (double.tryParse(json['discipline_score']?.toString() ?? '') ?? 0.0) /
              100,
      activityScore:
          (double.tryParse(json['activity_score']?.toString() ?? '') ?? 0.0) /
              100,
    );
  }
}

class DashboardPendingSubmission {
  const DashboardPendingSubmission({
    required this.id,
    required this.typeName,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  final int id;
  final String typeName;
  final String status;
  final String startDate;
  final String endDate;

  factory DashboardPendingSubmission.fromJson(Map<String, dynamic> json) {
    final typeMap = json['submission_type'] as Map<String, dynamic>? ?? {};
    final dateRange = json['date_range'] as Map<String, dynamic>? ?? {};
    return DashboardPendingSubmission(
      id: json['id'] as int,
      typeName: typeMap['name'] as String? ?? '',
      status: json['status'] as String? ?? '',
      startDate: dateRange['start_date'] as String? ?? '',
      endDate: dateRange['end_date'] as String? ?? '',
    );
  }
}

class DashboardInstitutionInfo {
  const DashboardInstitutionInfo({
    required this.id,
    required this.name,
    required this.locations,
  });

  final int id;
  final String name;
  final List<RequiredLocation> locations;

  factory DashboardInstitutionInfo.fromJson(Map<String, dynamic> json) {
    return DashboardInstitutionInfo(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      locations: (json['locations'] as List<dynamic>? ?? [])
          .map((e) => RequiredLocation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
