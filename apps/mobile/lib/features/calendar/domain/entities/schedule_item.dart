class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.timeLabel,
    required this.title,
    this.place,
    this.endTimeLabel,
  });

  final String id;
  final String timeLabel;
  final String title;
  final String? place;
  final String? endTimeLabel;
}
