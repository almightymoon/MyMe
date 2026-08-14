import '../../../../core/domain/value_objects/money_minor.dart';
import '../entities/finance_category.dart';
import '../entities/finance_category_breakdown.dart';
import '../entities/finance_enums.dart';
import '../entities/finance_summary.dart';
import '../entities/finance_transaction.dart';

/// Pure, deterministic finance aggregation (no I/O).
class FinanceSummaryService {
  const FinanceSummaryService();

  FinanceSummary summarize({
    required List<FinanceTransaction> transactions,
    required List<FinanceCategory> categories,
    required FinancePeriod period,
    required String currencyCode,
    DateTime? asOf,
  }) {
    final now = asOf ?? DateTime.now();
    final localNow = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
    );
    final bounds = periodBounds(period, localNow);
    final currency = currencyCode.trim().toUpperCase();

    var allIncome = BigInt.zero;
    var allExpense = BigInt.zero;
    var periodIncome = BigInt.zero;
    var periodExpense = BigInt.zero;
    var spentToday = BigInt.zero;
    var periodCount = 0;
    final expenseByCategory = <String, BigInt>{};

    final categoryNames = <String, String>{
      for (final c in categories) c.id: c.name,
    };

    for (final tx in transactions) {
      if (tx.currencyCode.toUpperCase() != currency) {
        // MVP: ignore other currencies rather than mixing balances.
        continue;
      }
      final amount = tx.amountMinor.value;
      if (tx.type == TransactionType.income) {
        allIncome += amount;
      } else {
        allExpense += amount;
      }

      final occurred = tx.occurredAt.toLocal();
      if (_inBounds(occurred, bounds.start, bounds.end)) {
        periodCount += 1;
        if (tx.type == TransactionType.income) {
          periodIncome += amount;
        } else {
          periodExpense += amount;
          expenseByCategory.update(
            tx.categoryId,
            (v) => v + amount,
            ifAbsent: () => amount,
          );
        }
      }

      if (tx.type == TransactionType.expense &&
          _isSameLocalDay(occurred, localNow)) {
        spentToday += amount;
      }
    }

    final breakdown = <FinanceCategoryBreakdown>[];
    final sortedEntries = expenseByCategory.entries.toList()
      ..sort((a, b) {
        final cmp = b.value.compareTo(a.value);
        if (cmp != 0) return cmp;
        return a.key.compareTo(b.key);
      });

    for (final entry in sortedEntries) {
      final basisPoints = periodExpense == BigInt.zero
          ? 0
          : ((entry.value * BigInt.from(10000)) ~/ periodExpense).toInt();
      breakdown.add(
        FinanceCategoryBreakdown(
          categoryId: entry.key,
          categoryName: categoryNames[entry.key] ?? 'Unknown',
          amountMinor: MoneyMinor.fromBigInt(entry.value),
          percentageBasisPoints: basisPoints,
        ),
      );
    }

    return FinanceSummary(
      currencyCode: currency,
      currentBalanceMinor: allIncome - allExpense,
      periodIncomeMinor: MoneyMinor.fromBigInt(periodIncome),
      periodExpenseMinor: MoneyMinor.fromBigInt(periodExpense),
      spentTodayMinor: MoneyMinor.fromBigInt(spentToday),
      transactionCount: periodCount,
      categoryBreakdown: List.unmodifiable(breakdown),
      selectedPeriod: period,
      periodStart: bounds.start,
      periodEnd: bounds.end,
    );
  }

  /// Inclusive local start, exclusive local end (null end = unbounded).
  ({DateTime? start, DateTime? end}) periodBounds(
    FinancePeriod period,
    DateTime asOfLocal,
  ) {
    final y = asOfLocal.year;
    final m = asOfLocal.month;
    switch (period) {
      case FinancePeriod.thisMonth:
        return (start: DateTime(y, m, 1), end: DateTime(y, m + 1, 1));
      case FinancePeriod.lastMonth:
        final start = DateTime(y, m - 1, 1);
        return (start: start, end: DateTime(y, m, 1));
      case FinancePeriod.thisYear:
        return (start: DateTime(y, 1, 1), end: DateTime(y + 1, 1, 1));
      case FinancePeriod.allTime:
        return (start: null, end: null);
    }
  }

  bool _inBounds(DateTime occurred, DateTime? start, DateTime? end) {
    if (start != null && occurred.isBefore(start)) return false;
    if (end != null && !occurred.isBefore(end)) return false;
    return true;
  }

  bool _isSameLocalDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
