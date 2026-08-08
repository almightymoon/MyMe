import '../entities/habit_summary.dart';

abstract class HabitRepository {
  Future<List<HabitSummary>> fetchHabits();
}
