import '../../../calendar/domain/entities/schedule_item.dart';
import '../../../coach/domain/entities/coach_suggestion.dart';
import '../../../finance/domain/entities/finance_summary.dart';
import '../../../goals/domain/entities/goal_summary.dart';
import '../../../habits/domain/entities/habit_summary.dart';
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
  final List<HabitSummary> habits;
  final FinanceSummary? finance;
  final CoachSuggestion? coachRecommendation;

  bool get hasDailyInformation =>
      focus != null ||
      schedule.isNotEmpty ||
      goals.isNotEmpty ||
      habits.isNotEmpty ||
      finance != null ||
      coachRecommendation != null;

  factory TodaySummary.empty({required String greetingName}) {
    return TodaySummary(greetingName: greetingName);
  }
}
