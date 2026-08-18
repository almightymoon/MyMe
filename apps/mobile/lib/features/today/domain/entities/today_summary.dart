import '../../../calendar/domain/entities/schedule_item.dart';
import '../../../coach/domain/entities/coach_suggestion.dart';
import '../../../finance/domain/entities/finance_summary.dart';
import '../../../goals/domain/entities/goal_summary.dart';
import '../../../habits/domain/entities/habit_progress.dart';
import 'daily_focus.dart';

class TodaySummary {
  const TodaySummary({
    required this.greetingName,
    this.focus,
    this.schedule = const [],
    this.goals = const [],
    this.habits = const [],
    this.finance,
    this.coachRecommendation,
  });

  final String greetingName;
  final DailyFocus? focus;
  final List<ScheduleItem> schedule;
  final List<GoalSummary> goals;

  /// Scheduled Habit rows for the current local day (live from HabitRepository).
  final List<HabitTodayItem> habits;
  final FinanceSummary? finance;
  final CoachSuggestion? coachRecommendation;

  bool get hasDailyInformation =>
      focus != null ||
      schedule.isNotEmpty ||
      goals.isNotEmpty ||
      habits.isNotEmpty ||
      finance != null ||
      coachRecommendation != null;

  /// Average of live goal and habit progress. Never a scripted demo figure.
  int get computedLifeScore {
    final percents = <double>[
      for (final goal in goals) goal.progressPercent.clamp(0, 100),
      for (final habit in habits) habit.completionPercent,
    ];
    if (percents.isEmpty) return 0;
    return (percents.reduce((a, b) => a + b) / percents.length).round();
  }

  /// Seeded demo focus when present; otherwise the first live goal or habit.
  DailyFocus? get effectiveFocus {
    if (focus != null) return focus;
    if (goals.isNotEmpty) {
      final goal = goals.first;
      return DailyFocus(
        title: goal.title,
        progressPercent: goal.progressPercent,
      );
    }
    if (habits.isNotEmpty) {
      final habit = habits.first;
      return DailyFocus(
        title: habit.habit.name,
        progressPercent: habit.completionPercent,
      );
    }
    return null;
  }

  factory TodaySummary.empty({required String greetingName}) {
    return TodaySummary(greetingName: greetingName);
  }

  TodaySummary copyWith({
    String? greetingName,
    DailyFocus? focus,
    List<ScheduleItem>? schedule,
    List<GoalSummary>? goals,
    List<HabitTodayItem>? habits,
    FinanceSummary? finance,
    CoachSuggestion? coachRecommendation,
  }) {
    return TodaySummary(
      greetingName: greetingName ?? this.greetingName,
      focus: focus ?? this.focus,
      schedule: schedule ?? this.schedule,
      goals: goals ?? this.goals,
      habits: habits ?? this.habits,
      finance: finance ?? this.finance,
      coachRecommendation: coachRecommendation ?? this.coachRecommendation,
    );
  }
}
