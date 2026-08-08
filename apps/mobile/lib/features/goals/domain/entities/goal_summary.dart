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
}
