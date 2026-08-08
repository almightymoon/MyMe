class HabitSummary {
  const HabitSummary({
    required this.id,
    required this.title,
    required this.valueLabel,
    required this.detailLabel,
    this.isOnTrack = true,
  });

  final String id;
  final String title;
  final String valueLabel;
  final String detailLabel;
  final bool isOnTrack;
}
