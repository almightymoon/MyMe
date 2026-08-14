import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/value_objects/money_minor.dart';
import 'package:memy/core/domain/value_objects/year_month.dart';
import 'package:memy/features/finance/data/seed/finance_seed.dart';
import 'package:memy/features/finance/domain/entities/finance_budget.dart';
import 'package:memy/features/finance/domain/entities/finance_enums.dart';
import 'package:memy/features/finance/domain/entities/finance_transaction.dart';
import 'package:memy/features/finance/domain/services/finance_report_service.dart';

void main() {
  final categories = FinanceSeed.demoCategories(now: DateTime(2026, 8, 10));
  const service = FinanceReportService();
  final month = YearMonth(2026, 8);
  final overall = FinanceBudget(
    id: 'b-overall',
    name: 'August',
    month: month,
    amountMinor: MoneyMinor.fromInt(5000000),
    currencyCode: 'PKR',
    warningThresholdBasisPoints: 8000,
    createdAt: DateTime(2026, 8, 1),
    updatedAt: DateTime(2026, 8, 1),
  );
  final foodBudget = FinanceBudget(
    id: 'b-food',
    name: 'Food',
    categoryId: 'cat_food',
    month: month,
    amountMinor: MoneyMinor.fromInt(3000000),
    currencyCode: 'PKR',
    warningThresholdBasisPoints: 8000,
    createdAt: DateTime(2026, 8, 1),
    updatedAt: DateTime(2026, 8, 1),
  );

  FinanceTransaction expense({
    required String id,
    required int minor,
    required DateTime at,
    String categoryId = 'cat_food',
  }) {
    return FinanceTransaction(
      id: id,
      type: TransactionType.expense,
      amountMinor: MoneyMinor.fromInt(minor),
      currencyCode: 'PKR',
      categoryId: categoryId,
      occurredAt: at,
      paymentMethod: PaymentMethod.cash,
      createdAt: at,
      updatedAt: at,
    );
  }

  test('overall and category budgets derive spent remaining and overspend', () {
    final txs = [
      expense(id: 'a', minor: 2500000, at: DateTime(2026, 8, 10)),
      expense(
        id: 'b',
        minor: 1000000,
        at: DateTime(2026, 8, 11),
        categoryId: 'cat_transport',
      ),
    ];
    final overallProgress = FinanceBudgetProgress(
      budget: overall,
      spentMinor: service.spentForBudget(
        budget: overall,
        transactions: txs,
        currencyCode: 'PKR',
      ),
    );
    expect(overallProgress.spentMinor, MoneyMinor.fromInt(3500000));
    expect(overallProgress.remainingSigned, BigInt.from(1500000));
    expect(overallProgress.isOverspent, isFalse);
    expect(overallProgress.spentBasisPoints, 7000);

    final foodProgress = FinanceBudgetProgress(
      budget: foodBudget,
      spentMinor: service.spentForBudget(
        budget: foodBudget,
        transactions: txs,
        currencyCode: 'PKR',
      ),
    );
    expect(foodProgress.spentMinor, MoneyMinor.fromInt(2500000));

    final over = FinanceBudgetProgress(
      budget: foodBudget,
      spentMinor: MoneyMinor.fromInt(4000000),
    );
    expect(over.isOverspent, isTrue);
    expect(over.remainingSigned.isNegative, isTrue);
    expect(over.isAtOrAboveWarning, isTrue);
  });

  test('reports compare periods and name the largest category', () {
    final txs = [
      expense(id: 'jul', minor: 4000000, at: DateTime(2026, 7, 10)),
      expense(id: 'aug-food', minor: 2500000, at: DateTime(2026, 8, 10)),
      FinanceTransaction(
        id: 'aug-in',
        type: TransactionType.income,
        amountMinor: MoneyMinor.fromInt(10000000),
        currencyCode: 'PKR',
        categoryId: 'cat_salary',
        occurredAt: DateTime(2026, 8, 1),
        paymentMethod: PaymentMethod.bankTransfer,
        createdAt: DateTime(2026, 8, 1),
        updatedAt: DateTime(2026, 8, 1),
      ),
    ];
    final report = service.build(
      transactions: txs,
      categories: categories,
      budgets: [overall],
      period: FinancePeriod.thisMonth,
      currencyCode: 'PKR',
      asOf: DateTime(2026, 8, 11),
    );
    expect(report.expenseMinor, MoneyMinor.fromInt(2500000));
    expect(report.incomeMinor, MoneyMinor.fromInt(10000000));
    expect(report.topExpenseCategories.first.categoryName, 'Food');
    expect(report.previousExpenseMinor, MoneyMinor.fromInt(4000000));
    expect(report.deterministicSummary, contains('Food'));
    expect(report.deterministicSummary, contains('less'));
  });

  test('empty report has zero totals', () {
    final report = service.build(
      transactions: const [],
      categories: categories,
      budgets: const [],
      period: FinancePeriod.allTime,
      currencyCode: 'PKR',
      asOf: DateTime(2026, 8, 11),
    );
    expect(report.transactionCount, 0);
    expect(report.expenseMinor, MoneyMinor.zero);
    expect(report.deterministicSummary, isNull);
  });
}
