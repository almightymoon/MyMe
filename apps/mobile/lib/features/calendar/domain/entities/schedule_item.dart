class ScheduleItem {
  const ScheduleItem({
    required this.id,
    required this.timeLabel,
    required this.title,
    this.place,
    this.endTimeLabel,
    this.date,
    this.colorValue = 0xFFFF6A1A,
    this.notes,
    this.reminderMinutes,
  });

  final String id;
  final String timeLabel;
  final String title;
  final String? place;
  final String? endTimeLabel;

  /// Calendar day this event belongs to (time component ignored).
  final DateTime? date;

  /// ARGB color for the agenda accent bar.
  final int colorValue;

  final String? notes;
  final int? reminderMinutes;

  String get metaLabel {
    final base = place ?? '';
    if (notes == null || notes!.isEmpty) return base;
    if (base.isEmpty) return notes!;
    return '$base · $notes';
  }

  bool isOnDay(DateTime day) {
    final d = date;
    if (d == null) return false;
    return d.year == day.year && d.month == day.month && d.day == day.day;
  }

  ScheduleItem copyWith({
    String? id,
    String? timeLabel,
    String? title,
    String? place,
    String? endTimeLabel,
    DateTime? date,
    int? colorValue,
    String? notes,
    int? reminderMinutes,
  }) {
    return ScheduleItem(
      id: id ?? this.id,
      timeLabel: timeLabel ?? this.timeLabel,
      title: title ?? this.title,
      place: place ?? this.place,
      endTimeLabel: endTimeLabel ?? this.endTimeLabel,
      date: date ?? this.date,
      colorValue: colorValue ?? this.colorValue,
      notes: notes ?? this.notes,
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
    );
  }
}
