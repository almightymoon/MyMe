import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/fake_repository_config.dart';
import '../../../goals/application/providers/goal_providers.dart';
import '../../../goals/domain/entities/goal_enums.dart';
import '../../../goals/domain/entities/goal_summary.dart';
import '../../data/repositories/fake_today_repository.dart';
import '../../domain/entities/today_summary.dart';
import '../../domain/repositories/today_repository.dart';

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  return FakeTodayRepository(config: ref.watch(fakeRepositoryConfigProvider));
});

/// Base Today payload without goals (fake async sections).
final todayBaseProvider = FutureProvider.autoDispose<TodaySummary>((ref) async {
  return ref.watch(todayRepositoryProvider).fetchTodaySummary();
});

/// Composes Today with live active goals from [GoalRepository].
final todaySummaryProvider = Provider.autoDispose<AsyncValue<TodaySummary>>((
  ref,
) {
  final baseAsync = ref.watch(todayBaseProvider);
  final goalsAsync = ref.watch(goalsProvider);

  if (baseAsync.isLoading || goalsAsync.isLoading) {
    return const AsyncValue.loading();
  }
  if (baseAsync.hasError) {
    return AsyncValue.error(
      baseAsync.error!,
      baseAsync.stackTrace ?? StackTrace.current,
    );
  }

  final base = baseAsync.requireValue;
  final goals = goalsAsync.valueOrNull ?? const [];
  final activeSummaries = goals
      .where((g) => g.status == GoalStatus.active)
      .map(GoalSummary.fromGoal)
      .toList(growable: false);

  return AsyncValue.data(base.copyWith(goals: activeSummaries));
});
