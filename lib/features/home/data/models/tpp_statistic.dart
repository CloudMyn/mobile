import 'dashboard_model.dart';

class TppStatistic {
  final double totalAmount;
  final double totalDeduction;
  final double netResult;
  final String period;

  const TppStatistic({
    required this.totalAmount,
    required this.totalDeduction,
    required this.netResult,
    required this.period,
  });

  factory TppStatistic.fromDashboard(DashboardTpp tpp) {
    return TppStatistic(
      totalAmount: tpp.amountBeforeDeduction,
      totalDeduction: tpp.deductionAmount,
      netResult: tpp.amountAfterDeduction,
      period: tpp.periodDate,
    );
  }
}
