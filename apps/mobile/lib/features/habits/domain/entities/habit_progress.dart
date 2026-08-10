import '../../../../core/domain/value_objects/local_date.dart';
import 'habit.dart';
import 'habit_enums.dart';

class HabitTodayItem {
  const HabitTodayItem({
    required this.habit,
    required this.date,
    required this.isScheduled,
    required this.value,
    required this.targetValue,
    required this.isCompleted,
    required this.currentStreak,
  });

  final Habit habit;
  final LocalDate date;
  final bool isScheduled;
  final int value;
  final int targetValue;
  final bool isCompleted;
  final int currentStreak;
}

class HabitStreakSummary {
  const HabitStreakSummary({
    required this.currentStreak,
    required this.longestStreak,
    required this.isWeekStreak,
  });

  final int currentStreak;
  final int longestStreak;

  /// True when frequency is times-per-week (streak counts successful weeks).
  final bool isWeekStreak;
}

class HabitWeeklySummary {
  const HabitWeeklySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.scheduledCount,
    required this.completedCount,
    required this.completionPercent,
  });

  final LocalDate weekStart;
  final LocalDate weekEnd;
  final int scheduledCount;
  final int completedCount;

  /// Integer 0–100.
  final int completionPercent;
}

class HabitProgressSummary {
  const HabitProgressSummary({
    required this.habit,
    required this.today,
    required this.streak,
    required this.week,
  });

  final Habit habit;
  final HabitTodayItem today;
  final HabitStreakSummary streak;
  final HabitWeeklySummary week;
}

class HabitsOverviewSummary {
  const HabitsOverviewSummary({
    required this.date,
    required this.scheduledToday,
    required this.completedToday,
    required this.activeCount,
    required this.week,
    required this.bestCurrentStreak,
    required this.items,
  });

  final LocalDate date;
  final int scheduledToday;
  final int completedToday;
  final int activeCount;
  final HabitWeeklySummary week;
  final int bestCurrentStreak;
  final List<HabitTodayItem> items;
}

class HabitCheckInDraft {
  const HabitCheckInDraft({
    required this.habitId,
    required this.localDate,
    required this.value,
    this.note,
  });

  final String habitId;
  final LocalDate localDate;
  final int value;
  final String? note;
}

/// History-aware completion check — accepts the goal type/target applicable
/// on the check-in's date (from an effective-dated [HabitScheduleRevision])
/// rather than the Habit's current fields, so later schedule edits never
/// rewrite the completion outcome of past check-ins.
bool isValueCompletedFor(HabitGoalType goalType, int targetValue, int value) {
  if (value < 0) return false;
  return value >= targetValue;
}

/// History-aware normalization — see [isValueCompletedFor].
int normalizeValueFor(HabitGoalType goalType, int value) {
  if (value < 0) {
    throw ArgumentError.value(value, 'value', 'must be non-negative');
  }
  if (goalType == HabitGoalType.binary) {
    return value >= 1 ? 1 : 0;
  }
  return value;
}

bool isHabitValueCompleted(Habit habit, int value) {
  return isValueCompletedFor(habit.goalType, habit.targetValue, value);
}

int normalizedCheckInValue(Habit habit, int value) {
  return normalizeValueFor(habit.goalType, value);
}
