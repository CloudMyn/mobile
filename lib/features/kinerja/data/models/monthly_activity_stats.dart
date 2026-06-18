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

  factory MonthlyActivityStats.fromJson(Map<String, dynamic> json) {
    final categoryMap = <String, int>{};
    if (json['activities_by_category'] != null) {
      final rawMap = json['activities_by_category'] as Map<String, dynamic>;
      rawMap.forEach((key, value) {
        categoryMap[key] = (value as num).toInt();
      });
    }

    return MonthlyActivityStats(
      totalActivities: (json['total_activities'] as num?)?.toInt() ?? 0,
      activitiesByCategory: categoryMap,
      target: (json['target'] as num?)?.toInt() ?? 20,
      month: (json['month'] as num?)?.toInt() ?? DateTime.now().month,
      year: (json['year'] as num?)?.toInt() ?? DateTime.now().year,
    );
  }

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
