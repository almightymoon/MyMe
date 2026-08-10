import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/fake_repository_config.dart';
import '../../../calendar/application/providers/calendar_providers.dart';
import '../../../calendar/data/mappers/schedule_item_mapper.dart';
import '../../../calendar/domain/entities/schedule_item.dart';
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

/// Base Today payload without goals/finance/habits/calendar (fake async
/// section — focus, greeting, coach recommendation).
final todayBaseProvider = FutureProvider.autoDispose<TodaySummary>((ref) async {
  return ref.watch(todayRepositoryProvider).fetchTodaySummary();
});

/// Live Habit rows for Today. Habit failures surface here without wiping
/// Goals/Finance content on the composed summary.
final todayHabitsProvider =
    Provider.autoDispose<AsyncValue<List<HabitTodayItem>>>((ref) {
      return ref.watch(todayHabitItemsProvider);
    });

/// Today's day range, expressed the same way [CalendarSeed] anchors demo
/// events: local wall-clock year/month/day reinterpreted as a UTC date, so
/// "today" lines up for both querying and seeding without a timezone-driven
/// off-by-one near local midnight vs UTC midnight.
final todayCalendarRangeProvider = Provider.autoDispose<CalendarDateRange>((
  ref,
) {
  final now = ref.watch(appClockProvider).now();
  final startOfDay = DateTime.utc(now.year, now.month, now.day);
  return CalendarDateRange(
    startUtc: startOfDay,
    endUtc: startOfDay.add(const Duration(days: 1)),
  );
});

/// Live calendar events for today, mapped to the Today glance DTO. A
/// calendar failure surfaces here only — it must never wipe out
/// goals/finance/habits on the composed [todaySummaryProvider].
final todayCalendarEventsProvider =
    Provider.autoDispose<AsyncValue<List<ScheduleItem>>>((ref) {
      final range = ref.watch(todayCalendarRangeProvider);
      final async = ref.watch(calendarEventsInRangeProvider(range));
      return async.whenData(ScheduleItemMapper.fromMemyEvents);
    });

/// Composes Today with live active goals, finance, scheduled habits, and
/// today's calendar agenda. Each section fails independently: a broken
/// section falls back to empty rather than failing the whole screen.
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

  // Habits and Calendar are optional; failures do not fail the whole Today.
  final habitItems = ref.watch(todayHabitsProvider).valueOrNull ?? const [];
  final schedule =
      ref.watch(todayCalendarEventsProvider).valueOrNull ?? const [];

  return AsyncValue.data(
    base.copyWith(
      goals: activeSummaries,
      finance: finance,
      habits: habitItems,
      schedule: schedule,
    ),
  );
});
