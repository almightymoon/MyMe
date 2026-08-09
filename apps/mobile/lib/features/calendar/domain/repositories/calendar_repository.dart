import '../entities/schedule_item.dart';

abstract class CalendarRepository {
  Future<List<ScheduleItem>> fetchUpcomingEvents();

  Future<List<ScheduleItem>> fetchAllEvents();

  Future<ScheduleItem> addEvent(ScheduleItem event);
}
