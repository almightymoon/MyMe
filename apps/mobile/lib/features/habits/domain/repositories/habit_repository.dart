import '../../../../core/domain/value_objects/local_date.dart';
import '../entities/habit.dart';
import '../entities/habit_check_in.dart';
import '../entities/habit_history.dart';
import '../entities/habit_progress.dart';

abstract class HabitRepository {
  Stream<List<Habit>> watchHabits();
  Future<List<Habit>> getHabits();
  Future<Habit?> getHabit(String id);
  Future<Habit> createHabit(Habit habit);
  Future<Habit> updateHabit(Habit habit);
  Future<Habit> pauseHabit(String id);
  Future<Habit> resumeHabit(String id);
  Future<Habit> archiveHabit(String id);
  Future<Habit> restoreHabit(String id);
  Future<void> deleteHabit(String id);

  /// Effective-dated schedule/target history for [habitId], oldest first.
  Future<List<HabitScheduleRevision>> getScheduleRevisions(String habitId);

  /// Pause/active/archive status history for [habitId], oldest first.
  Future<List<HabitStatusPeriod>> getStatusPeriods(String habitId);

  Stream<List<HabitCheckIn>> watchCheckIns();
  Future<List<HabitCheckIn>> getCheckInsForHabit(String habitId);
  Future<List<HabitCheckIn>> getCheckInsForRange({
    required LocalDate start,
    required LocalDate endInclusive,
  });
  Future<HabitCheckIn> upsertCheckIn(HabitCheckInDraft draft);
  Future<void> removeCheckIn({
    required String habitId,
    required LocalDate localDate,
  });

  Future<List<HabitTodayItem>> getTodayItems(LocalDate date);
  Future<HabitsOverviewSummary> getOverview(LocalDate date);
  Future<void> refresh();
}
