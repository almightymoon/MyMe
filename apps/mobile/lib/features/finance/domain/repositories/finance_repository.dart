import '../entities/finance_category.dart';
import '../entities/finance_enums.dart';
import '../entities/finance_summary.dart';
import '../entities/finance_transaction.dart';

/// Pluggable Finance persistence (fake / local now; API later).
///
/// Implementations: [FakeFinanceRepository], [LocalFinanceRepository].
abstract class FinanceRepository {
  Stream<List<FinanceTransaction>> watchTransactions();

  Future<List<FinanceTransaction>> getTransactions();

  Future<FinanceTransaction?> getTransaction(String id);

  Future<FinanceTransaction> createTransaction(FinanceTransaction transaction);

  Future<FinanceTransaction> updateTransaction(FinanceTransaction transaction);

  Future<void> deleteTransaction(String id);

  Future<List<FinanceCategory>> getCategories();

  Future<FinanceSummary> getSummary({
    required FinancePeriod period,
    DateTime? asOf,
  });

  /// No-op for in-memory stores; local reloads from disk.
  Future<void> refresh();
}
