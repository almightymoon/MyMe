import '../../../../core/data/fake_repository_config.dart';
import '../../domain/entities/schedule_item.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../seed/calendar_seed.dart';

/// In-memory [CalendarRepository] for UI development and tests.
///
/// Demo only — not backed by a network or database.
class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository({required this.config})
    : _events = List<ScheduleItem>.from(CalendarSeed.demoAgenda);

  final FakeRepositoryConfig config;
  final List<ScheduleItem> _events;

  @override
  Future<List<ScheduleItem>> fetchUpcomingEvents() {
    return runFakeFetch(
      config: config,
      onData: () => List<ScheduleItem>.unmodifiable(_events),
      onEmpty: () => const <ScheduleItem>[],
    );
  }

  @override
  Future<List<ScheduleItem>> fetchAllEvents() {
    return runFakeFetch(
      config: config,
      onData: () => List<ScheduleItem>.unmodifiable(_events),
      onEmpty: () => const <ScheduleItem>[],
    );
  }

  @override
  Future<ScheduleItem> addEvent(ScheduleItem event) async {
    await Future<void>.delayed(config.delay);
    if (config.forceFailure) {
      throw FakeRepositoryException(config.failureMessage);
    }
    _events.add(event);
    return event;
  }
}
