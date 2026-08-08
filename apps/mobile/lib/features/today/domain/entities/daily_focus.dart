class DailyFocus {
  const DailyFocus({
    required this.title,
    required this.progressPercent,
    this.subtitle,
  });

  final String title;
  final double progressPercent;
  final String? subtitle;
}
