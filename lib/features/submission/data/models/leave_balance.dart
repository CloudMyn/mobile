class LeaveBalance {
  final int id;
  final int leaveTypeId;
  final String leaveTypeName;
  final int balanceYear;
  final double totalQuota;
  final double usedBalance;
  final double remainingBalance;
  final String? notes;

  const LeaveBalance({
    required this.id,
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.balanceYear,
    required this.totalQuota,
    required this.usedBalance,
    required this.remainingBalance,
    this.notes,
  });

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    final leaveType = json['leave_type'] as Map<String, dynamic>? ?? {};
    return LeaveBalance(
      id: json['id'] as int,
      leaveTypeId: leaveType['id'] as int? ?? 0,
      leaveTypeName: leaveType['name'] as String? ?? '',
      balanceYear: json['balance_year'] as int? ?? DateTime.now().year,
      totalQuota: (json['total_quota'] as num?)?.toDouble() ?? 0,
      usedBalance: (json['used_balance'] as num?)?.toDouble() ?? 0,
      remainingBalance: (json['remaining_balance'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
    );
  }

  String get remainingLabel {
    final days = remainingBalance.truncate();
    return '$days hari';
  }
}
