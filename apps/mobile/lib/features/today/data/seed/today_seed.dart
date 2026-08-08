import '../../../calendar/data/seed/calendar_seed.dart';
import '../../../coach/data/seed/coach_seed.dart';
import '../../../finance/data/seed/finance_seed.dart';
import '../../../goals/data/seed/goals_seed.dart';
import '../../../habits/data/seed/habits_seed.dart';
import '../../../user/data/seed/user_seed.dart';
import '../../domain/entities/daily_focus.dart';
import '../../domain/entities/today_summary.dart';

/// Assembles Today demo data from feature seeds.
abstract final class TodaySeed {
  static const DailyFocus demoFocus = DailyFocus(
    title: 'Finish AI Research Paper',
    progressPercent: 55,
    subtitle: 'Protect your afternoon focus block',
  );

  static TodaySummary populated() {
    return TodaySummary(
      greetingName: UserSeed.demoProfile.displayName,
      focus: demoFocus,
      schedule: CalendarSeed.demoAgenda.take(2).toList(growable: false),
      goals: [GoalsSeed.featured],
      habits: HabitsSeed.demoHabits.take(2).toList(growable: false),
      finance: FinanceSeed.demoSummary,
      coachRecommendation: CoachSeed.dailyRecommendation,
    );
  }

  static TodaySummary empty() {
    return TodaySummary.empty(greetingName: UserSeed.demoProfile.displayName);
  }
}
