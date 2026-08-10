import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/fake_repository_config.dart';
import '../../../finance/application/providers/finance_providers.dart';
import '../../../goals/application/providers/goal_providers.dart';
import '../../../goals/domain/entities/goal_enums.dart';
import '../../../goals/domain/entities/goal_summary.dart';
import '../../../habits/application/providers/habit_providers.dart';
import '../../../habits/domain/entities/habit_progress.dart';
import '../../data/repositories/fake_today_repository.dart';
import '../../domain/entities/today_summary.dart';
import '../../domain/repositories/today_repository.dart';

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  return FakeTodayRepository(config: ref.watch(fakeRepositoryConfigProvider));
});

/// Base Today payload without goals/finance/habits (fake async sections).
final todayBaseProvider = FutureProvider.autoDispose<TodaySummary>((ref) async {
  return ref.watch(todayRepositoryProvider).fetchTodaySummary();
});

/// Live Habit rows for Today. Habit failures surface here without wiping
/// Goals/Finance content on the composed summary.
final todayHabitsProvider =
    Provider.autoDispose<AsyncValue<List<HabitTodayItem>>>((ref) {
      return ref.watch(todayHabitItemsProvider);
    });

/// Composes Today with live active goals, finance, and scheduled habits.
final todaySummaryProvider = Provider.autoDispose<AsyncValue<TodaySummary>>((
  ref,
) {
  final baseAsync = ref.watch(todayBaseProvider);
  final goalsAsync = ref.watch(goalsProvider);
  final financeAsync = ref.watch(todayFinanceSummaryProvider);

  if (baseAsync.isLoading || goalsAsync.isLoading || financeAsync.isLoading) {
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

  final txs = ref.watch(financeTransactionsProvider).valueOrNull ?? const [];
  final finance = txs.isEmpty ? null : financeAsync.valueOrNull;

  // Habits are optional for emptiness; failures do not fail the whole Today.
  final habitItems = ref.watch(todayHabitsProvider).valueOrNull ?? const [];

  return AsyncValue.data(
    base.copyWith(goals: activeSummaries, finance: finance, habits: habitItems),
  );
});
