import '../entities/goal_summary.dart';

abstract class GoalRepository {
  Future<List<GoalSummary>> fetchGoals();
}
