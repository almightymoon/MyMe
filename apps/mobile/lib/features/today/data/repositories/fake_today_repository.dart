import '../../../../core/data/fake_repository_config.dart';
import '../../domain/entities/today_summary.dart';
import '../../domain/repositories/today_repository.dart';
import '../seed/today_seed.dart';

/// In-memory [TodayRepository] for UI development and tests.
///
/// Demo only — not backed by a network or database.
class FakeTodayRepository implements TodayRepository {
  FakeTodayRepository({required this.config});

  final FakeRepositoryConfig config;

  @override
  Future<TodaySummary> fetchTodaySummary() {
    return runFakeFetch(
      config: config,
      onData: TodaySeed.populated,
      onEmpty: TodaySeed.empty,
    );
  }
}
