import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/local_goal_repository.dart';
import '../../domain/entities/goal.dart';
import '../../domain/entities/goal_enums.dart';
import '../../domain/entities/goal_forecast.dart';
import '../../domain/entities/goal_summary.dart';
import '../../domain/repositories/goal_repository.dart';
import '../../domain/services/goal_forecast_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in bootstrap/tests',
  );
});

final uuidProvider = Provider<Uuid>((ref) => const Uuid());

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  final repo = LocalGoalRepository(prefs: ref.watch(sharedPreferencesProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

final goalForecastServiceProvider = Provider<GoalForecastService>((ref) {
  return const GoalForecastService();
});

/// Live list of all goals (reactive).
final goalsProvider = StreamProvider.autoDispose<List<Goal>>((ref) {
  return ref.watch(goalRepositoryProvider).watchGoals();
});

final goalSummariesProvider =
    Provider.autoDispose<AsyncValue<List<GoalSummary>>>((ref) {
      return ref
          .watch(goalsProvider)
          .whenData(
            (goals) => goals.map(GoalSummary.fromGoal).toList(growable: false),
          );
    });

final activeGoalsProvider = Provider.autoDispose<AsyncValue<List<Goal>>>((ref) {
  return ref
      .watch(goalsProvider)
      .whenData(
        (goals) => goals
            .where((g) => g.status == GoalStatus.active)
            .toList(growable: false),
      );
});

final goalByIdProvider = StreamProvider.autoDispose.family<Goal?, String>((
  ref,
  id,
) async* {
  final repo = ref.watch(goalRepositoryProvider);
  yield await repo.getGoal(id);
  await for (final goals in repo.watchGoals()) {
    Goal? match;
    for (final goal in goals) {
      if (goal.id == id) {
        match = goal;
        break;
      }
    }
    yield match;
  }
});

final goalForecastProvider = Provider.autoDispose.family<GoalForecast?, String>(
  (ref, id) {
    final goal = ref.watch(goalByIdProvider(id)).valueOrNull;
    if (goal == null) return null;
    return ref.watch(goalForecastServiceProvider).forecast(goal);
  },
);

final goalsFilterProvider = StateProvider.autoDispose<GoalsListFilter>((ref) {
  return GoalsListFilter.all;
});

enum GoalsListFilter { all, active, completed, archived }

final filteredGoalsProvider = Provider.autoDispose<AsyncValue<List<Goal>>>((
  ref,
) {
  final filter = ref.watch(goalsFilterProvider);
  return ref.watch(goalsProvider).whenData((goals) {
    switch (filter) {
      case GoalsListFilter.all:
        return goals;
      case GoalsListFilter.active:
        return goals.where((g) => g.status == GoalStatus.active).toList();
      case GoalsListFilter.completed:
        return goals.where((g) => g.status == GoalStatus.completed).toList();
      case GoalsListFilter.archived:
        return goals.where((g) => g.status == GoalStatus.archived).toList();
    }
  });
});

final averageActiveProgressProvider = Provider.autoDispose<double>((ref) {
  final active = ref.watch(activeGoalsProvider).valueOrNull ?? const [];
  if (active.isEmpty) return 0;
  final sum = active.fold<double>(0, (acc, g) => acc + g.progressPercent);
  return sum / active.length;
});
