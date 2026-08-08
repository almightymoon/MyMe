import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/fake_repository_config.dart';
import '../../data/repositories/fake_goal_repository.dart';
import '../../domain/entities/goal_summary.dart';
import '../../domain/repositories/goal_repository.dart';

final goalRepositoryProvider = Provider<GoalRepository>((ref) {
  return FakeGoalRepository(config: ref.watch(fakeRepositoryConfigProvider));
});

final goalsProvider = FutureProvider.autoDispose<List<GoalSummary>>((
  ref,
) async {
  return ref.watch(goalRepositoryProvider).fetchGoals();
});
