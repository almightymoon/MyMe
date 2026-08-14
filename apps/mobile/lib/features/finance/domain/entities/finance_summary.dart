import '../../../../core/domain/value_objects/money_minor.dart';
import 'finance_category_breakdown.dart';
import 'finance_enums.dart';

/// Derived finance totals for a selected [FinancePeriod].
///
/// [currentBalanceMinor] is signed (income − expense, all-time) and may be
/// negative. Period income / expense / spent-today amounts are non-negative
/// [MoneyMinor] values. Presentation formats labels — this entity never
/// stores display strings.
class FinanceSummary {
  const FinanceSummary({
    required this.currencyCode,
    required this.currentBalanceMinor,
    required this.periodIncomeMinor,
    required this.periodExpenseMinor,
    required this.spentTodayMinor,
    required this.transactionCount,
    required this.categoryBreakdown,
    required this.selectedPeriod,
    this.periodStart,
    this.periodEnd,
  });

  final String currencyCode;

  /// Signed net balance in minor units (all-time income − all-time expenses).
  final BigInt currentBalanceMinor;
  final MoneyMinor periodIncomeMinor;
  final MoneyMinor periodExpenseMinor;
  final MoneyMinor spentTodayMinor;
  final int transactionCount;
  final List<FinanceCategoryBreakdown> categoryBreakdown;
  final FinancePeriod selectedPeriod;
  final DateTime? periodStart;
  final DateTime? periodEnd;

  static FinanceSummary empty({
    String currencyCode = 'PKR',
    FinancePeriod period = FinancePeriod.thisMonth,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return FinanceSummary(
      currencyCode: currencyCode,
      currentBalanceMinor: BigInt.zero,
      periodIncomeMinor: MoneyMinor.zero,
      periodExpenseMinor: MoneyMinor.zero,
      spentTodayMinor: MoneyMinor.zero,
      transactionCount: 0,
      categoryBreakdown: const [],
      selectedPeriod: period,
      periodStart: periodStart,
      periodEnd: periodEnd,
    );
  }

  bool get hasTransactions => transactionCount > 0;
}
