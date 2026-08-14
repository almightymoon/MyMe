import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/config/environment_config.dart';
import '../../../auth/application/auth_session_controller.dart';
import '../../../auth/data/account_local_store.dart';
import '../../data/repositories/fake_finance_repository.dart';
import '../../data/repositories/local_finance_repository.dart';
import '../../../../core/domain/value_objects/year_month.dart';
import '../../../user/application/providers/user_providers.dart';
import '../../domain/entities/finance_budget.dart';
import '../../domain/entities/finance_category.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_money_position.dart';
import '../../domain/entities/finance_period_report.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/services/finance_report_service.dart';
import '../../domain/services/finance_summary_service.dart';

/// Override in tests to force `fake` / `local` without dart-defines.
final financeDataSourceProvider = Provider<FinanceDataSource>((ref) {
  return EnvironmentConfig.resolveFinanceDataSource();
});

final financeSummaryServiceProvider = Provider<FinanceSummaryService>((ref) {
  return const FinanceSummaryService();
});

final financeReportServiceProvider = Provider<FinanceReportService>((ref) {
  return FinanceReportService(
    summaryService: ref.watch(financeSummaryServiceProvider),
  );
});

final localFinanceRepositoryProvider = Provider<LocalFinanceRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final store = AccountLocalStore(ref.watch(authSessionProvider)?.userId);
  final repo = LocalFinanceRepository(
    prefs: prefs,
    documentKey: store.key(LocalFinanceRepository.storageKey),
    initKey: store.key(LocalFinanceRepository.initializedKey),
    summaryService: ref.watch(financeSummaryServiceProvider),
    // Keep built-in categories; never seed sample transactions in production.
    seedBuilder: EnvironmentConfig.shouldSeedDemoContent
        ? null
        : () => const [],
  );
  ref.onDispose(repo.dispose);
  return repo;
});

/// Resolves [FinanceRepository] from [financeDataSourceProvider].
///
/// Modes (`--dart-define=FINANCE_DATA_SOURCE=`):
/// - `fake` — in-memory [FakeFinanceRepository]
/// - `local` — [LocalFinanceRepository] (default)
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final source = ref.watch(financeDataSourceProvider);
  switch (source) {
    case FinanceDataSource.fake:
      final repo = FakeFinanceRepository(
        summaryService: ref.watch(financeSummaryServiceProvider),
      );
      ref.onDispose(repo.dispose);
      return repo;
    case FinanceDataSource.local:
      return ref.watch(localFinanceRepositoryProvider);
  }
});

final financePeriodProvider = StateProvider<FinancePeriod>((ref) {
  return FinancePeriod.thisMonth;
});

final financeTransactionsProvider =
    FutureProvider.autoDispose<List<FinanceTransaction>>((ref) {
      return ref.watch(financeRepositoryProvider).getTransactions();
    });

final financeCategoriesProvider =
    FutureProvider.autoDispose<List<FinanceCategory>>((ref) {
      return ref.watch(financeRepositoryProvider).getCategories();
    });

final financeTransactionByIdProvider = Provider.autoDispose
    .family<AsyncValue<FinanceTransaction?>, String>((ref, id) {
      return ref.watch(financeTransactionsProvider).whenData((list) {
        for (final tx in list) {
          if (tx.id == id) return tx;
        }
        return null;
      });
    });

/// Reactive summary for the selected [financePeriodProvider].
final financeSummaryProvider = Provider.autoDispose<AsyncValue<FinanceSummary>>(
  (ref) {
    final period = ref.watch(financePeriodProvider);
    final txsAsync = ref.watch(financeTransactionsProvider);
    final catsAsync = ref.watch(financeCategoriesProvider);
    final service = ref.watch(financeSummaryServiceProvider);

    if (txsAsync.isLoading || catsAsync.isLoading) {
      return const AsyncValue.loading();
    }
    if (txsAsync.hasError) {
      return AsyncValue.error(
        txsAsync.error!,
        txsAsync.stackTrace ?? StackTrace.current,
      );
    }
    if (catsAsync.hasError) {
      return AsyncValue.error(
        catsAsync.error!,
        catsAsync.stackTrace ?? StackTrace.current,
      );
    }

    final transactions = txsAsync.requireValue;
    final categories = catsAsync.requireValue;
    return AsyncValue.data(
      service.summarize(
        transactions: transactions,
        categories: categories,
        period: period,
        currencyCode: ref.watch(baseCurrencyProvider),
      ),
    );
  },
);

/// Today always uses this-month period for income/expense cards.
final todayFinanceSummaryProvider =
    Provider.autoDispose<AsyncValue<FinanceSummary>>((ref) {
      final txsAsync = ref.watch(financeTransactionsProvider);
      final catsAsync = ref.watch(financeCategoriesProvider);
      final service = ref.watch(financeSummaryServiceProvider);

      if (txsAsync.isLoading || catsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (txsAsync.hasError) {
        return AsyncValue.error(
          txsAsync.error!,
          txsAsync.stackTrace ?? StackTrace.current,
        );
      }
      if (catsAsync.hasError) {
        return AsyncValue.error(
          catsAsync.error!,
          catsAsync.stackTrace ?? StackTrace.current,
        );
      }

      return AsyncValue.data(
        service.summarize(
          transactions: txsAsync.requireValue,
          categories: catsAsync.requireValue,
          period: FinancePeriod.thisMonth,
          currencyCode: ref.watch(baseCurrencyProvider),
        ),
      );
    });

final financeBudgetsProvider = FutureProvider.autoDispose<List<FinanceBudget>>((
  ref,
) {
  return ref.watch(financeRepositoryProvider).getBudgets();
});

final financeBudgetMonthProvider = StateProvider<YearMonth>((ref) {
  return YearMonth.fromDateTime(DateTime.now());
});

final financeBudgetsForSelectedMonthProvider =
    Provider.autoDispose<AsyncValue<List<FinanceBudgetProgress>>>((ref) {
      final month = ref.watch(financeBudgetMonthProvider);
      final budgetsAsync = ref.watch(financeBudgetsProvider);
      final txsAsync = ref.watch(financeTransactionsProvider);
      final report = ref.watch(financeReportServiceProvider);
      if (budgetsAsync.isLoading || txsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (budgetsAsync.hasError) {
        return AsyncValue.error(
          budgetsAsync.error!,
          budgetsAsync.stackTrace ?? StackTrace.current,
        );
      }
      final txs = txsAsync.valueOrNull ?? const <FinanceTransaction>[];
      final budgets = (budgetsAsync.valueOrNull ?? const <FinanceBudget>[])
          .where((b) => !b.isArchived && b.month == month);
      return AsyncValue.data([
        for (final budget in budgets)
          FinanceBudgetProgress(
            budget: budget,
            spentMinor: report.spentForBudget(
              budget: budget,
              transactions: txs,
              currencyCode: ref.watch(baseCurrencyProvider),
            ),
          ),
      ]);
    });

final todayFinanceBudgetProgressProvider =
    Provider.autoDispose<AsyncValue<FinanceBudgetProgress?>>((ref) {
      final month = YearMonth.fromDateTime(DateTime.now());
      final budgetsAsync = ref.watch(financeBudgetsProvider);
      final txsAsync = ref.watch(financeTransactionsProvider);
      final report = ref.watch(financeReportServiceProvider);
      if (budgetsAsync.isLoading || txsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (budgetsAsync.hasError) {
        return AsyncValue.error(
          budgetsAsync.error!,
          budgetsAsync.stackTrace ?? StackTrace.current,
        );
      }
      final txs = txsAsync.valueOrNull ?? const <FinanceTransaction>[];
      final budgets = budgetsAsync.valueOrNull ?? const <FinanceBudget>[];
      FinanceBudget? overall;
      for (final budget in budgets) {
        if (!budget.isArchived && budget.month == month && budget.isOverall) {
          overall = budget;
          break;
        }
      }
      if (overall == null) return const AsyncValue.data(null);
      return AsyncValue.data(
        FinanceBudgetProgress(
          budget: overall,
          spentMinor: report.spentForBudget(
            budget: overall,
            transactions: txs,
            currencyCode: ref.watch(baseCurrencyProvider),
          ),
        ),
      );
    });

final financeBudgetByIdProvider = Provider.autoDispose
    .family<AsyncValue<FinanceBudget?>, String>((ref, id) {
      return ref.watch(financeBudgetsProvider).whenData((list) {
        for (final budget in list) {
          if (budget.id == id) return budget;
        }
        return null;
      });
    });

final financeMoneyPositionsProvider =
    FutureProvider.autoDispose<List<FinanceMoneyPosition>>((ref) {
      return ref.watch(financeRepositoryProvider).getMoneyPositions();
    });

final financeMoneyPositionByIdProvider = Provider.autoDispose
    .family<AsyncValue<FinanceMoneyPosition?>, String>((ref, id) {
      return ref.watch(financeMoneyPositionsProvider).whenData((list) {
        for (final position in list) {
          if (position.id == id) return position;
        }
        return null;
      });
    });

final financeMoneyOwedTotalsProvider =
    Provider.autoDispose<AsyncValue<MoneyOwedTotals>>((ref) {
      return ref.watch(financeMoneyPositionsProvider).whenData((list) {
        return MoneyOwedTotals.fromPositions(
          list,
          currencyCode: ref.watch(baseCurrencyProvider),
        );
      });
    });

final financePeriodReportProvider =
    Provider.autoDispose<AsyncValue<FinancePeriodReport>>((ref) {
      final period = ref.watch(financePeriodProvider);
      final txsAsync = ref.watch(financeTransactionsProvider);
      final catsAsync = ref.watch(financeCategoriesProvider);
      final budgetsAsync = ref.watch(financeBudgetsProvider);
      final report = ref.watch(financeReportServiceProvider);
      if (txsAsync.isLoading || catsAsync.isLoading || budgetsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (txsAsync.hasError) {
        return AsyncValue.error(
          txsAsync.error!,
          txsAsync.stackTrace ?? StackTrace.current,
        );
      }
      return AsyncValue.data(
        report.build(
          transactions: txsAsync.requireValue,
          categories: catsAsync.valueOrNull ?? const [],
          budgets: budgetsAsync.valueOrNull ?? const [],
          period: period,
          currencyCode: ref.watch(baseCurrencyProvider),
        ),
      );
    });
