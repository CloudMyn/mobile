import 'package:intl/intl.dart';

/// Model representasi data respon GET /api/v1/mobile/tpp/my
class TppDetailModel {
  const TppDetailModel({
    required this.id,
    required this.user,
    required this.period,
    required this.calculation,
    required this.ekp,
    required this.dailyRecords,
  });

  final int id;
  final TppUserInfo user;
  final TppPeriodInfo period;
  final TppCalculationInfo calculation;
  final TppEkpInfo ekp;
  final List<TppDailyRecordModel> dailyRecords;

  factory TppDetailModel.fromJson(Map<String, dynamic> json) {
    return TppDetailModel(
      id: json['id'] as int? ?? 0,
      user: TppUserInfo.fromJson(json['user'] as Map<String, dynamic>? ?? {}),
      period: TppPeriodInfo.fromJson(json['period'] as Map<String, dynamic>? ?? {}),
      calculation: TppCalculationInfo.fromJson(
          json['calculation'] as Map<String, dynamic>? ?? {}),
      ekp: TppEkpInfo.fromJson(json['ekp'] as Map<String, dynamic>? ?? {}),
      dailyRecords: (json['daily_records'] as List<dynamic>? ?? [])
          .map((e) => TppDailyRecordModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TppUserInfo {
  const TppUserInfo({
    this.id,
    required this.name,
    required this.fullName,
    required this.nip,
    this.positionName,
    this.institutionName,
    this.departmentName,
  });

  final int? id;
  final String name;
  final String fullName;
  final String nip;
  final String? positionName;
  final String? institutionName;
  final String? departmentName;

  String get displayName => fullName.isNotEmpty ? fullName : name;

  factory TppUserInfo.fromJson(Map<String, dynamic> json) {
    return TppUserInfo(
      id: json['id'] as int?,
      name: json['name'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      nip: json['nip'] as String? ?? '-',
      positionName: json['position_name'] as String?,
      institutionName: json['institution_name'] as String?,
      departmentName: json['department_name'] as String?,
    );
  }
}

class TppPeriodInfo {
  const TppPeriodInfo({
    required this.month,
    required this.year,
    required this.periodDate,
    required this.periodLabel,
  });

  final int month;
  final int year;
  final String periodDate;
  final String periodLabel;

  factory TppPeriodInfo.fromJson(Map<String, dynamic> json) {
    return TppPeriodInfo(
      month: json['month'] as int? ?? DateTime.now().month,
      year: json['year'] as int? ?? DateTime.now().year,
      periodDate: json['period_date'] as String? ?? '',
      periodLabel: json['period_label'] as String? ?? '',
    );
  }
}

class TppCalculationInfo {
  const TppCalculationInfo({
    required this.paguJabatan,
    required this.absentDeductionPct,
    required this.lateDeductionPct,
    required this.earlyLeaveDeductionPct,
    required this.cutiDeductionPct,
    required this.attendanceDeductionPct,
    required this.attendanceDeductionRp,
    required this.attendanceNetPagu,
    required this.skpScorePct,
    required this.skpAmountRp,
    required this.taxRatePct,
    required this.taxDeductionRp,
    required this.finalTakeHomePayRp,
    required this.disciplineScore,
    required this.activityScore,
    required this.weightedScore,
    this.disciplinePortionPagu,
    this.disciplineDeductionRp,
    this.disciplineNetRp,
    this.activityPortionPagu,
    this.activityDeductionPct,
    this.activityDeductionRp,
    this.activityNetRp,
    this.approvedActivityDays,
    this.totalWorkDays,
    this.totalTppGrossRp,
  });

  final int paguJabatan;
  final double absentDeductionPct;
  final double lateDeductionPct;
  final double earlyLeaveDeductionPct;
  final double cutiDeductionPct;
  final double attendanceDeductionPct;
  final int attendanceDeductionRp;
  final int attendanceNetPagu;
  final double skpScorePct;
  final int skpAmountRp;
  final double taxRatePct;
  final int taxDeductionRp;
  final int finalTakeHomePayRp;
  final double disciplineScore;
  final double activityScore;
  final double weightedScore;

  final int? disciplinePortionPagu;
  final int? disciplineDeductionRp;
  final int? disciplineNetRp;
  final int? activityPortionPagu;
  final double? activityDeductionPct;
  final int? activityDeductionRp;
  final int? activityNetRp;
  final int? approvedActivityDays;
  final int? totalWorkDays;
  final int? totalTppGrossRp;

  int get dispPagu => disciplinePortionPagu ?? (paguJabatan * 0.4).round();
  int get dispNet => disciplineNetRp ?? attendanceNetPagu;
  int get dispDedRp => disciplineDeductionRp ?? attendanceDeductionRp;
  int get actPagu => activityPortionPagu ?? (paguJabatan * 0.6).round();
  int get actNet => activityNetRp ?? (actPagu * (activityScore / 100)).round();
  int get actDedRp => activityDeductionRp ?? (actPagu - actNet);
  int get grossRp => totalTppGrossRp ?? (dispNet + actNet);
  int get approvedDays => approvedActivityDays ?? 0;
  int get workDays => totalWorkDays ?? 0;

  static String formatRupiah(num val, {bool withDecimals = false}) {
    final format = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: withDecimals ? 2 : 0,
    );
    return format.format(val);
  }

  static String formatNumber(num val) {
    return NumberFormat.decimalPattern('id_ID').format(val);
  }

  factory TppCalculationInfo.fromJson(Map<String, dynamic> json) {
    return TppCalculationInfo(
      paguJabatan: (json['pagu_jabatan'] as num?)?.toInt() ?? 0,
      absentDeductionPct: (json['absent_deduction_pct'] as num?)?.toDouble() ?? 0.0,
      lateDeductionPct: (json['late_deduction_pct'] as num?)?.toDouble() ?? 0.0,
      earlyLeaveDeductionPct: (json['early_leave_deduction_pct'] as num?)?.toDouble() ?? 0.0,
      cutiDeductionPct: (json['cuti_deduction_pct'] as num?)?.toDouble() ?? 0.0,
      attendanceDeductionPct: (json['attendance_deduction_pct'] as num?)?.toDouble() ?? 0.0,
      attendanceDeductionRp: (json['attendance_deduction_rp'] as num?)?.toInt() ?? 0,
      attendanceNetPagu: (json['attendance_net_pagu'] as num?)?.toInt() ?? 0,
      skpScorePct: (json['skp_score_pct'] as num?)?.toDouble() ?? 0.0,
      skpAmountRp: (json['skp_amount_rp'] as num?)?.toInt() ?? 0,
      taxRatePct: (json['tax_rate_pct'] as num?)?.toDouble() ?? 0.0,
      taxDeductionRp: (json['tax_deduction_rp'] as num?)?.toInt() ?? 0,
      finalTakeHomePayRp: (json['final_take_home_pay_rp'] as num?)?.toInt() ?? 0,
      disciplineScore: (json['discipline_score'] as num?)?.toDouble() ?? 0.0,
      activityScore: (json['activity_score'] as num?)?.toDouble() ?? 0.0,
      weightedScore: (json['weighted_score'] as num?)?.toDouble() ?? 0.0,
      disciplinePortionPagu: (json['discipline_portion_pagu'] as num?)?.toInt(),
      disciplineDeductionRp: (json['discipline_deduction_rp'] as num?)?.toInt(),
      disciplineNetRp: (json['discipline_net_rp'] as num?)?.toInt(),
      activityPortionPagu: (json['activity_portion_pagu'] as num?)?.toInt(),
      activityDeductionPct: (json['activity_deduction_pct'] as num?)?.toDouble(),
      activityDeductionRp: (json['activity_deduction_rp'] as num?)?.toInt(),
      activityNetRp: (json['activity_net_rp'] as num?)?.toInt(),
      approvedActivityDays: (json['approved_activity_days'] as num?)?.toInt(),
      totalWorkDays: (json['total_work_days'] as num?)?.toInt(),
      totalTppGrossRp: (json['total_tpp_gross_rp'] as num?)?.toInt(),
    );
  }
}

class TppEkpInfo {
  const TppEkpInfo({
    this.id,
    required this.status,
    this.predikat,
    this.percentage,
    this.fileName,
  });

  final int? id;
  final String status; // 'disetujui' | 'pending' | 'ditolak' | 'belum_upload'
  final String? predikat;
  final double? percentage;
  final String? fileName;

  bool get isApproved => status.toLowerCase() == 'disetujui';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'ditolak';

  /// Jika belum ada penilaian EKP / belum disetujui, kembalikan 'Belum Ada Penilaian'
  String get displayPredikat {
    if (predikat != null && predikat!.trim().isNotEmpty) {
      return predikat!;
    }
    return 'Belum Ada Penilaian';
  }

  String get statusDescription {
    switch (status.toLowerCase()) {
      case 'disetujui':
        final pred = predikat != null ? ' • Predikat: $predikat' : '';
        final pct = percentage != null ? ' • Nilai TPP: ${percentage!.toStringAsFixed(0)}%' : '';
        return 'Status: Disetujui$pred$pct';
      case 'pending':
        return 'Status: Menunggu Verifikasi Atasan (Skor EKP sementara: 0%)';
      case 'ditolak':
        return 'Status: Ditolak (Skor EKP: 0%)';
      default:
        return 'Status: Belum Ada Dokumen EKP yang Disetujui (Skor EKP: 0%)';
    }
  }

  factory TppEkpInfo.fromJson(Map<String, dynamic> json) {
    return TppEkpInfo(
      id: json['id'] as int?,
      status: json['status'] as String? ?? 'belum_upload',
      predikat: json['predikat'] as String?,
      percentage: (json['percentage'] as num?)?.toDouble(),
      fileName: json['file_name'] as String?,
    );
  }
}

class TppDailyRecordModel {
  const TppDailyRecordModel({
    required this.id,
    required this.recordDate,
    required this.isWorkday,
    this.attendanceStatus,
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

  factory TppDailyRecordModel.fromJson(Map<String, dynamic> json) {
    return TppDailyRecordModel(
      id: json['id'] as int? ?? 0,
      recordDate: json['record_date'] as String? ?? '',
      isWorkday: json['is_workday'] as bool? ?? true,
      attendanceStatus: json['attendance_status'] as String?,
      totalLateMinutes: json['total_late_minutes'] as int? ?? 0,
      totalEarlyLeaveMinutes: json['total_early_leave_minutes'] as int? ?? 0,
      disciplineDeductionPct:
          (json['discipline_deduction_pct'] as num?)?.toDouble() ?? 0.0,
      hasApprovedActivity: json['has_approved_activity'] as bool? ?? false,
      activityDeductionPct:
          (json['activity_deduction_pct'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
