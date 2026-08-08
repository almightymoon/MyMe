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
      final current = goal.currentAmountMinor ?? 0;
      return '${_formatMinor(current, goal.currencyCode!)} of '
          '${_formatMinor(goal.targetAmountMinor!, goal.currencyCode!)}';
    }
    if (goal.milestones.isNotEmpty) {
      final done = goal.milestones.where((m) => m.isCompleted).length;
      return '$done / ${goal.milestones.length} milestones · ${goal.displayCategory}';
    }
    return '${goal.displayCategory} · ${goal.priority.label}';
  }

  static String _formatMinor(int minor, String currencyCode) {
    final major = minor / 100.0;
    final formatted = major >= 1000
        ? major
              .toStringAsFixed(0)
              .replaceAllMapped(
                RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]},',
              )
        : (minor % 100 == 0
              ? major.toStringAsFixed(0)
              : major.toStringAsFixed(2));
    return '$currencyCode $formatted';
  }
}
