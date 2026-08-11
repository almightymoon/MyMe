import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/domain/value_objects/money_minor.dart';
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

/// Local JSON persistence for finance (SharedPreferences).
///
/// Schema:
/// ```json
/// {
///   "schemaVersion": 3,
///   "baseCurrencyCode": "PKR",
///   "categories": [ /* FinanceCategory.toJson() */ ],
///   "transactions": [ /* FinanceTransaction.toJson() */ ],
///   "budgets": [ /* FinanceBudget.toJson() */ ],
///   "moneyPositions": [ /* FinanceMoneyPosition.toJson() */ ]
/// }
/// ```
///
/// Initialization flag `memy_finance_initialized_v1` ensures demo seed runs
/// only once. Deleting all transactions does not reseed.
class LocalFinanceRepository implements FinanceRepository {
  LocalFinanceRepository({
    required this.prefs,
    this.seedBuilder,
    this.categorySeedBuilder,
    this.summaryService = const FinanceSummaryService(),
    this.reportService = const FinanceReportService(),
  });

  static const int schemaVersion = 3;
  static const String storageKey = 'memy_finance_v1';
  static const String initializedKey = 'memy_finance_initialized_v1';

  final SharedPreferences prefs;
  final List<FinanceTransaction> Function()? seedBuilder;
  final List<FinanceCategory> Function()? categorySeedBuilder;
  final FinanceSummaryService summaryService;
  final FinanceReportService reportService;

  final _controller = StreamController<List<FinanceTransaction>>.broadcast();
  final _categoryController =
      StreamController<List<FinanceCategory>>.broadcast();
  final _budgetController = StreamController<List<FinanceBudget>>.broadcast();
  final _moneyPositionController =
      StreamController<List<FinanceMoneyPosition>>.broadcast();
  Future<void>? _initFuture;

  List<FinanceTransaction> _transactions = const [];
  List<FinanceCategory> _categories = const [];
  List<FinanceBudget> _budgets = const [];
  List<FinanceMoneyPosition> _moneyPositions = const [];
  String _baseCurrencyCode = FinanceSeed.baseCurrencyCode;

  String get baseCurrencyCode => _baseCurrencyCode;

  Future<void> ensureInitialized() {
    return _initFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    final initialized = prefs.getBool(initializedKey) ?? false;
    if (!initialized) {
      _categories = List<FinanceCategory>.unmodifiable(
        categorySeedBuilder?.call() ?? FinanceSeed.demoCategories(),
      );
      _transactions = List<FinanceTransaction>.unmodifiable(
        seedBuilder?.call() ?? FinanceSeed.demoTransactions(),
      );
      _budgets = const [];
      _moneyPositions = const [];
      _baseCurrencyCode = FinanceSeed.baseCurrencyCode;
      await _persist();
      await prefs.setBool(initializedKey, true);
      return;
    }

    _readFromDisk();
  }

  void _readFromDisk() {
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      _transactions = const [];
      _budgets = const [];
      _moneyPositions = const [];
      _categories = List<FinanceCategory>.unmodifiable(
        categorySeedBuilder?.call() ?? FinanceSeed.demoCategories(),
      );
      _baseCurrencyCode = FinanceSeed.baseCurrencyCode;
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        _transactions = const [];
        _categories = const [];
        _budgets = const [];
        _moneyPositions = const [];
        return;
      }
      final map = Map<String, dynamic>.from(decoded);
      final version = (map['schemaVersion'] as num?)?.toInt() ?? 0;
      if (version > schemaVersion) {
        _transactions = const [];
        _categories = const [];
        _budgets = const [];
        _moneyPositions = const [];
        return;
      }
      final currency = (map['baseCurrencyCode'] as String?)
          ?.trim()
          .toUpperCase();
      _baseCurrencyCode = (currency != null && currency.length == 3)
          ? currency
          : FinanceSeed.baseCurrencyCode;

      final catList = map['categories'];
      final categories = <FinanceCategory>[];
      if (catList is List) {
        for (final item in catList) {
          final parsed = item is Map<String, dynamic>
              ? FinanceCategory.fromJson(item)
              : item is Map
              ? FinanceCategory.fromJson(Map<String, dynamic>.from(item))
              : null;
          if (parsed != null) categories.add(parsed);
        }
      }
      _categories = List<FinanceCategory>.unmodifiable(
        categories.isEmpty
            ? (categorySeedBuilder?.call() ?? FinanceSeed.demoCategories())
            : categories,
      );

      final txList = map['transactions'];
      final transactions = <FinanceTransaction>[];
      if (txList is List) {
        for (final item in txList) {
          final parsed = item is Map<String, dynamic>
              ? FinanceTransaction.fromJson(item)
              : item is Map
              ? FinanceTransaction.fromJson(Map<String, dynamic>.from(item))
              : null;
          if (parsed != null) transactions.add(parsed);
        }
      }
      _transactions = List<FinanceTransaction>.unmodifiable(transactions);

      final budgetList = map['budgets'];
      final budgets = <FinanceBudget>[];
      if (budgetList is List) {
        for (final item in budgetList) {
          final parsed = item is Map<String, dynamic>
              ? FinanceBudget.fromJson(item)
              : item is Map
              ? FinanceBudget.fromJson(Map<String, dynamic>.from(item))
              : null;
          if (parsed != null) budgets.add(parsed);
        }
      }
      _budgets = List<FinanceBudget>.unmodifiable(budgets);

      final positionList = map['moneyPositions'];
      final positions = <FinanceMoneyPosition>[];
      if (positionList is List) {
        for (final item in positionList) {
          final parsed = item is Map<String, dynamic>
              ? FinanceMoneyPosition.fromJson(item)
              : item is Map
              ? FinanceMoneyPosition.fromJson(Map<String, dynamic>.from(item))
              : null;
          if (parsed != null) positions.add(parsed);
        }
      }
      _moneyPositions = List<FinanceMoneyPosition>.unmodifiable(positions);
    } catch (_) {
      // Corrupted document — keep initialized, return empty ledger.
      _transactions = const [];
      _budgets = const [];
      _moneyPositions = const [];
      _categories = List<FinanceCategory>.unmodifiable(
        categorySeedBuilder?.call() ?? FinanceSeed.demoCategories(),
      );
    }
  }

  Future<void> _persist() async {
    final payload = jsonEncode({
      'schemaVersion': schemaVersion,
      'baseCurrencyCode': _baseCurrencyCode,
      'categories': _categories.map((c) => c.toJson()).toList(),
      'transactions': _transactions.map((t) => t.toJson()).toList(),
      'budgets': _budgets.map((b) => b.toJson()).toList(),
      'moneyPositions': _moneyPositions.map((p) => p.toJson()).toList(),
    });
    await prefs.setString(storageKey, payload);
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
      _moneyPositionController.add(
        List.unmodifiable(_sortedPositions(_moneyPositions)),
      );
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

  List<FinanceMoneyPosition> _sortedPositions(List<FinanceMoneyPosition> list) {
    final today = LocalDate.fromDateTime(DateTime.now());
    final copy = [...list]
      ..sort((a, b) {
        final rankA = a.statusAt(today).index;
        final rankB = b.statusAt(today).index;
        if (rankA != rankB) return rankA.compareTo(rankB);
        final dueA = a.dueDate;
        final dueB = b.dueDate;
        if (dueA != null && dueB != null) {
          final dueCmp = dueA.compareTo(dueB);
          if (dueCmp != 0) return dueCmp;
        } else if (dueA != null) {
          return -1;
        } else if (dueB != null) {
          return 1;
        }
        return b.updatedAt.compareTo(a.updatedAt);
      });
    return copy;
  }

  void _assertMoneyPositionValid(
    FinanceMoneyPosition position, {
    MoneyMinor? alreadyPaid,
  }) {
    if (position.counterparty.trim().isEmpty) {
      throw AppException.validation('Who this is with is required.');
    }
    if (!position.originalAmountMinor.isPositive) {
      throw AppException.validation('Amount must be greater than zero.');
    }
    if (position.currencyCode.toUpperCase() != _baseCurrencyCode) {
      throw AppException.validation(
        'Money owed must use the base currency ($_baseCurrencyCode).',
      );
    }
    final paid = alreadyPaid ?? position.paidMinor;
    if (paid > position.originalAmountMinor) {
      throw AppException.validation(
        'Amount cannot be less than what is already paid.',
      );
    }
  }

  Future<void> _requireReady() => ensureInitialized();

  @override
  Stream<List<FinanceTransaction>> watchTransactions() async* {
    await _requireReady();
    yield List.unmodifiable(_sorted(_transactions));
    yield* _controller.stream;
  }

  @override
  Future<List<FinanceTransaction>> getTransactions() async {
    await _requireReady();
    return List.unmodifiable(_sorted(_transactions));
  }

  @override
  Future<FinanceTransaction?> getTransaction(String id) async {
    await _requireReady();
    for (final tx in _transactions) {
      if (tx.id == id) return tx;
    }
    return null;
  }

  @override
  Future<FinanceTransaction> createTransaction(
    FinanceTransaction transaction,
  ) async {
    await _requireReady();
    if (_transactions.any((t) => t.id == transaction.id)) {
      throw StateError('Transaction already exists: ${transaction.id}');
    }
    _transactions = List<FinanceTransaction>.unmodifiable([
      ..._transactions,
      transaction,
    ]);
    await _persist();
    return transaction;
  }

  @override
  Future<FinanceTransaction> updateTransaction(
    FinanceTransaction transaction,
  ) async {
    await _requireReady();
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index < 0) {
      throw StateError('Transaction not found: ${transaction.id}');
    }
    final updated = transaction.copyWith(updatedAt: DateTime.now());
    final next = [..._transactions];
    next[index] = updated;
    _transactions = List<FinanceTransaction>.unmodifiable(next);
    await _persist();
    return updated;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _requireReady();
    final next = _transactions.where((t) => t.id != id).toList();
    if (next.length == _transactions.length) {
      throw StateError('Transaction not found: $id');
    }
    _transactions = List<FinanceTransaction>.unmodifiable(next);
    await _persist();
  }

  @override
  Stream<List<FinanceCategory>> watchCategories() async* {
    await _requireReady();
    yield List.unmodifiable(_categories);
    yield* _categoryController.stream;
  }

  @override
  Future<List<FinanceCategory>> getCategories() async {
    await _requireReady();
    return List.unmodifiable(_categories);
  }

  @override
  Future<FinanceCategory> createCustomCategory(FinanceCategory category) async {
    await _requireReady();
    if (!category.isCustom) {
      throw AppException.validation('Only custom categories can be created.');
    }
    _assertUniqueCategoryName(category);
    _categories = List<FinanceCategory>.unmodifiable([
      ..._categories,
      category,
    ]);
    await _persist();
    return category;
  }

  @override
  Future<FinanceCategory> updateCustomCategory(FinanceCategory category) async {
    await _requireReady();
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index < 0) {
      throw AppException.notFound('Category not found.');
    }
    final existing = _categories[index];
    if (!existing.isCustom) {
      throw AppException.validation('Built-in categories cannot be edited.');
    }
    _assertUniqueCategoryName(category, ignoreId: category.id);
    final next = [..._categories];
    next[index] = category;
    _categories = List<FinanceCategory>.unmodifiable(next);
    await _persist();
    return category;
  }

  @override
  Future<void> archiveCategory(String id) async {
    await _requireReady();
    final index = _categories.indexWhere((c) => c.id == id);
    if (index < 0) throw AppException.notFound('Category not found.');
    final existing = _categories[index];
    final next = [..._categories];
    next[index] = FinanceCategory(
      id: existing.id,
      name: existing.name,
      type: existing.type,
      iconKey: existing.iconKey,
      isCustom: existing.isCustom,
      isArchived: true,
      createdAt: existing.createdAt,
    );
    _categories = List<FinanceCategory>.unmodifiable(next);
    await _persist();
  }

  @override
  Future<void> restoreCategory(String id) async {
    await _requireReady();
    final index = _categories.indexWhere((c) => c.id == id);
    if (index < 0) throw AppException.notFound('Category not found.');
    final existing = _categories[index];
    final next = [..._categories];
    next[index] = FinanceCategory(
      id: existing.id,
      name: existing.name,
      type: existing.type,
      iconKey: existing.iconKey,
      isCustom: existing.isCustom,
      createdAt: existing.createdAt,
    );
    _categories = List<FinanceCategory>.unmodifiable(next);
    await _persist();
  }

  void _assertUniqueCategoryName(FinanceCategory category, {String? ignoreId}) {
    final name = category.name.trim().toLowerCase();
    final clash = _categories.any(
      (c) =>
          c.id != ignoreId &&
          c.type == category.type &&
          !c.isArchived &&
          c.name.trim().toLowerCase() == name,
    );
    if (clash) {
      throw AppException.conflict(
        'A ${category.type.label.toLowerCase()} category with that name already exists.',
      );
    }
  }

  @override
  Stream<List<FinanceBudget>> watchBudgets() async* {
    await _requireReady();
    yield List.unmodifiable(_budgets);
    yield* _budgetController.stream;
  }

  @override
  Future<List<FinanceBudget>> getBudgets() async {
    await _requireReady();
    return List.unmodifiable(_budgets);
  }

  @override
  Future<List<FinanceBudget>> getBudgetsForMonth(YearMonth month) async {
    await _requireReady();
    return List.unmodifiable(
      _budgets.where((b) => !b.isArchived && b.month == month),
    );
  }

  @override
  Future<FinanceBudget?> getBudget(String id) async {
    await _requireReady();
    for (final budget in _budgets) {
      if (budget.id == id) return budget;
    }
    return null;
  }

  @override
  Future<FinanceBudget> createBudget(FinanceBudget budget) async {
    await _requireReady();
    _assertBudgetSlotFree(budget);
    if (budget.currencyCode.toUpperCase() != _baseCurrencyCode) {
      throw AppException.validation(
        'Budgets must use the base currency ($_baseCurrencyCode).',
      );
    }
    _budgets = List<FinanceBudget>.unmodifiable([..._budgets, budget]);
    await _persist();
    return budget;
  }

  @override
  Future<FinanceBudget> updateBudget(FinanceBudget budget) async {
    await _requireReady();
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index < 0) throw AppException.notFound('Budget not found.');
    _assertBudgetSlotFree(budget, ignoreId: budget.id);
    final next = [..._budgets];
    next[index] = budget;
    _budgets = List<FinanceBudget>.unmodifiable(next);
    await _persist();
    return budget;
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _requireReady();
    final next = _budgets.where((b) => b.id != id).toList();
    if (next.length == _budgets.length) {
      throw AppException.notFound('Budget not found.');
    }
    _budgets = List<FinanceBudget>.unmodifiable(next);
    await _persist();
  }

  @override
  Stream<List<FinanceMoneyPosition>> watchMoneyPositions() async* {
    await _requireReady();
    yield List.unmodifiable(_sortedPositions(_moneyPositions));
    yield* _moneyPositionController.stream;
  }

  @override
  Future<List<FinanceMoneyPosition>> getMoneyPositions() async {
    await _requireReady();
    return List.unmodifiable(_sortedPositions(_moneyPositions));
  }

  @override
  Future<FinanceMoneyPosition?> getMoneyPosition(String id) async {
    await _requireReady();
    for (final position in _moneyPositions) {
      if (position.id == id) return position;
    }
    return null;
  }

  @override
  Future<FinanceMoneyPosition> createMoneyPosition(
    FinanceMoneyPosition position,
  ) async {
    await _requireReady();
    if (_moneyPositions.any((p) => p.id == position.id)) {
      throw AppException.conflict('This money-owed row already exists.');
    }
    _assertMoneyPositionValid(position);
    _moneyPositions = List<FinanceMoneyPosition>.unmodifiable([
      ..._moneyPositions,
      position,
    ]);
    await _persist();
    return position;
  }

  @override
  Future<FinanceMoneyPosition> updateMoneyPosition(
    FinanceMoneyPosition position,
  ) async {
    await _requireReady();
    final index = _moneyPositions.indexWhere((p) => p.id == position.id);
    if (index < 0) {
      throw AppException.notFound('Money owed entry not found.');
    }
    final existing = _moneyPositions[index];
    _assertMoneyPositionValid(position, alreadyPaid: existing.paidMinor);
    final next = [..._moneyPositions];
    next[index] = position.copyWith(payments: existing.payments);
    _moneyPositions = List<FinanceMoneyPosition>.unmodifiable(next);
    await _persist();
    return next[index];
  }

  @override
  Future<void> deleteMoneyPosition(String id) async {
    await _requireReady();
    final next = _moneyPositions.where((p) => p.id != id).toList();
    if (next.length == _moneyPositions.length) {
      throw AppException.notFound('Money owed entry not found.');
    }
    _moneyPositions = List<FinanceMoneyPosition>.unmodifiable(next);
    await _persist();
  }

  @override
  Future<FinanceMoneyPosition> recordMoneyPayment({
    required String positionId,
    required FinanceMoneyPayment payment,
  }) async {
    await _requireReady();
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
    final next = [..._moneyPositions];
    next[index] = updated;
    _moneyPositions = List<FinanceMoneyPosition>.unmodifiable(next);
    await _persist();
    return updated;
  }

  void _assertBudgetSlotFree(FinanceBudget budget, {String? ignoreId}) {
    final clash = _budgets.any((existing) {
      if (existing.id == ignoreId || existing.isArchived) return false;
      if (existing.month != budget.month) return false;
      return existing.categoryId == budget.categoryId;
    });
    if (clash) {
      throw AppException.conflict(
        budget.isOverall
            ? 'An overall budget already exists for this month.'
            : 'A budget already exists for this category this month.',
      );
    }
  }

  @override
  Future<FinanceSummary> getSummary({
    required FinancePeriod period,
    DateTime? asOf,
  }) async {
    await _requireReady();
    return summaryService.summarize(
      transactions: _transactions,
      categories: _categories,
      period: period,
      currencyCode: _baseCurrencyCode,
      asOf: asOf,
    );
  }

  @override
  Future<FinancePeriodReport> getPeriodReport({
    required FinancePeriod period,
    DateTime? asOf,
  }) async {
    await _requireReady();
    return reportService.build(
      transactions: _transactions,
      categories: _categories,
      budgets: _budgets,
      period: period,
      currencyCode: _baseCurrencyCode,
      asOf: asOf,
    );
  }

  @override
  Future<void> refresh() async {
    await _requireReady();
    _readFromDisk();
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
      _moneyPositionController.add(
        List.unmodifiable(_sortedPositions(_moneyPositions)),
      );
    }
  }

  /// Wipes all local transactions and resets categories to the seed catalog.
  /// Does not reseed demo transactions.
  Future<void> clearAllLocalData() async {
    await _requireReady();
    _transactions = const [];
    _budgets = const [];
    _moneyPositions = const [];
    _categories = List<FinanceCategory>.unmodifiable(
      categorySeedBuilder?.call() ?? FinanceSeed.demoCategories(),
    );
    await _persist();
  }

  void dispose() {
    _controller.close();
    _categoryController.close();
    _budgetController.close();
    _moneyPositionController.close();
  }
}
