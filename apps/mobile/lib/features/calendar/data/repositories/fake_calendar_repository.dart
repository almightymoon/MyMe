import '../../../../core/data/fake_repository_config.dart';
import '../../domain/entities/schedule_item.dart';
import '../../domain/repositories/calendar_repository.dart';
import '../seed/calendar_seed.dart';

/// In-memory [CalendarRepository] for UI development and tests.
///
/// Demo only — not backed by a network or database.
class FakeCalendarRepository implements CalendarRepository {
  FakeCalendarRepository({required this.config});

  final FakeRepositoryConfig config;

  @override
  Future<List<ScheduleItem>> fetchUpcomingEvents() {
    return runFakeFetch(
      config: config,
      onData: () => List<ScheduleItem>.unmodifiable(CalendarSeed.demoAgenda),
      onEmpty: () => const <ScheduleItem>[],
    );
  }
}
