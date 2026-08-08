import '../services/money_format.dart';
import '../value_objects/money_minor.dart';
import 'goal.dart';
import 'goal_enums.dart';

class GoalSummary {
  const GoalSummary({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progressPercent,
    this.status = 'active',
  });

  final String id;
  final String title;
  final String subtitle;
  final double progressPercent;
  final String status;

  factory GoalSummary.fromGoal(Goal goal) {
    return GoalSummary(
      id: goal.id,
      title: goal.name,
      subtitle: _subtitleFor(goal),
      progressPercent: goal.progressPercent,
      status: goal.status.name,
    );
  }

  static String _subtitleFor(Goal goal) {
    if (goal.targetAmountMinor != null && goal.currencyCode != null) {
      final current = goal.currentAmountMinor ?? MoneyMinor.zero;
      return '${MoneyFormat.formatMinor(current, goal.currencyCode!)} of '
          '${MoneyFormat.formatMinor(goal.targetAmountMinor!, goal.currencyCode!)}';
    }
    if (goal.milestones.isNotEmpty) {
      final done = goal.milestones.where((m) => m.isCompleted).length;
      return '$done / ${goal.milestones.length} milestones · ${goal.displayCategory}';
    }
    return '${goal.displayCategory} · ${goal.priority.label}';
  }
}
