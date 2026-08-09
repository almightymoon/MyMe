import '../../domain/entities/schedule_item.dart';

/// Demo seed data inspired by `/app/js/data.js` (August 2026).
abstract final class CalendarSeed {
  static final DateTime demoDay = DateTime(2026, 8, 7);

  static final List<ScheduleItem> demoAgenda = [
    ScheduleItem(
      id: 'team',
      timeLabel: '10:00 AM',
      endTimeLabel: '11:00 AM',
      title: 'Team Meeting',
      place: 'Google Meet',
      date: demoDay,
      colorValue: 0xFF34C759,
    ),
    ScheduleItem(
      id: 'research',
      timeLabel: '2:00 PM',
      endTimeLabel: '3:30 PM',
      title: 'Research Work',
      place: 'Focus Time',
      date: demoDay,
      colorValue: 0xFFE8501F,
    ),
    ScheduleItem(
      id: 'gym',
      timeLabel: '6:00 PM',
      endTimeLabel: '7:00 PM',
      title: 'Gym Workout',
      place: 'Fitness Center',
      date: demoDay,
      colorValue: 0xFF34C759,
    ),
  ];

  static const List<int> eventPalette = [
    0xFF34C759,
    0xFFE8501F,
    0xFF3B82F6,
    0xFFFF6A1A,
    0xFF8B5CF6,
  ];
}
