class MonthlyActivityStats {
  final int totalActivities;
  final Map<String, int> activitiesByCategory;
  final int target;
  final int month;
  final int year;

  const MonthlyActivityStats({
    required this.totalActivities,
    required this.activitiesByCategory,
    required this.target,
    required this.month,
    required this.year,
  });

  double get progressPercent =>
      target > 0 ? (totalActivities / target).clamp(0.0, 1.0) : 0.0;

  String get formattedPeriod {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${months[month - 1]} $year';
  }
}
