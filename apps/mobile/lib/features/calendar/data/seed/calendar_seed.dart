import '../../domain/entities/schedule_item.dart';

/// Demo seed data inspired by `/app/js/data.js`.
abstract final class CalendarSeed {
  static const List<ScheduleItem> demoAgenda = [
    ScheduleItem(
      id: 'team',
      timeLabel: '10:00 AM',
      endTimeLabel: '11:00 AM',
      title: 'Team Meeting',
      place: 'Google Meet',
    ),
    ScheduleItem(
      id: 'research',
      timeLabel: '2:00 PM',
      endTimeLabel: '3:30 PM',
      title: 'Research Work',
      place: 'Focus Time',
    ),
    ScheduleItem(
      id: 'gym',
      timeLabel: '6:00 PM',
      endTimeLabel: '7:00 PM',
      title: 'Gym Workout',
      place: 'Fitness Center',
    ),
  ];
}
