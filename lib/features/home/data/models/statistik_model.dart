/// Model untuk response GET /mobile/statistik
class StatistikModel {
  const StatistikModel({
    required this.period,
    this.tpp,
    required this.attendance,
    required this.leaveBalances,
    required this.recentSubmissions,
  });

  final StatistikPeriod period;
  final StatistikTpp? tpp;
  final StatistikAttendance attendance;
  final List<StatistikLeaveBalance> leaveBalances;
  final List<StatistikRecentSubmission> recentSubmissions;

  factory StatistikModel.fromJson(Map<String, dynamic> json) {
    return StatistikModel(
      period: StatistikPeriod.fromJson(json['period'] as Map<String, dynamic>),
      tpp: json['tpp'] != null
          ? StatistikTpp.fromJson(json['tpp'] as Map<String, dynamic>)
          : null,
      attendance: StatistikAttendance.fromJson(
          json['attendance'] as Map<String, dynamic>),
      leaveBalances: (json['leave_balances'] as List<dynamic>? ?? [])
          .map((e) =>
              StatistikLeaveBalance.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentSubmissions: (json['recent_submissions'] as List<dynamic>? ?? [])
          .map((e) =>
              StatistikRecentSubmission.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class StatistikPeriod {
  const StatistikPeriod({
    required this.month,
    required this.year,
    required this.label,
  });

  final int month;
  final int year;
  final String label; // "Mei 2026"

  factory StatistikPeriod.fromJson(Map<String, dynamic> json) {
    return StatistikPeriod(
      month: json['month'] as int,
      year: json['year'] as int,
      label: json['label'] as String? ?? '',
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class StatistikTpp {
  const StatistikTpp({
    required this.id,
    required this.periodDate,
    required this.amountBeforeDeduction,
    required this.amountAfterDeduction,
    required this.deductionAmount,
    required this.disciplineScore,
    required this.activityScore,
    required this.dailyRecords,
  });

  final int id;
  final String periodDate; // "2026-05"
  final int amountBeforeDeduction;
  final int amountAfterDeduction;
  final int deductionAmount;
  final double disciplineScore; // 0.0–1.0
  final double activityScore;   // 0.0–1.0
  final List<StatistikTppDailyRecord> dailyRecords;

  factory StatistikTpp.fromJson(Map<String, dynamic> json) {
    return StatistikTpp(
      id: json['id'] as int,
      periodDate: json['period_date'] as String? ?? '',
      amountBeforeDeduction:
          (json['amount_before_deduction'] as num?)?.toInt() ?? 0,
      amountAfterDeduction:
          (json['amount_after_deduction'] as num?)?.toInt() ?? 0,
      deductionAmount: (json['deduction_amount'] as num?)?.toInt() ?? 0,
      disciplineScore:
          ((json['discipline_score'] as num?)?.toDouble() ?? 0) / 100,
      activityScore: ((json['activity_score'] as num?)?.toDouble() ?? 0) / 100,
      dailyRecords: (json['daily_records'] as List<dynamic>? ?? [])
          .map((e) =>
              StatistikTppDailyRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class StatistikTppDailyRecord {
  const StatistikTppDailyRecord({
    required this.id,
    required this.recordDate,
    required this.isWorkday,
    required this.attendanceStatus,
    required this.totalLateMinutes,
    required this.totalEarlyLeaveMinutes,
    required this.disciplineDeductionPct,
    required this.hasApprovedActivity,
    required this.activityDeductionPct,
  });

  final int id;
  final String recordDate;
  final bool isWorkday;
  final String? attendanceStatus;
  final int totalLateMinutes;
  final int totalEarlyLeaveMinutes;
  final double disciplineDeductionPct;
  final bool hasApprovedActivity;
  final double activityDeductionPct;

  factory StatistikTppDailyRecord.fromJson(Map<String, dynamic> json) {
    return StatistikTppDailyRecord(
      id: json['id'] as int? ?? 0,
      recordDate: json['record_date'] as String? ?? '',
      isWorkday: json['is_workday'] as bool? ?? true,
      attendanceStatus: json['attendance_status'] as String?,
      totalLateMinutes: json['total_late_minutes'] as int? ?? 0,
      totalEarlyLeaveMinutes: json['total_early_leave_minutes'] as int? ?? 0,
      disciplineDeductionPct: (json['discipline_deduction_pct'] as num?)?.toDouble() ?? 0.0,
      hasApprovedActivity: json['has_approved_activity'] as bool? ?? false,
      activityDeductionPct: (json['activity_deduction_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class StatistikAttendance {
  const StatistikAttendance({
    required this.totalWorkdays,
    required this.present,
    required this.absent,
    required this.leave,
    required this.sick,
    required this.permit,
    required this.totalLateMinutes,
    required this.totalEarlyLeaveMinutes,
    required this.totalWorkMinutes,
  });

  final int totalWorkdays;
  final int present;
  final int absent;
  final int leave;
  final int sick;
  final int permit;
  final int totalLateMinutes;
  final int totalEarlyLeaveMinutes;
  final int totalWorkMinutes;

  /// Izin = izin + sakit (ditampilkan sebagai satu kategori di UI)
  int get permissionTotal => permit + sick;

  /// Hari yang sudah terakumulasi (hadir + izin + cuti + alpha)
  int get accounted => present + permissionTotal + leave + absent;

  /// Persentase kehadiran (0–100)
  double get percentage =>
      totalWorkdays > 0 ? (accounted / totalWorkdays) * 100 : 0;

  /// Total jam kerja dari menit
  double get totalWorkHours => totalWorkMinutes / 60;

  factory StatistikAttendance.fromJson(Map<String, dynamic> json) {
    return StatistikAttendance(
      totalWorkdays: json['total_workdays'] as int? ?? 0,
      present: json['present'] as int? ?? 0,
      absent: json['absent'] as int? ?? 0,
      leave: json['leave'] as int? ?? 0,
      sick: json['sick'] as int? ?? 0,
      permit: json['permit'] as int? ?? 0,
      totalLateMinutes: json['total_late_minutes'] as int? ?? 0,
      totalEarlyLeaveMinutes: json['total_early_leave_minutes'] as int? ?? 0,
      totalWorkMinutes: json['total_work_minutes'] as int? ?? 0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class StatistikLeaveBalance {
  const StatistikLeaveBalance({
    required this.id,
    required this.leaveTypeName,
    required this.leaveTypeCode,
    required this.balanceYear,
    required this.currentYearQuota,
    required this.carryForwardBalance,
    required this.additionalQuota,
    required this.usedBalance,
    required this.remainingBalance,
  });

  final int id;
  final String leaveTypeName;
  final String leaveTypeCode;
  final int balanceYear;
  final double currentYearQuota;
  final double carryForwardBalance;
  final double additionalQuota;
  final double usedBalance;
  final double remainingBalance;

  double get totalAvailable => currentYearQuota + carryForwardBalance + additionalQuota;

  factory StatistikLeaveBalance.fromJson(Map<String, dynamic> json) {
    final type = json['leave_type'] as Map<String, dynamic>? ?? {};
    return StatistikLeaveBalance(
      id: json['id'] as int,
      leaveTypeName: type['name'] as String? ?? '',
      leaveTypeCode: type['code'] as String? ?? '',
      balanceYear: json['balance_year'] as int? ?? 0,
      currentYearQuota:
          (json['current_year_quota'] as num?)?.toDouble() ?? 0,
      carryForwardBalance:
          (json['carry_forward_balance'] as num?)?.toDouble() ?? 0,
      additionalQuota: (json['additional_quota'] as num?)?.toDouble() ?? 0,
      usedBalance: (json['used_balance'] as num?)?.toDouble() ?? 0,
      remainingBalance: (json['remaining_balance'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class StatistikRecentSubmission {
  const StatistikRecentSubmission({
    required this.id,
    required this.typeName,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.status,
  });

  final int id;
  final String typeName;
  final String startDate; // "2026-03-10"
  final String endDate;
  final double totalDays;
  final String status;

  factory StatistikRecentSubmission.fromJson(Map<String, dynamic> json) {
    return StatistikRecentSubmission(
      id: json['id'] as int,
      typeName: json['type_name'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      totalDays: (json['total_days'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? '',
    );
  }
}
