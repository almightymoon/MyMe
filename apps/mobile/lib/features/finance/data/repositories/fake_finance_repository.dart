import 'dart:async';

import '../../../../core/domain/value_objects/year_month.dart';
import '../../../../core/errors/app_exception.dart';
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
import '../seed/finance_seed.dart';

/// In-memory [FinanceRepository] for demos and widget tests.
class FakeFinanceRepository implements FinanceRepository {
  FakeFinanceRepository({
    List<FinanceTransaction>? initialTransactions,
    List<FinanceCategory>? initialCategories,
    this.baseCurrencyCode = FinanceSeed.baseCurrencyCode,
    this.summaryService = const FinanceSummaryService(),
    this.reportService = const FinanceReportService(),
    List<FinanceBudget>? initialBudgets,
    List<FinanceMoneyPosition>? initialMoneyPositions,
  }) : _transactions = List<FinanceTransaction>.from(
         initialTransactions ?? FinanceSeed.demoTransactions(),
       ),
       _categories = List<FinanceCategory>.from(
         initialCategories ?? FinanceSeed.demoCategories(),
       ),
       _budgets = List<FinanceBudget>.from(initialBudgets ?? const []),
       _moneyPositions = List<FinanceMoneyPosition>.from(
         initialMoneyPositions ?? const [],
       );

  final String baseCurrencyCode;
  final FinanceSummaryService summaryService;
  final FinanceReportService reportService;

  final List<FinanceTransaction> _transactions;
  final List<FinanceCategory> _categories;
  final List<FinanceBudget> _budgets;
  final List<FinanceMoneyPosition> _moneyPositions;
  final _controller = StreamController<List<FinanceTransaction>>.broadcast();
  final _categoryController =
      StreamController<List<FinanceCategory>>.broadcast();
  final _budgetController = StreamController<List<FinanceBudget>>.broadcast();
  final _moneyPositionController =
      StreamController<List<FinanceMoneyPosition>>.broadcast();

  List<FinanceTransaction> get snapshot =>
      List.unmodifiable(_sorted(_transactions));

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_sorted(_transactions)));
    }
    if (!_categoryController.isClosed) {
      _categoryController.add(List.unmodifiable(_categories));
    }
    if (!_budgetController.isClosed) {
      _budgetController.add(List.unmodifiable(_budgets));
    }
    if (!_moneyPositionController.isClosed) {
      _moneyPositionController.add(List.unmodifiable(_moneyPositions));
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
  Stream<List<FinanceCategory>> watchCategories() async* {
    yield List.unmodifiable(_categories);
    yield* _categoryController.stream;
  }

  @override
  Future<List<FinanceCategory>> getCategories() async =>
      List.unmodifiable(_categories);

  @override
  Future<FinanceCategory> createCustomCategory(FinanceCategory category) async {
    _categories.add(category);
    _emit();
    return category;
  }

  @override
  Future<FinanceCategory> updateCustomCategory(FinanceCategory category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index < 0) throw AppException.notFound('Category not found.');
    _categories[index] = category;
    _emit();
    return category;
  }

  @override
  Future<void> archiveCategory(String id) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index < 0) throw AppException.notFound('Category not found.');
    final existing = _categories[index];
    _categories[index] = FinanceCategory(
      id: existing.id,
      name: existing.name,
      type: existing.type,
      iconKey: existing.iconKey,
      isCustom: existing.isCustom,
      isArchived: true,
      createdAt: existing.createdAt,
    );
    _emit();
  }

  @override
  Future<void> restoreCategory(String id) async {
    final index = _categories.indexWhere((c) => c.id == id);
    if (index < 0) throw AppException.notFound('Category not found.');
    final existing = _categories[index];
    _categories[index] = FinanceCategory(
      id: existing.id,
      name: existing.name,
      type: existing.type,
      iconKey: existing.iconKey,
      isCustom: existing.isCustom,
      createdAt: existing.createdAt,
    );
    _emit();
  }

  @override
  Stream<List<FinanceBudget>> watchBudgets() async* {
    yield List.unmodifiable(_budgets);
    yield* _budgetController.stream;
  }

  @override
  Future<List<FinanceBudget>> getBudgets() async => List.unmodifiable(_budgets);

  @override
  Future<List<FinanceBudget>> getBudgetsForMonth(YearMonth month) async =>
      List.unmodifiable(
        _budgets.where((b) => !b.isArchived && b.month == month),
      );

  @override
  Future<FinanceBudget?> getBudget(String id) async {
    for (final budget in _budgets) {
      if (budget.id == id) return budget;
    }
    return null;
  }

  @override
  Future<FinanceBudget> createBudget(FinanceBudget budget) async {
    _budgets.add(budget);
    _emit();
    return budget;
  }

  @override
  Future<FinanceBudget> updateBudget(FinanceBudget budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index < 0) throw AppException.notFound('Budget not found.');
    _budgets[index] = budget;
    _emit();
    return budget;
  }

  @override
  Future<void> deleteBudget(String id) async {
    final before = _budgets.length;
    _budgets.removeWhere((b) => b.id == id);
    if (_budgets.length == before) {
      throw AppException.notFound('Budget not found.');
    }
    _emit();
  }

  @override
  Stream<List<FinanceMoneyPosition>> watchMoneyPositions() async* {
    yield List.unmodifiable(_moneyPositions);
    yield* _moneyPositionController.stream;
  }

  @override
  Future<List<FinanceMoneyPosition>> getMoneyPositions() async =>
      List.unmodifiable(_moneyPositions);

  @override
  Future<FinanceMoneyPosition?> getMoneyPosition(String id) async {
    for (final position in _moneyPositions) {
      if (position.id == id) return position;
    }
    return null;
  }

  @override
  Future<FinanceMoneyPosition> createMoneyPosition(
    FinanceMoneyPosition position,
  ) async {
    if (_moneyPositions.any((p) => p.id == position.id)) {
      throw AppException.conflict('This money-owed row already exists.');
    }
    _moneyPositions.add(position);
    _emit();
    return position;
  }

  @override
  Future<FinanceMoneyPosition> updateMoneyPosition(
    FinanceMoneyPosition position,
  ) async {
    final index = _moneyPositions.indexWhere((p) => p.id == position.id);
    if (index < 0) {
      throw AppException.notFound('Money owed entry not found.');
    }
    final existing = _moneyPositions[index];
    if (existing.paidMinor > position.originalAmountMinor) {
      throw AppException.validation(
        'Amount cannot be less than what is already paid.',
      );
    }
    final updated = position.copyWith(payments: existing.payments);
    _moneyPositions[index] = updated;
    _emit();
    return updated;
  }

  @override
  Future<void> deleteMoneyPosition(String id) async {
    final before = _moneyPositions.length;
    _moneyPositions.removeWhere((p) => p.id == id);
    if (_moneyPositions.length == before) {
      throw AppException.notFound('Money owed entry not found.');
    }
    _emit();
  }

  @override
  Future<FinanceMoneyPosition> recordMoneyPayment({
    required String positionId,
    required FinanceMoneyPayment payment,
  }) async {
    final index = _moneyPositions.indexWhere((p) => p.id == positionId);
    if (index < 0) {
      throw AppException.notFound('Money owed entry not found.');
    }
    final existing = _moneyPositions[index];
    if (!payment.amountMinor.isPositive) {
      throw AppException.validation('Payment must be greater than zero.');
    }
    if (!existing.canAcceptPayment(payment.amountMinor)) {
      throw AppException.validation(
        'Payment cannot be more than the remaining amount.',
      );
    }
    if (existing.payments.any((p) => p.id == payment.id)) {
      throw AppException.conflict('This payment was already recorded.');
    }
    final updated = existing.copyWith(
      payments: [...existing.payments, payment],
      updatedAt: DateTime.now(),
    );
    _moneyPositions[index] = updated;
    _emit();
    return updated;
  }

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
  Future<FinancePeriodReport> getPeriodReport({
    required FinancePeriod period,
    DateTime? asOf,
  }) async {
    return reportService.build(
      transactions: _transactions,
      categories: _categories,
      budgets: _budgets,
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
    _budgets.clear();
    _moneyPositions.clear();
    _categories
      ..clear()
      ..addAll(FinanceSeed.demoCategories());
    _emit();
  }

  void dispose() {
    _controller.close();
    _categoryController.close();
    _budgetController.close();
    _moneyPositionController.close();
  }
}
