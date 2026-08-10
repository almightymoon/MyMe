import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/finance_category.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/entities/finance_transaction.dart';
import '../../domain/repositories/finance_repository.dart';
import '../../domain/services/finance_summary_service.dart';
import '../seed/finance_seed.dart';

/// Local JSON persistence for finance (SharedPreferences).
///
/// Schema:
/// ```json
/// {
///   "schemaVersion": 1,
///   "baseCurrencyCode": "PKR",
///   "categories": [ /* FinanceCategory.toJson() */ ],
///   "transactions": [ /* FinanceTransaction.toJson() */ ]
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
  });

  static const int schemaVersion = 1;
  static const String storageKey = 'memy_finance_v1';
  static const String initializedKey = 'memy_finance_initialized_v1';

  final SharedPreferences prefs;
  final List<FinanceTransaction> Function()? seedBuilder;
  final List<FinanceCategory> Function()? categorySeedBuilder;
  final FinanceSummaryService summaryService;

  final _controller = StreamController<List<FinanceTransaction>>.broadcast();
  Future<void>? _initFuture;

  List<FinanceTransaction> _transactions = const [];
  List<FinanceCategory> _categories = const [];
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
        return;
      }
      final map = Map<String, dynamic>.from(decoded);
      final version = (map['schemaVersion'] as num?)?.toInt() ?? 0;
      if (version != schemaVersion && version != 0) {
        // Future migrations can branch here; unknown versions → empty-safe.
        _transactions = const [];
        _categories = const [];
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
    } catch (_) {
      // Corrupted document — keep initialized, return empty ledger.
      _transactions = const [];
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
    });
    await prefs.setString(storageKey, payload);
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
  Future<List<FinanceCategory>> getCategories() async {
    await _requireReady();
    return List.unmodifiable(_categories);
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
  Future<void> refresh() async {
    await _requireReady();
    _readFromDisk();
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_sorted(_transactions)));
    }
  }

  /// Wipes all local transactions and resets categories to the seed catalog.
  /// Does not reseed demo transactions.
  Future<void> clearAllLocalData() async {
    await _requireReady();
    _transactions = const [];
    _categories = List<FinanceCategory>.unmodifiable(
      categorySeedBuilder?.call() ?? FinanceSeed.demoCategories(),
    );
    await _persist();
  }

  void dispose() {
    _controller.close();
  }
}
