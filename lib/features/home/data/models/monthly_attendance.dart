class MonthlyAttendance {
  final int present;
  final int permission;
  final int leave;
  final int absent;
  final int total;
  final String month;

  const MonthlyAttendance({
    required this.present,
    required this.permission,
    required this.leave,
    required this.absent,
    required this.total,
    required this.month,
  });

  int get accounted => present + permission + leave + absent;
  double get percentage =>
      total > 0 ? (accounted / total) * 100 : 0;
}
