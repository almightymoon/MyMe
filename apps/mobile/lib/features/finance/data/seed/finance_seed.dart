import '../../../../core/domain/value_objects/money_minor.dart';
import '../../domain/entities/finance_category.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_transaction.dart';

/// Demo categories and transactions for first-run local / fake seeds only.
///
/// Presentation must never import this file.
abstract final class FinanceSeed {
  static const String baseCurrencyCode = 'PKR';

  static List<FinanceCategory> demoCategories({DateTime? now}) {
    final asOf = now ?? DateTime.now();
    return [
      FinanceCategory(
        id: 'cat_food',
        name: 'Food',
        type: TransactionType.expense,
        iconKey: 'food',
        isCustom: false,
        createdAt: asOf,
      ),
      FinanceCategory(
        id: 'cat_transport',
        name: 'Transport',
        type: TransactionType.expense,
        iconKey: 'transport',
        isCustom: false,
        createdAt: asOf,
      ),
      FinanceCategory(
        id: 'cat_shopping',
        name: 'Shopping',
        type: TransactionType.expense,
        iconKey: 'shopping',
        isCustom: false,
        createdAt: asOf,
      ),
      FinanceCategory(
        id: 'cat_bills',
        name: 'Bills',
        type: TransactionType.expense,
        iconKey: 'bills',
        isCustom: false,
        createdAt: asOf,
      ),
      FinanceCategory(
        id: 'cat_others',
        name: 'Others',
        type: TransactionType.expense,
        iconKey: 'other',
        isCustom: false,
        createdAt: asOf,
      ),
      FinanceCategory(
        id: 'cat_salary',
        name: 'Salary',
        type: TransactionType.income,
        iconKey: 'salary',
        isCustom: false,
        createdAt: asOf,
      ),
      FinanceCategory(
        id: 'cat_other_income',
        name: 'Other income',
        type: TransactionType.income,
        iconKey: 'income',
        isCustom: false,
        createdAt: asOf,
      ),
    ];
  }

  /// Deterministic demo ledger (amounts in paisa / 2-decimal minor units).
  ///
  /// All-time: income PKR 334,000 − expense PKR 89,000 = balance PKR 245,000.
  static List<FinanceTransaction> demoTransactions({DateTime? now}) {
    final asOf = now ?? DateTime.now();
    final monthStart = DateTime(asOf.year, asOf.month, 1);
    DateTime atDay(int day, {int hour = 12}) =>
        DateTime(monthStart.year, monthStart.month, day, hour, 0);

    final created = monthStart;
    return [
      _tx(
        id: 'tx_salary',
        type: TransactionType.income,
        amountMajor: 180000,
        categoryId: 'cat_salary',
        occurredAt: atDay(1, hour: 9),
        method: PaymentMethod.bankTransfer,
        merchant: 'Employer',
        created: created,
      ),
      _tx(
        id: 'tx_bonus',
        type: TransactionType.income,
        amountMajor: 154000,
        categoryId: 'cat_other_income',
        occurredAt: atDay(5, hour: 10),
        method: PaymentMethod.bankTransfer,
        merchant: 'Side project',
        created: created,
      ),
      _tx(
        id: 'tx_food_1',
        type: TransactionType.expense,
        amountMajor: 22450,
        categoryId: 'cat_food',
        occurredAt: atDay(3, hour: 13),
        method: PaymentMethod.debitCard,
        merchant: 'Grocery & cafes',
        created: created,
      ),
      _tx(
        id: 'tx_transport_1',
        type: TransactionType.expense,
        amountMajor: 17800,
        categoryId: 'cat_transport',
        occurredAt: atDay(4, hour: 8),
        method: PaymentMethod.mobileWallet,
        merchant: 'Commute',
        created: created,
      ),
      _tx(
        id: 'tx_shopping_1',
        type: TransactionType.expense,
        amountMajor: 13300,
        categoryId: 'cat_shopping',
        occurredAt: atDay(7, hour: 16),
        method: PaymentMethod.creditCard,
        merchant: 'Retail',
        created: created,
      ),
      _tx(
        id: 'tx_bills_1',
        type: TransactionType.expense,
        amountMajor: 13300,
        categoryId: 'cat_bills',
        occurredAt: atDay(8, hour: 11),
        method: PaymentMethod.bankTransfer,
        merchant: 'Utilities',
        created: created,
      ),
      _tx(
        id: 'tx_others_1',
        type: TransactionType.expense,
        amountMajor: 17900,
        categoryId: 'cat_others',
        occurredAt: atDay(10, hour: 15),
        method: PaymentMethod.cash,
        merchant: 'Misc',
        created: created,
      ),
      // Spent today slice (local calendar day of [asOf]).
      _tx(
        id: 'tx_today_coffee',
        type: TransactionType.expense,
        amountMajor: 4250,
        categoryId: 'cat_food',
        occurredAt: DateTime(asOf.year, asOf.month, asOf.day, 12, 30),
        method: PaymentMethod.mobileWallet,
        merchant: 'Coffee & lunch',
        created: created,
        note: 'Today spend',
      ),
    ];
  }

  static FinanceTransaction _tx({
    required String id,
    required TransactionType type,
    required int amountMajor,
    required String categoryId,
    required DateTime occurredAt,
    required PaymentMethod method,
    required DateTime created,
    String? merchant,
    String? note,
  }) {
    return FinanceTransaction(
      id: id,
      type: type,
      amountMinor: MoneyMinor.fromInt(amountMajor * 100),
      currencyCode: baseCurrencyCode,
      categoryId: categoryId,
      occurredAt: occurredAt,
      paymentMethod: method,
      merchantOrSource: merchant,
      note: note,
      createdAt: created,
      updatedAt: created,
    );
  }
}
