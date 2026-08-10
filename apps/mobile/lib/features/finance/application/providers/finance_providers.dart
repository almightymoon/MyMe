import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/config/environment_config.dart';
import '../../data/repositories/fake_finance_repository.dart';
import '../../data/repositories/local_finance_repository.dart';
import '../../data/seed/finance_seed.dart';
import '../../domain/entities/finance_category.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/services/finance_summary_service.dart';

/// Override in tests to force `fake` / `local` without dart-defines.
final financeDataSourceProvider = Provider<FinanceDataSource>((ref) {
  return EnvironmentConfig.financeDataSource;
});

final financeSummaryServiceProvider = Provider<FinanceSummaryService>((ref) {
  return const FinanceSummaryService();
});

final localFinanceRepositoryProvider = Provider<LocalFinanceRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final repo = LocalFinanceRepository(
    prefs: prefs,
    summaryService: ref.watch(financeSummaryServiceProvider),
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
    StreamProvider.autoDispose<List<FinanceTransaction>>((ref) {
      return ref.watch(financeRepositoryProvider).watchTransactions();
    });

final financeCategoriesProvider =
    FutureProvider.autoDispose<List<FinanceCategory>>((ref) {
      // Re-read when transactions change so category lookups stay fresh after seed.
      ref.watch(financeTransactionsProvider);
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
        currencyCode: FinanceSeed.baseCurrencyCode,
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
          currencyCode: FinanceSeed.baseCurrencyCode,
        ),
      );
    });
