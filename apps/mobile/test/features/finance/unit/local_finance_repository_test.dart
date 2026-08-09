import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/domain/value_objects/money_minor.dart';
import 'package:memy/features/finance/data/repositories/local_finance_repository.dart';
import 'package:memy/features/finance/data/seed/finance_seed.dart';
import 'package:memy/features/finance/domain/entities/finance_enums.dart';
import 'package:memy/features/finance/domain/entities/finance_transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late LocalFinanceRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repo = LocalFinanceRepository(
      prefs: prefs,
      seedBuilder: () =>
          FinanceSeed.demoTransactions(now: DateTime(2026, 8, 9, 12)),
      categorySeedBuilder: () =>
          FinanceSeed.demoCategories(now: DateTime(2026, 8, 9, 12)),
    );
  });

  test('seeds once when storage is uninitialized', () async {
    final first = await repo.getTransactions();
    expect(first, isNotEmpty);

    final id = first.first.id;
    await repo.deleteTransaction(id);
    final afterDelete = await repo.getTransactions();
    expect(afterDelete.length, first.length - 1);

    final again = LocalFinanceRepository(
      prefs: prefs,
      seedBuilder: () => first,
    );
    expect(await again.getTransactions(), hasLength(afterDelete.length));
  });

  test('deleting all transactions does not reseed', () async {
    final seeded = await repo.getTransactions();
    for (final tx in seeded) {
      await repo.deleteTransaction(tx.id);
    }
    expect(await repo.getTransactions(), isEmpty);

    final reopened = LocalFinanceRepository(prefs: prefs);
    expect(await reopened.getTransactions(), isEmpty);
  });

  test('CRUD persists money as digit strings and survives recreate', () async {
    await repo.ensureInitialized();
    for (final tx in await repo.getTransactions()) {
      await repo.deleteTransaction(tx.id);
    }

    final now = DateTime(2026, 8, 9, 15, 30);
    final created = await repo.createTransaction(
      FinanceTransaction(
        id: 'tx-persist',
        type: TransactionType.expense,
        amountMinor: MoneyMinor.fromInt(2500000),
        currencyCode: 'PKR',
        categoryId: 'cat_food',
        occurredAt: now,
        paymentMethod: PaymentMethod.cash,
        merchantOrSource: 'Cafe',
        createdAt: now,
        updatedAt: now,
      ),
    );
    expect(created.amountMinor, MoneyMinor.fromInt(2500000));

    final raw = prefs.getString(LocalFinanceRepository.storageKey)!;
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final txs = decoded['transactions'] as List<dynamic>;
    final saved = txs.first as Map<String, dynamic>;
    expect(saved['amountMinor'], isA<String>());
    expect(saved['amountMinor'], '2500000');

    final reopened = LocalFinanceRepository(prefs: prefs);
    final loaded = await reopened.getTransaction('tx-persist');
    expect(loaded, isNotNull);
    expect(loaded!.amountMinor, MoneyMinor.fromInt(2500000));
    expect(loaded.merchantOrSource, 'Cafe');

    await reopened.updateTransaction(
      loaded.copyWith(
        amountMinor: MoneyMinor.fromInt(3000000),
        note: 'Updated',
      ),
    );
    expect(
      (await reopened.getTransaction('tx-persist'))!.amountMinor,
      MoneyMinor.fromInt(3000000),
    );

    await reopened.deleteTransaction('tx-persist');
    expect(await reopened.getTransaction('tx-persist'), isNull);
  });

  test('corrupted document does not crash and yields empty ledger', () async {
    await prefs.setBool(LocalFinanceRepository.initializedKey, true);
    await prefs.setString(LocalFinanceRepository.storageKey, '{not-json');
    final broken = LocalFinanceRepository(prefs: prefs);
    expect(await broken.getTransactions(), isEmpty);
  });

  test('watchTransactions emits after create', () async {
    await repo.ensureInitialized();
    for (final tx in await repo.getTransactions()) {
      await repo.deleteTransaction(tx.id);
    }

    final events = <int>[];
    final sub = repo.watchTransactions().listen((list) {
      events.add(list.length);
    });
    await Future<void>.delayed(Duration.zero);

    final now = DateTime.now();
    await repo.createTransaction(
      FinanceTransaction(
        id: 'watched',
        type: TransactionType.income,
        amountMinor: MoneyMinor.fromInt(10000),
        currencyCode: 'PKR',
        categoryId: 'cat_salary',
        occurredAt: now,
        paymentMethod: PaymentMethod.bankTransfer,
        createdAt: now,
        updatedAt: now,
      ),
    );
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();
    expect(events, contains(1));
  });

  test('getSummary reflects edits and deletes', () async {
    await repo.ensureInitialized();
    for (final tx in await repo.getTransactions()) {
      await repo.deleteTransaction(tx.id);
    }
    final now = DateTime(2026, 8, 9, 12);
    await repo.createTransaction(
      FinanceTransaction(
        id: 'sum-1',
        type: TransactionType.income,
        amountMinor: MoneyMinor.fromInt(1000000),
        currencyCode: 'PKR',
        categoryId: 'cat_salary',
        occurredAt: now,
        paymentMethod: PaymentMethod.cash,
        createdAt: now,
        updatedAt: now,
      ),
    );
    var summary = await repo.getSummary(
      period: FinancePeriod.allTime,
      asOf: now,
    );
    expect(summary.currentBalanceMinor, BigInt.from(1000000));

    final existing = await repo.getTransaction('sum-1');
    await repo.updateTransaction(
      existing!.copyWith(amountMinor: MoneyMinor.fromInt(500000)),
    );
    summary = await repo.getSummary(period: FinancePeriod.allTime, asOf: now);
    expect(summary.currentBalanceMinor, BigInt.from(500000));

    await repo.deleteTransaction('sum-1');
    summary = await repo.getSummary(period: FinancePeriod.allTime, asOf: now);
    expect(summary.currentBalanceMinor, BigInt.zero);
  });
}
