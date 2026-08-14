import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/value_objects/money_minor.dart';
import 'package:memy/features/auth/data/account_local_store.dart';
import 'package:memy/features/auth/data/account_namespace.dart';
import 'package:memy/features/finance/data/repositories/local_finance_repository.dart';
import 'package:memy/features/finance/domain/entities/finance_enums.dart';
import 'package:memy/features/finance/domain/entities/finance_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('finance records do not leak across accounts', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    const userA = AccountLocalStore('user-a');
    const userB = AccountLocalStore('user-b');
    final now = DateTime.utc(2026, 8, 11);
    final repoA = LocalFinanceRepository(
      prefs: prefs,
      documentKey: userA.key(LocalFinanceRepository.storageKey),
      initKey: userA.key(LocalFinanceRepository.initializedKey),
      seedBuilder: () => const [],
      categorySeedBuilder: () => const [],
    );
    await repoA.createTransaction(
      FinanceTransaction(
        id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        type: TransactionType.expense,
        amountMinor: MoneyMinor.fromInt(100),
        currencyCode: 'PKR',
        categoryId: 'cat',
        occurredAt: now,
        paymentMethod: PaymentMethod.cash,
        createdAt: now,
        updatedAt: now,
      ),
    );
    final repoB = LocalFinanceRepository(
      prefs: prefs,
      documentKey: userB.key(LocalFinanceRepository.storageKey),
      initKey: userB.key(LocalFinanceRepository.initializedKey),
      seedBuilder: () => const [],
      categorySeedBuilder: () => const [],
    );
    expect(await repoB.getTransactions(), isEmpty);
    expect(await repoA.getTransactions(), isNotEmpty);
    expect(
      accountStorageNamespace('user-a'),
      isNot(accountStorageNamespace('user-b')),
    );
  });
}
