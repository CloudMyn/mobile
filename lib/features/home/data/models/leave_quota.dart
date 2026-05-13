class LeaveUsage {
  final String type;
  final int days;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // 'approved' | 'pending' | 'rejected'

  const LeaveUsage({
    required this.type,
    required this.days,
    required this.startDate,
    required this.endDate,
    required this.status,
  });
}

class LeaveQuota {
  final int yearlyQuota;           // kuota resmi tahun berjalan
  final int usedThisYear;          // sudah terpakai tahun ini
  final int prevYearQuota;         // total kuota tahun lalu
  final int prevYearRemaining;     // sisa dari tahun lalu yang masih berlaku
  final String year;
  final List<LeaveUsage> recentUsages;

  const LeaveQuota({
    required this.yearlyQuota,
    required this.usedThisYear,
    required this.prevYearQuota,
    required this.prevYearRemaining,
    required this.year,
    this.recentUsages = const [],
  });

  int get totalAvailable => yearlyQuota + prevYearRemaining;
  int get remaining => totalAvailable - usedThisYear;
  double get usedPercentage =>
      totalAvailable > 0 ? (usedThisYear / totalAvailable).clamp(0.0, 1.0) : 0;
}
