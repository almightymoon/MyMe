import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/domain/services/money_format.dart';
import 'package:memy/core/domain/value_objects/money_minor.dart';
import 'package:memy/features/finance/application/controllers/transaction_form_controller.dart';
import 'package:memy/features/finance/application/providers/finance_providers.dart';
import 'package:memy/features/finance/data/repositories/local_finance_repository.dart';
import 'package:memy/features/finance/domain/entities/finance_enums.dart';

import '../../../helpers/test_app.dart';

Future<void> _openAddTransaction(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('nav_quick_add')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('quick_add_transaction')));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('transaction_form')), findsOneWidget);
}

Future<void> _fillExpenseFood25k(WidgetTester tester) async {
  final context = tester.element(find.byKey(const Key('transaction_form')));
  final container = ProviderScope.containerOf(context);
  final controller = container.read(addTransactionControllerProvider.notifier);
  controller.setType(TransactionType.expense);
  controller.setAmountText('25000');
  controller.setCategoryId('cat_food');
  controller.setPaymentMethod(PaymentMethod.cash);
  controller.setOccurredAt(DateTime.now());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('finance overview shows populated, empty, and period change', (
    tester,
  ) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go(RoutePaths.finance);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('finance_overview')), findsOneWidget);
    expect(find.byKey(const Key('finance_populated')), findsOneWidget);
    expect(find.byKey(const Key('finance_balance_value')), findsOneWidget);
    expect(find.byKey(const Key('finance_planned_feature')), findsOneWidget);

    await tester.tap(find.byKey(const Key('finance_period_selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('finance_period_allTime')));
    await tester.pumpAndSettle();
    expect(find.text('All Time'), findsWidgets);

    await tester.tap(find.byKey(const Key('finance_see_all')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('transaction_history_list')), findsOneWidget);
  });

  testWidgets('finance empty state when ledger cleared', (tester) async {
    await pumpMemyApp(tester, seedFinance: false);
    await signInToToday(tester);
    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go(RoutePaths.finance);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('finance_empty')), findsOneWidget);
  });

  testWidgets('add transaction validation and duplicate save protection', (
    tester,
  ) async {
    await pumpMemyApp(tester, seedFinance: false, seedGoals: false);
    await signInToToday(tester);
    await _openAddTransaction(tester);

    await tester.tap(find.byKey(const Key('transaction_save_button')));
    await tester.pumpAndSettle();
    expect(find.text('Amount is required'), findsOneWidget);
    expect(find.text('Category is required'), findsOneWidget);

    await _fillExpenseFood25k(tester);

    final context = tester.element(find.byKey(const Key('transaction_form')));
    final container = ProviderScope.containerOf(context);
    final controller = container.read(
      addTransactionControllerProvider.notifier,
    );

    final first = controller.submit(validCategoryIds: {'cat_food'});
    final second = controller.submit(validCategoryIds: {'cat_food'});
    final ids = await Future.wait([first, second]);
    final createdIds = ids.whereType<String>().toList();
    expect(createdIds, hasLength(1));

    await tester.pumpAndSettle();
    final repo = container.read(financeRepositoryProvider);
    expect(await repo.getTransactions(), hasLength(1));
    expect(
      (await repo.getTransactions()).first.amountMinor,
      MoneyMinor.fromInt(2500000),
    );
  });

  testWidgets('history detail edit delete flow', (tester) async {
    await pumpMemyApp(tester, seedFinance: false, seedGoals: false);
    await signInToToday(tester);
    await _openAddTransaction(tester);
    await _fillExpenseFood25k(tester);

    final context = tester.element(find.byKey(const Key('transaction_form')));
    final container = ProviderScope.containerOf(context);
    final id = await container
        .read(addTransactionControllerProvider.notifier)
        .submit(validCategoryIds: {'cat_food'});
    expect(id, isNotNull);
    await tester.pumpAndSettle();

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('transaction_form'))),
    );
    router.go(RoutePaths.transactionHistory);
    await tester.pumpAndSettle();
    expect(find.byKey(Key('transaction_tile_$id')), findsOneWidget);

    await tester.tap(find.byKey(Key('transaction_tile_$id')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('transaction_detail_scroll')), findsOneWidget);

    await tester.tap(find.byKey(const Key('transaction_edit_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('transaction_form')), findsOneWidget);

    final editController = container.read(
      editTransactionControllerProvider(id!).notifier,
    );
    // Ensure hydrate completed.
    await tester.pumpAndSettle();
    editController.setAmountText('26000');
    final updatedId = await editController.submit(
      validCategoryIds: {'cat_food'},
    );
    expect(updatedId, id);
    await tester.pumpAndSettle();

    expect(
      (await container.read(financeRepositoryProvider).getTransaction(id))!
          .amountMinor,
      MoneyMinor.fromInt(2600000),
    );

    router.go(RoutePaths.transactionDetailPath(id));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('transaction_delete_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('transaction_delete_confirm')));
    await tester.pumpAndSettle();
    expect(
      await container.read(financeRepositoryProvider).getTransaction(id),
      isNull,
    );
  });

  testWidgets('Today finance card updates after expense', (tester) async {
    await pumpMemyApp(tester, seedFinance: false, seedGoals: false);
    await signInToToday(tester);

    expect(find.byKey(const Key('today_finance_card')), findsNothing);

    await _openAddTransaction(tester);
    await _fillExpenseFood25k(tester);
    final context = tester.element(find.byKey(const Key('transaction_form')));
    final container = ProviderScope.containerOf(context);
    final id = await container
        .read(addTransactionControllerProvider.notifier)
        .submit(validCategoryIds: {'cat_food'});
    expect(id, isNotNull);
    await tester.pumpAndSettle();

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('transaction_form'))),
    );
    router.go(RoutePaths.today);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today_finance_card')), findsOneWidget);
    expect(
      find.text(MoneyFormat.formatSignedMinor(BigInt.from(-2500000), 'PKR')),
      findsWidgets,
    );
  });

  testWidgets('integration: Quick Add expense 25k Food, double save, persist', (
    tester,
  ) async {
    final prefs = await setupTestPreferences(
      seedGoals: false,
      seedFinance: false,
    );
    await pumpMemyApp(
      tester,
      prefs: prefs,
      seedGoals: false,
      seedFinance: false,
    );
    await signInToToday(tester);
    await _openAddTransaction(tester);
    await _fillExpenseFood25k(tester);

    final context = tester.element(find.byKey(const Key('transaction_form')));
    final container = ProviderScope.containerOf(context);
    final controller = container.read(
      addTransactionControllerProvider.notifier,
    );

    final rapid = await Future.wait([
      controller.submit(validCategoryIds: {'cat_food'}),
      controller.submit(validCategoryIds: {'cat_food'}),
      controller.submit(validCategoryIds: {'cat_food'}),
    ]);
    await tester.pumpAndSettle();

    final created = rapid.whereType<String>().toSet();
    expect(created, hasLength(1));

    final repo = container.read(financeRepositoryProvider);
    final txs = await repo.getTransactions();
    expect(txs, hasLength(1));
    expect(txs.first.amountMinor, MoneyMinor.fromInt(2500000));
    expect(txs.first.categoryId, 'cat_food');

    final summary = await repo.getSummary(period: FinancePeriod.thisMonth);
    expect(summary.periodExpenseMinor, MoneyMinor.fromInt(2500000));
    expect(
      summary.categoryBreakdown.any((b) => b.categoryId == 'cat_food'),
      isTrue,
    );

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('transaction_form'))),
    );
    router.go(RoutePaths.transactionHistory);
    await tester.pumpAndSettle();
    expect(find.byKey(Key('transaction_tile_${txs.first.id}')), findsOneWidget);

    router.go(RoutePaths.finance);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('finance_populated')), findsOneWidget);
    expect(find.textContaining('Food'), findsWidgets);

    router.go(RoutePaths.today);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today_finance_card')), findsOneWidget);
    expect(
      find.text(MoneyFormat.formatSignedMinor(BigInt.from(-2500000), 'PKR')),
      findsWidgets,
    );

    final reopened = LocalFinanceRepository(prefs: prefs);
    final persisted = await reopened.getTransactions();
    expect(persisted, hasLength(1));
    expect(persisted.first.amountMinor, MoneyMinor.fromInt(2500000));
  });
}
