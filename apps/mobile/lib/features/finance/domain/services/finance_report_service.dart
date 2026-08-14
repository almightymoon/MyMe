import '../../../../core/domain/services/money_format.dart';
import '../../../../core/domain/value_objects/money_minor.dart';
import '../../../../core/domain/value_objects/year_month.dart';
import '../entities/finance_budget.dart';
import '../entities/finance_category.dart';
import '../entities/finance_enums.dart';
import '../entities/finance_period_report.dart';
import '../entities/finance_transaction.dart';
import 'finance_summary_service.dart';

/// Pure derived Finance reports — never persisted as source of truth.
class FinanceReportService {
  const FinanceReportService({
    this.summaryService = const FinanceSummaryService(),
  });

  final FinanceSummaryService summaryService;

  FinancePeriodReport build({
    required List<FinanceTransaction> transactions,
    required List<FinanceCategory> categories,
    required List<FinanceBudget> budgets,
    required FinancePeriod period,
    required String currencyCode,
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final summary = summaryService.summarize(
      transactions: transactions,
      categories: categories,
      period: period,
      currencyCode: currencyCode,
      asOf: now,
    );

    final bounds = summaryService.periodBounds(period, now);
    final days = _inclusiveDays(bounds.start, bounds.end, now);
    final avgDaily = days <= 0
        ? MoneyMinor.zero
        : MoneyMinor.fromBigInt(
            summary.periodExpenseMinor.value ~/ BigInt.from(days),
          );

    final month = YearMonth.fromDateTime(now);
    final relevantMonth = switch (period) {
      FinancePeriod.thisMonth => month,
      FinancePeriod.lastMonth => month.previousMonth,
      FinancePeriod.thisYear || FinancePeriod.allTime => month,
    };
    final monthBudgets = budgets
        .where((b) => !b.isArchived && b.month == relevantMonth)
        .toList(growable: false);
    final progress = <FinanceBudgetProgress>[
      for (final budget in monthBudgets)
        FinanceBudgetProgress(
          budget: budget,
          spentMinor: _spentForBudget(
            budget: budget,
            transactions: transactions,
            currencyCode: currencyCode,
          ),
        ),
    ];

    MoneyMinor? previousIncome;
    MoneyMinor? previousExpense;
    if (period == FinancePeriod.thisMonth ||
        period == FinancePeriod.lastMonth) {
      final previousPeriod = period == FinancePeriod.thisMonth
          ? FinancePeriod.lastMonth
          : FinancePeriod.thisMonth;
      final previous = summaryService.summarize(
        transactions: transactions,
        categories: categories,
        period: previousPeriod,
        currencyCode: currencyCode,
        asOf: now,
      );
      previousIncome = previous.periodIncomeMinor;
      previousExpense = previous.periodExpenseMinor;
    }

    final top = summary.categoryBreakdown.take(5).toList(growable: false);
    final currency = currencyCode.trim().toUpperCase();
    String? line;
    if (top.isNotEmpty) {
      line =
          '${top.first.categoryName} was your largest expense category '
          'this period.';
    }
    if (previousExpense != null) {
      final delta = summary.periodExpenseMinor.value - previousExpense.value;
      final abs = delta.abs();
      final formatted = MoneyFormat.formatMinor(
        MoneyMinor.fromBigInt(abs),
        currency,
      );
      if (delta < BigInt.zero) {
        line = '${line ?? ''} You spent $formatted less than last period.'
            .trim();
      } else if (delta > BigInt.zero) {
        line = '${line ?? ''} You spent $formatted more than last period.'
            .trim();
      }
    }
    final overall = progress.where((p) => p.budget.isOverall).firstOrNull;
    if (overall != null && !overall.isOverspent) {
      final remaining = MoneyFormat.formatMinor(
        MoneyMinor.fromBigInt(overall.remainingSigned),
        currency,
      );
      line =
          '${line ?? ''} You have $remaining remaining in your monthly budget.'
              .trim();
    }

    return FinancePeriodReport(
      period: period,
      periodStart: summary.periodStart ?? DateTime(now.year, 1, 1),
      periodEndExclusive: summary.periodEnd ?? DateTime(now.year + 1, 1, 1),
      currencyCode: currency,
      incomeMinor: summary.periodIncomeMinor,
      expenseMinor: summary.periodExpenseMinor,
      transactionCount: summary.transactionCount,
      averageDailyExpenseMinor: avgDaily,
      topExpenseCategories: top,
      budgetProgress: progress,
      previousIncomeMinor: previousIncome,
      previousExpenseMinor: previousExpense,
      deterministicSummary: line,
    );
  }

  MoneyMinor spentForBudget({
    required FinanceBudget budget,
    required List<FinanceTransaction> transactions,
    required String currencyCode,
  }) => _spentForBudget(
    budget: budget,
    transactions: transactions,
    currencyCode: currencyCode,
  );

  MoneyMinor _spentForBudget({
    required FinanceBudget budget,
    required List<FinanceTransaction> transactions,
    required String currencyCode,
  }) {
    final currency = currencyCode.trim().toUpperCase();
    final start = budget.month.startLocal;
    final end = budget.month.endExclusiveLocal;
    var spent = BigInt.zero;
    for (final tx in transactions) {
      if (tx.type != TransactionType.expense) continue;
      if (tx.currencyCode.toUpperCase() != currency) continue;
      final occurred = tx.occurredAt.toLocal();
      if (occurred.isBefore(start) || !occurred.isBefore(end)) continue;
      if (!budget.isOverall && tx.categoryId != budget.categoryId) continue;
      spent += tx.amountMinor.value;
    }
    return MoneyMinor.fromBigInt(spent);
  }

  int _inclusiveDays(DateTime? start, DateTime? end, DateTime now) {
    final s = start ?? DateTime(now.year, now.month, now.day);
    final e =
        end ??
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    final delta = e.difference(s).inDays;
    return delta <= 0 ? 1 : delta;
  }
}
