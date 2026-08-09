import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/services/money_format.dart';
import 'package:memy/core/domain/value_objects/money_minor.dart';
import 'package:memy/features/finance/domain/entities/finance_category.dart';
import 'package:memy/features/finance/domain/entities/finance_enums.dart';
import 'package:memy/features/finance/domain/entities/finance_transaction.dart';
import 'package:memy/features/finance/domain/services/finance_summary_service.dart';

void main() {
  group('MoneyFormat finance amounts', () {
    test('parses whole-unit and decimal major amounts', () {
      expect(MoneyFormat.parseMajorToMinor('100'), MoneyMinor.fromInt(10000));
      expect(MoneyFormat.parseMajorToMinor('100.5'), MoneyMinor.fromInt(10050));
      expect(
        MoneyFormat.parseMajorToMinor('100.50'),
        MoneyMinor.fromInt(10050),
      );
      expect(
        MoneyFormat.parseMajorToMinor('25,000'),
        MoneyMinor.fromInt(2500000),
      );
      expect(
        MoneyFormat.parseMajorToMinor('150,000,000'),
        MoneyMinor.parse('15000000000'),
      );
      expect(
        MoneyFormat.parseMajorToMinor('150,000,000.00'),
        MoneyMinor.parse('15000000000'),
      );
    });

    test('rejects malformed and excessive fraction digits', () {
      expect(MoneyFormat.parseMajorToMinor(null), isNull);
      expect(MoneyFormat.parseMajorToMinor(''), isNull);
      expect(() => MoneyFormat.parseMajorToMinor('abc'), throwsFormatException);
      expect(
        () => MoneyFormat.parseMajorToMinor('1.234'),
        throwsFormatException,
      );
      expect(() => MoneyFormat.parseMajorToMinor('1e3'), throwsFormatException);
      expect(() => MoneyFormat.parseMajorToMinor('-5'), throwsFormatException);
    });

    test('formats large and signed balances without floating point', () {
      expect(
        MoneyFormat.formatMinor(MoneyMinor.fromInt(2500000), 'PKR'),
        'PKR 25,000',
      );
      expect(
        MoneyFormat.formatMinor(MoneyMinor.parse('15000000000'), 'PKR'),
        'PKR 150,000,000',
      );
      expect(MoneyFormat.formatMinor(MoneyMinor.zero, 'PKR'), 'PKR 0');
      expect(
        MoneyFormat.formatSignedMinor(BigInt.from(-425000), 'PKR'),
        'PKR -4,250',
      );
    });

    test('serializes MoneyMinor as digit string', () {
      expect(MoneyMinor.fromInt(2500000).toJson(), '2500000');
    });
  });

  group('FinanceSummaryService', () {
    const service = FinanceSummaryService();
    final categories = [
      const FinanceCategory(
        id: 'food',
        name: 'Food',
        type: TransactionType.expense,
        iconKey: 'food',
        isCustom: false,
      ),
      const FinanceCategory(
        id: 'salary',
        name: 'Salary',
        type: TransactionType.income,
        iconKey: 'salary',
        isCustom: false,
      ),
    ];

    FinanceTransaction tx({
      required String id,
      required TransactionType type,
      required int major,
      required String categoryId,
      required DateTime occurredAt,
    }) {
      final now = DateTime(2026, 8, 9);
      return FinanceTransaction(
        id: id,
        type: type,
        amountMinor: MoneyMinor.fromInt(major * 100),
        currencyCode: 'PKR',
        categoryId: categoryId,
        occurredAt: occurredAt,
        paymentMethod: PaymentMethod.cash,
        createdAt: now,
        updatedAt: now,
      );
    }

    test('income increases and expense decreases balance', () {
      final asOf = DateTime(2026, 8, 15, 12);
      final summary = service.summarize(
        transactions: [
          tx(
            id: 'i1',
            type: TransactionType.income,
            major: 100000,
            categoryId: 'salary',
            occurredAt: DateTime(2026, 8, 1),
          ),
          tx(
            id: 'e1',
            type: TransactionType.expense,
            major: 25000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 2),
          ),
        ],
        categories: categories,
        period: FinancePeriod.thisMonth,
        currencyCode: 'PKR',
        asOf: asOf,
      );
      expect(summary.currentBalanceMinor, BigInt.from(7500000));
      expect(summary.periodIncomeMinor, MoneyMinor.fromInt(10000000));
      expect(summary.periodExpenseMinor, MoneyMinor.fromInt(2500000));
    });

    test('supports negative balance and spent today', () {
      final asOf = DateTime(2026, 8, 9, 18);
      final summary = service.summarize(
        transactions: [
          tx(
            id: 'e1',
            type: TransactionType.expense,
            major: 5000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 9, 10),
          ),
          tx(
            id: 'e2',
            type: TransactionType.expense,
            major: 1000,
            categoryId: 'food',
            occurredAt: DateTime(2026, 7, 1),
          ),
        ],
        categories: categories,
        period: FinancePeriod.thisMonth,
        currencyCode: 'PKR',
        asOf: asOf,
      );
      expect(summary.currentBalanceMinor, BigInt.from(-600000));
      expect(summary.spentTodayMinor, MoneyMinor.fromInt(500000));
      expect(summary.periodExpenseMinor, MoneyMinor.fromInt(500000));
    });

    test('period bounds cover this/last month, year, all time', () {
      final asOf = DateTime(2026, 8, 15);
      final txs = [
        tx(
          id: 'jul',
          type: TransactionType.expense,
          major: 1000,
          categoryId: 'food',
          occurredAt: DateTime(2026, 7, 20),
        ),
        tx(
          id: 'aug',
          type: TransactionType.expense,
          major: 2000,
          categoryId: 'food',
          occurredAt: DateTime(2026, 8, 1),
        ),
        tx(
          id: 'prev-year',
          type: TransactionType.expense,
          major: 3000,
          categoryId: 'food',
          occurredAt: DateTime(2025, 12, 31, 23, 59),
        ),
      ];

      expect(
        service
            .summarize(
              transactions: txs,
              categories: categories,
              period: FinancePeriod.thisMonth,
              currencyCode: 'PKR',
              asOf: asOf,
            )
            .periodExpenseMinor,
        MoneyMinor.fromInt(200000),
      );
      expect(
        service
            .summarize(
              transactions: txs,
              categories: categories,
              period: FinancePeriod.lastMonth,
              currencyCode: 'PKR',
              asOf: asOf,
            )
            .periodExpenseMinor,
        MoneyMinor.fromInt(100000),
      );
      expect(
        service
            .summarize(
              transactions: txs,
              categories: categories,
              period: FinancePeriod.thisYear,
              currencyCode: 'PKR',
              asOf: asOf,
            )
            .periodExpenseMinor,
        MoneyMinor.fromInt(300000),
      );
      expect(
        service
            .summarize(
              transactions: txs,
              categories: categories,
              period: FinancePeriod.allTime,
              currencyCode: 'PKR',
              asOf: asOf,
            )
            .periodExpenseMinor,
        MoneyMinor.fromInt(600000),
      );
    });

    test('category breakdown uses precise basis points', () {
      final asOf = DateTime(2026, 8, 15);
      final summary = service.summarize(
        transactions: [
          tx(
            id: 'a',
            type: TransactionType.expense,
            major: 75,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 1),
          ),
          tx(
            id: 'b',
            type: TransactionType.expense,
            major: 25,
            categoryId: 'food',
            occurredAt: DateTime(2026, 8, 2),
          ),
        ],
        categories: categories,
        period: FinancePeriod.thisMonth,
        currencyCode: 'PKR',
        asOf: asOf,
      );
      expect(summary.categoryBreakdown, hasLength(1));
      expect(summary.categoryBreakdown.first.percentageBasisPoints, 10000);
      expect(
        summary.categoryBreakdown.first.amountMinor,
        MoneyMinor.fromInt(10000),
      );
    });

    test('large values remain precise', () {
      final asOf = DateTime(2026, 8, 15);
      final summary = service.summarize(
        transactions: [
          tx(
            id: 'big',
            type: TransactionType.income,
            major: 150000000,
            categoryId: 'salary',
            occurredAt: DateTime(2026, 8, 1),
          ),
        ],
        categories: categories,
        period: FinancePeriod.allTime,
        currencyCode: 'PKR',
        asOf: asOf,
      );
      expect(summary.currentBalanceMinor, BigInt.parse('15000000000'));
      expect(summary.periodIncomeMinor, MoneyMinor.parse('15000000000'));
    });
  });
}
