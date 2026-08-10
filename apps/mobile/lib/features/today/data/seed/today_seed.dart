import '../../../calendar/data/seed/calendar_seed.dart';
import '../../../coach/data/seed/coach_seed.dart';
import '../../../user/data/seed/user_seed.dart';
import '../../domain/entities/daily_focus.dart';
import '../../domain/entities/today_summary.dart';

/// Assembles Today demo data from feature seeds.
///
/// Goals are injected by [todaySummaryProvider] from [GoalRepository].
/// Finance is injected from [FinanceRepository] via [todayFinanceSummaryProvider].
/// Habits are injected from [HabitRepository] via [todayHabitsProvider].
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
      // Home glance matches prototype: Team Meeting + Gym Workout.
      schedule: [CalendarSeed.demoAgenda[0], CalendarSeed.demoAgenda[2]],
      goals: const [],
      habits: const [],
      finance: null,
      coachRecommendation: CoachSeed.dailyRecommendation,
    );
  }

  static TodaySummary empty() {
    return TodaySummary.empty(greetingName: UserSeed.demoProfile.displayName);
  }
}
