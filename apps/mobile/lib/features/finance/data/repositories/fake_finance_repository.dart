import '../../../../core/data/fake_repository_config.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/repositories/finance_repository.dart';
import '../seed/finance_seed.dart';

/// In-memory [FinanceRepository] for UI development and tests.
///
/// Demo only — not backed by a network or database.
class FakeFinanceRepository implements FinanceRepository {
  FakeFinanceRepository({required this.config});

  final FakeRepositoryConfig config;

  @override
  Future<FinanceSummary> fetchFinanceSummary() {
    return runFakeFetch(
      config: config,
      onData: () => FinanceSeed.demoSummary,
      onEmpty: () => FinanceSummary.empty,
    );
  }
}
