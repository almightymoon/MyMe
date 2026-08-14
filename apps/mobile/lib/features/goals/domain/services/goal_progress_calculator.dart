import '../entities/goal.dart';
import '../entities/goal_enums.dart';
import '../entities/goal_milestone.dart';
import '../value_objects/money_minor.dart';

/// Recalculates [Goal.progressPercent] from amounts and/or milestones.
abstract final class GoalProgressCalculator {
  static double calculate(Goal goal) {
    if (goal.status == GoalStatus.completed) return 100;

    final target = goal.targetAmountMinor;
    if (target != null && target.isPositive) {
      final rawCurrent = (goal.currentAmountMinor ?? MoneyMinor.zero).value;
      final currentValue = rawCurrent > target.value
          ? target.value
          : rawCurrent;
      // Scale by 100 using BigInt floor division so amounts never pass through
      // `double`; matches server `calculateFinancialProgressPercent`.
      final percent = (currentValue * BigInt.from(100)) ~/ target.value;
      return percent.toDouble().clamp(0, 100);
    }

    if (goal.milestones.isNotEmpty) {
      final done = goal.milestones.where((m) => m.isCompleted).length;
      return ((done / goal.milestones.length) * 100).clamp(0, 100);
    }

    return goal.progressPercent.clamp(0, 100);
  }

  static Goal withRecalculatedProgress(Goal goal) {
    final progress = calculate(goal);
    var status = goal.status;
    if (progress >= 100 && status == GoalStatus.active) {
      status = GoalStatus.completed;
    }
    return goal.copyWith(progressPercent: progress, status: status);
  }

  static List<GoalMilestone> reindex(List<GoalMilestone> milestones) {
    final sorted = [...milestones]..sort((a, b) => a.order.compareTo(b.order));
    return [
      for (var i = 0; i < sorted.length; i++) sorted[i].copyWith(order: i),
    ];
  }
}
