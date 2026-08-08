import '../../../../core/data/fake_repository_config.dart';
import '../../domain/entities/habit_summary.dart';
import '../../domain/repositories/habit_repository.dart';
import '../seed/habits_seed.dart';

/// In-memory [HabitRepository] for UI development and tests.
///
/// Demo only — not backed by a network or database.
class FakeHabitRepository implements HabitRepository {
  FakeHabitRepository({required this.config});

  final FakeRepositoryConfig config;

  @override
  Future<List<HabitSummary>> fetchHabits() {
    return runFakeFetch(
      config: config,
      onData: () => List<HabitSummary>.unmodifiable(HabitsSeed.demoHabits),
      onEmpty: () => const <HabitSummary>[],
    );
  }
}
