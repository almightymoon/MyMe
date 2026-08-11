import '../../../../core/domain/value_objects/year_month.dart';
import '../entities/finance_budget.dart';
import '../entities/finance_category.dart';
import '../entities/finance_enums.dart';
import '../entities/finance_money_position.dart';
import '../entities/finance_period_report.dart';
import '../entities/finance_summary.dart';
import '../entities/finance_transaction.dart';

/// Pluggable Finance persistence (fake / local now; API later).
abstract class FinanceRepository {
  Stream<List<FinanceTransaction>> watchTransactions();

  Future<List<FinanceTransaction>> getTransactions();

  Future<FinanceTransaction?> getTransaction(String id);

  Future<FinanceTransaction> createTransaction(FinanceTransaction transaction);

  Future<FinanceTransaction> updateTransaction(FinanceTransaction transaction);

  Future<void> deleteTransaction(String id);

  Stream<List<FinanceCategory>> watchCategories();

  Future<List<FinanceCategory>> getCategories();

  Future<FinanceCategory> createCustomCategory(FinanceCategory category);

  Future<FinanceCategory> updateCustomCategory(FinanceCategory category);

  Future<void> archiveCategory(String id);

  Future<void> restoreCategory(String id);

  Stream<List<FinanceBudget>> watchBudgets();

  Future<List<FinanceBudget>> getBudgets();

  Future<List<FinanceBudget>> getBudgetsForMonth(YearMonth month);

  Future<FinanceBudget?> getBudget(String id);

  Future<FinanceBudget> createBudget(FinanceBudget budget);

  Future<FinanceBudget> updateBudget(FinanceBudget budget);

  Future<void> deleteBudget(String id);

  Stream<List<FinanceMoneyPosition>> watchMoneyPositions();

  Future<List<FinanceMoneyPosition>> getMoneyPositions();

  Future<FinanceMoneyPosition?> getMoneyPosition(String id);

  Future<FinanceMoneyPosition> createMoneyPosition(
    FinanceMoneyPosition position,
  );

  Future<FinanceMoneyPosition> updateMoneyPosition(
    FinanceMoneyPosition position,
  );

  Future<void> deleteMoneyPosition(String id);

  Future<FinanceMoneyPosition> recordMoneyPayment({
    required String positionId,
    required FinanceMoneyPayment payment,
  });

  Future<FinanceSummary> getSummary({
    required FinancePeriod period,
    DateTime? asOf,
  });

  Future<FinancePeriodReport> getPeriodReport({
    required FinancePeriod period,
    DateTime? asOf,
  });

  Future<void> refresh();
}
