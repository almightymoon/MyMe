import '../../../../core/domain/value_objects/money_minor.dart';
import '../../../../core/domain/value_objects/year_month.dart';
import 'finance_budget.dart';
import 'finance_category_breakdown.dart';
import 'finance_enums.dart';

class FinancePeriodReport {
  const FinancePeriodReport({
    required this.period,
    required this.periodStart,
    required this.periodEndExclusive,
    required this.currencyCode,
    required this.incomeMinor,
    required this.expenseMinor,
    required this.transactionCount,
    required this.averageDailyExpenseMinor,
    required this.topExpenseCategories,
    required this.budgetProgress,
    this.previousIncomeMinor,
    this.previousExpenseMinor,
    this.deterministicSummary,
  });

  final FinancePeriod period;
  final DateTime periodStart;
  final DateTime periodEndExclusive;
  final String currencyCode;
  final MoneyMinor incomeMinor;
  final MoneyMinor expenseMinor;
  final int transactionCount;
  final MoneyMinor averageDailyExpenseMinor;
  final List<FinanceCategoryBreakdown> topExpenseCategories;
  final List<FinanceBudgetProgress> budgetProgress;
  final MoneyMinor? previousIncomeMinor;
  final MoneyMinor? previousExpenseMinor;

  /// Non-advice factual line, e.g. largest category.
  final String? deterministicSummary;

  /// Signed (income − expense). May be negative.
  BigInt get netCashFlowMinor => incomeMinor.value - expenseMinor.value;
}

class FinanceTrendPoint {
  const FinanceTrendPoint({
    required this.month,
    required this.incomeMinor,
    required this.expenseMinor,
  });

  final YearMonth month;
  final MoneyMinor incomeMinor;
  final MoneyMinor expenseMinor;

  BigInt get netMinor => incomeMinor.value - expenseMinor.value;
}
