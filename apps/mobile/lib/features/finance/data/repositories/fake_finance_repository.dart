import 'dart:async';

import '../../domain/entities/finance_category.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/services/finance_summary_service.dart';
import '../seed/finance_seed.dart';

/// In-memory [FinanceRepository] for demos and widget tests.
class FakeFinanceRepository implements FinanceRepository {
  FakeFinanceRepository({
    List<FinanceTransaction>? initialTransactions,
    List<FinanceCategory>? initialCategories,
    this.baseCurrencyCode = FinanceSeed.baseCurrencyCode,
    this.summaryService = const FinanceSummaryService(),
  }) : _transactions = List<FinanceTransaction>.from(
         initialTransactions ?? FinanceSeed.demoTransactions(),
       ),
       _categories = List<FinanceCategory>.from(
         initialCategories ?? FinanceSeed.demoCategories(),
       );

  final String baseCurrencyCode;
  final FinanceSummaryService summaryService;

  final List<FinanceTransaction> _transactions;
  final List<FinanceCategory> _categories;
  final _controller = StreamController<List<FinanceTransaction>>.broadcast();

  List<FinanceTransaction> get snapshot =>
      List.unmodifiable(_sorted(_transactions));

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_sorted(_transactions)));
    }
  }

  List<FinanceTransaction> _sorted(List<FinanceTransaction> list) {
    final copy = [...list]
      ..sort((a, b) {
        final cmp = b.occurredAt.compareTo(a.occurredAt);
        if (cmp != 0) return cmp;
        return b.createdAt.compareTo(a.createdAt);
      });
    return copy;
  }

  @override
  Stream<List<FinanceTransaction>> watchTransactions() async* {
    yield List.unmodifiable(_sorted(_transactions));
    yield* _controller.stream;
  }

  @override
  Future<List<FinanceTransaction>> getTransactions() async =>
      List.unmodifiable(_sorted(_transactions));

  @override
  Future<FinanceTransaction?> getTransaction(String id) async {
    for (final tx in _transactions) {
      if (tx.id == id) return tx;
    }
    return null;
  }

  @override
  Future<FinanceTransaction> createTransaction(
    FinanceTransaction transaction,
  ) async {
    if (_transactions.any((t) => t.id == transaction.id)) {
      throw StateError('Transaction already exists: ${transaction.id}');
    }
    _transactions.add(transaction);
    _emit();
    return transaction;
  }

  @override
  Future<FinanceTransaction> updateTransaction(
    FinanceTransaction transaction,
  ) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index < 0) {
      throw StateError('Transaction not found: ${transaction.id}');
    }
    final updated = transaction.copyWith(updatedAt: DateTime.now());
    _transactions[index] = updated;
    _emit();
    return updated;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final before = _transactions.length;
    _transactions.removeWhere((t) => t.id == id);
    if (_transactions.length == before) {
      throw StateError('Transaction not found: $id');
    }
    _emit();
  }

  @override
  Future<List<FinanceCategory>> getCategories() async =>
      List.unmodifiable(_categories);

  @override
  Future<FinanceSummary> getSummary({
    required FinancePeriod period,
    DateTime? asOf,
  }) async {
    return summaryService.summarize(
      transactions: _transactions,
      categories: _categories,
      period: period,
      currencyCode: baseCurrencyCode,
      asOf: asOf,
    );
  }

  @override
  Future<void> refresh() async {
    _emit();
  }

  /// Wipes all in-memory transactions and resets categories to the seed catalog.
  Future<void> clearAllLocalData() async {
    _transactions.clear();
    _categories
      ..clear()
      ..addAll(FinanceSeed.demoCategories());
    _emit();
  }

  void dispose() {
    _controller.close();
  }
}
