import '../entities/finance_summary.dart';

abstract class FinanceRepository {
  Future<FinanceSummary> fetchFinanceSummary();
}
