import '../../../../core/data/fake_repository_config.dart';
import '../../domain/entities/goal_summary.dart';
import '../../domain/repositories/goal_repository.dart';
import '../seed/goals_seed.dart';

/// In-memory [GoalRepository] for UI development and tests.
///
/// Demo only — not backed by a network or database.
class FakeGoalRepository implements GoalRepository {
  FakeGoalRepository({required this.config});

  final FakeRepositoryConfig config;

  @override
  Future<List<GoalSummary>> fetchGoals() {
    return runFakeFetch(
      config: config,
      onData: () => List<GoalSummary>.unmodifiable(GoalsSeed.demoGoals),
      onEmpty: () => const <GoalSummary>[],
    );
  }
}
