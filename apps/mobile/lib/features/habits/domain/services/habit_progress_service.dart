import '../../../../core/domain/value_objects/local_date.dart';
import '../entities/habit.dart';
import '../entities/habit_check_in.dart';
import '../entities/habit_enums.dart';
import '../entities/habit_history.dart';
import '../entities/habit_progress.dart';
import 'habit_schedule_service.dart';

/// Pure completion and streak calculations.
///
/// Streak semantics:
/// - Daily / selected weekdays: consecutive completed **scheduled** dates.
/// - An incomplete **current** day does not break the streak until the day ends.
/// - Times-per-week: consecutive successful **calendar weeks** (Monday start).
///   An incomplete current week does not break the streak until the week ends.
///
/// History awareness: every method accepts optional [revisions] /
/// [statusPeriods] (default `const []`), forwarded to [HabitScheduleService]
/// so scheduling/target resolution is effective-dated. Completion itself is
/// never recomputed from history — each [HabitCheckIn.isCompleted] flag is
/// fixed at write time against the schedule/target applicable on that
/// check-in's date, so later edits cannot rewrite past outcomes.
class HabitProgressService {
  HabitProgressService({
    HabitScheduleService scheduleService = const HabitScheduleService(),
  }) : _schedule = scheduleService;

  final HabitScheduleService _schedule;

  HabitScheduleService get scheduleService => _schedule;

  HabitCheckIn? checkInForDate(
    List<HabitCheckIn> checkIns,
    String habitId,
    LocalDate date,
  ) {
    for (final c in checkIns) {
      if (c.habitId == habitId && c.localDate == date) return c;
    }
    return null;
  }

  bool isCompletedOn(Habit habit, List<HabitCheckIn> checkIns, LocalDate date) {
    final c = checkInForDate(checkIns, habit.id, date);
    return c?.isCompleted == true;
  }

  int valueOn(Habit habit, List<HabitCheckIn> checkIns, LocalDate date) {
    return checkInForDate(checkIns, habit.id, date)?.value ?? 0;
  }

  HabitTodayItem todayItem({
    required Habit habit,
    required List<HabitCheckIn> checkIns,
    required LocalDate date,
    required LocalDate today,
    List<HabitScheduleRevision> revisions = const [],
    List<HabitStatusPeriod> statusPeriods = const [],
  }) {
    final scheduled = _schedule.isScheduledOn(
      habit,
      date,
      revisions: revisions,
      statusPeriods: statusPeriods,
    );
    final value = valueOn(habit, checkIns, date);
    final targetValue = _schedule.fieldsOn(habit, revisions, date).targetValue;
    final streak = streakSummary(
      habit: habit,
      checkIns: checkIns,
      today: today,
      revisions: revisions,
      statusPeriods: statusPeriods,
    );
    return HabitTodayItem(
      habit: habit,
      date: date,
      isScheduled: scheduled,
      value: value,
      targetValue: targetValue,
      isCompleted: isCompletedOn(habit, checkIns, date),
      currentStreak: streak.currentStreak,
    );
  }

  HabitWeeklySummary weeklySummary({
    required Habit habit,
    required List<HabitCheckIn> checkIns,
    required LocalDate anyDayInWeek,
    List<HabitScheduleRevision> revisions = const [],
    List<HabitStatusPeriod> statusPeriods = const [],
  }) {
    final weekStart = anyDayInWeek.startOfWeek();
    final weekEnd = weekStart.addDays(6);
    final scheduledDates = _schedule.scheduledDatesInRange(
      habit,
      weekStart,
      weekEnd,
      revisions: revisions,
      statusPeriods: statusPeriods,
    );

    final fields = _schedule.fieldsOn(habit, revisions, anyDayInWeek);
    int scheduledCount;
    int completedCount;

    if (fields.frequencyType == HabitFrequencyType.timesPerWeek) {
      scheduledCount = _schedule.scheduledCountInWeek(
        habit,
        anyDayInWeek,
        revisions: revisions,
        statusPeriods: statusPeriods,
      );
      completedCount = scheduledDates
          .where((d) => isCompletedOn(habit, checkIns, d))
          .length;
      if (completedCount > scheduledCount) {
        completedCount = scheduledCount;
      }
    } else {
      scheduledCount = scheduledDates.length;
      completedCount = scheduledDates
          .where((d) => isCompletedOn(habit, checkIns, d))
          .length;
    }

    final percent = scheduledCount == 0
        ? 0
        : ((completedCount * 100) / scheduledCount).floor().clamp(0, 100);

    return HabitWeeklySummary(
      weekStart: weekStart,
      weekEnd: weekEnd,
      scheduledCount: scheduledCount,
      completedCount: completedCount,
      completionPercent: percent,
    );
  }

  HabitStreakSummary streakSummary({
    required Habit habit,
    required List<HabitCheckIn> checkIns,
    required LocalDate today,
    List<HabitScheduleRevision> revisions = const [],
    List<HabitStatusPeriod> statusPeriods = const [],
  }) {
    final fields = _schedule.fieldsOn(habit, revisions, today);
    if (fields.frequencyType == HabitFrequencyType.timesPerWeek) {
      return _weekStreak(
        habit: habit,
        checkIns: checkIns,
        today: today,
        revisions: revisions,
        statusPeriods: statusPeriods,
      );
    }
    return _occurrenceStreak(
      habit: habit,
      checkIns: checkIns,
      today: today,
      revisions: revisions,
      statusPeriods: statusPeriods,
    );
  }

  HabitStreakSummary _occurrenceStreak({
    required Habit habit,
    required List<HabitCheckIn> checkIns,
    required LocalDate today,
    required List<HabitScheduleRevision> revisions,
    required List<HabitStatusPeriod> statusPeriods,
  }) {
    final start = habit.startDate;
    if (today.isBefore(start)) {
      return const HabitStreakSummary(
        currentStreak: 0,
        longestStreak: 0,
        isWeekStreak: false,
      );
    }

    // Build chronological list of scheduled dates from start through today.
    // Paused/archived periods covering a date exclude it here too, so a
    // pause mid-streak correctly breaks/excludes those days from the run.
    final dates = _schedule.scheduledDatesInRange(
      habit,
      start,
      today,
      revisions: revisions,
      statusPeriods: statusPeriods,
    );
    if (dates.isEmpty) {
      return const HabitStreakSummary(
        currentStreak: 0,
        longestStreak: 0,
        isWeekStreak: false,
      );
    }

    var longest = 0;
    var run = 0;
    for (final date in dates) {
      final completed = isCompletedOn(habit, checkIns, date);
      final isToday = date == today;
      if (completed) {
        run += 1;
        if (run > longest) longest = run;
      } else if (isToday) {
        // Incomplete current day does not break prior streak.
        break;
      } else {
        run = 0;
      }
    }

    // Current streak: walk backwards from today.
    var current = 0;
    for (var i = dates.length - 1; i >= 0; i--) {
      final date = dates[i];
      if (date == today && !isCompletedOn(habit, checkIns, date)) {
        continue;
      }
      if (isCompletedOn(habit, checkIns, date)) {
        current += 1;
      } else {
        break;
      }
    }

    if (current > longest) longest = current;

    return HabitStreakSummary(
      currentStreak: current,
      longestStreak: longest,
      isWeekStreak: false,
    );
  }

  HabitStreakSummary _weekStreak({
    required Habit habit,
    required List<HabitCheckIn> checkIns,
    required LocalDate today,
    required List<HabitScheduleRevision> revisions,
    required List<HabitStatusPeriod> statusPeriods,
  }) {
    final startWeek = habit.startDate.startOfWeek();
    final currentWeek = today.startOfWeek();
    if (currentWeek.isBefore(startWeek)) {
      return const HabitStreakSummary(
        currentStreak: 0,
        longestStreak: 0,
        isWeekStreak: true,
      );
    }

    final weeks = <LocalDate>[];
    var cursor = startWeek;
    while (!cursor.isAfter(currentWeek)) {
      weeks.add(cursor);
      cursor = cursor.addDays(7);
    }

    bool weekSuccess(LocalDate weekStart) {
      final summary = weeklySummary(
        habit: habit,
        checkIns: checkIns,
        anyDayInWeek: weekStart,
        revisions: revisions,
        statusPeriods: statusPeriods,
      );
      final needed =
          _schedule.fieldsOn(habit, revisions, weekStart).timesPerWeek ?? 1;
      return summary.completedCount >= needed;
    }

    var longest = 0;
    var run = 0;
    for (final week in weeks) {
      final isCurrent = week == currentWeek;
      if (weekSuccess(week)) {
        run += 1;
        if (run > longest) longest = run;
      } else if (isCurrent) {
        break;
      } else {
        run = 0;
      }
    }

    var current = 0;
    for (var i = weeks.length - 1; i >= 0; i--) {
      final week = weeks[i];
      if (week == currentWeek && !weekSuccess(week)) {
        continue;
      }
      if (weekSuccess(week)) {
        current += 1;
      } else {
        break;
      }
    }
    if (current > longest) longest = current;

    return HabitStreakSummary(
      currentStreak: current,
      longestStreak: longest,
      isWeekStreak: true,
    );
  }

  HabitProgressSummary progressFor({
    required Habit habit,
    required List<HabitCheckIn> checkIns,
    required LocalDate today,
    List<HabitScheduleRevision> revisions = const [],
    List<HabitStatusPeriod> statusPeriods = const [],
  }) {
    return HabitProgressSummary(
      habit: habit,
      today: todayItem(
        habit: habit,
        checkIns: checkIns,
        date: today,
        today: today,
        revisions: revisions,
        statusPeriods: statusPeriods,
      ),
      streak: streakSummary(
        habit: habit,
        checkIns: checkIns,
        today: today,
        revisions: revisions,
        statusPeriods: statusPeriods,
      ),
      week: weeklySummary(
        habit: habit,
        checkIns: checkIns,
        anyDayInWeek: today,
        revisions: revisions,
        statusPeriods: statusPeriods,
      ),
    );
  }

  HabitsOverviewSummary overview({
    required List<Habit> habits,
    required List<HabitCheckIn> checkIns,
    required LocalDate date,
    Map<String, List<HabitScheduleRevision>> revisionsByHabitId = const {},
    Map<String, List<HabitStatusPeriod>> statusPeriodsByHabitId = const {},
  }) {
    // Status effective on [date] (not necessarily the Habit's current
    // status) so browsing a past date still reflects who was active then.
    final active = habits.where((h) {
      final periods = statusPeriodsByHabitId[h.id] ?? const [];
      return _schedule.statusOn(h, periods, date) == HabitStatus.active;
    }).toList();
    final items = <HabitTodayItem>[];
    for (final habit in active) {
      final revisions = revisionsByHabitId[habit.id] ?? const [];
      final periods = statusPeriodsByHabitId[habit.id] ?? const [];
      if (!_schedule.isScheduledOn(
        habit,
        date,
        revisions: revisions,
        statusPeriods: periods,
      )) {
        continue;
      }
      items.add(
        todayItem(
          habit: habit,
          checkIns: checkIns,
          date: date,
          today: date,
          revisions: revisions,
          statusPeriods: periods,
        ),
      );
    }

    final scheduledToday = items.length;
    final completedToday = items.where((i) => i.isCompleted).length;
    var bestStreak = 0;
    var weekScheduled = 0;
    var weekCompleted = 0;
    for (final habit in active) {
      final revisions = revisionsByHabitId[habit.id] ?? const [];
      final periods = statusPeriodsByHabitId[habit.id] ?? const [];
      final streak = streakSummary(
        habit: habit,
        checkIns: checkIns,
        today: date,
        revisions: revisions,
        statusPeriods: periods,
      );
      if (streak.currentStreak > bestStreak) {
        bestStreak = streak.currentStreak;
      }
      final week = weeklySummary(
        habit: habit,
        checkIns: checkIns,
        anyDayInWeek: date,
        revisions: revisions,
        statusPeriods: periods,
      );
      weekScheduled += week.scheduledCount;
      weekCompleted += week.completedCount;
    }

    final weekPercent = weekScheduled == 0
        ? 0
        : ((weekCompleted * 100) / weekScheduled).floor().clamp(0, 100);

    return HabitsOverviewSummary(
      date: date,
      scheduledToday: scheduledToday,
      completedToday: completedToday,
      activeCount: active.length,
      week: HabitWeeklySummary(
        weekStart: date.startOfWeek(),
        weekEnd: date.startOfWeek().addDays(6),
        scheduledCount: weekScheduled,
        completedCount: weekCompleted,
        completionPercent: weekPercent,
      ),
      bestCurrentStreak: bestStreak,
      items: items,
    );
  }
}
