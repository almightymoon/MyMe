import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/fake_repository_config.dart';
import '../../data/repositories/fake_calendar_repository.dart';
import '../../domain/entities/schedule_item.dart';
import '../../domain/repositories/calendar_repository.dart';

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  return FakeCalendarRepository(
    config: ref.watch(fakeRepositoryConfigProvider),
  );
});

final upcomingEventsProvider = FutureProvider.autoDispose<List<ScheduleItem>>((
  ref,
) async {
  return ref.watch(calendarRepositoryProvider).fetchUpcomingEvents();
});
