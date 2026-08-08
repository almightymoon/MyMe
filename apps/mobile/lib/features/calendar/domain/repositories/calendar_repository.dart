import '../entities/schedule_item.dart';

abstract class CalendarRepository {
  Future<List<ScheduleItem>> fetchUpcomingEvents();
}
