import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/application/providers/core_providers.dart';
import 'package:memy/features/calendar/application/providers/calendar_providers.dart';
import 'package:memy/features/calendar/data/repositories/fake_calendar_repository.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_sync_status.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_time.dart';
import 'package:memy/features/calendar/domain/entities/calendar_sync_conflict.dart';
import 'package:memy/features/calendar/domain/entities/external_event_snapshot.dart';
import 'package:memy/features/calendar/domain/entities/memy_calendar_event.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets(
    'resolving a conflict with Keep both clears the banner and list',
    (tester) async {
      final clock = FixedAppClock(DateTime.utc(2026, 6, 15, 9));
      final time = TimedCalendarEventTime(
        startUtc: DateTime.utc(2026, 6, 15, 10),
        endUtc: DateTime.utc(2026, 6, 15, 11),
      );
      final localEvent = MemyCalendarEvent(
        id: 'evt_1',
        title: 'Design Review (moved)',
        time: time,
        syncStatus: CalendarEventSyncStatus.conflict,
        createdAt: clock.now(),
        updatedAt: clock.now(),
      );
      final repository = FakeCalendarRepository(
        clock: clock,
        seedEvents: [localEvent],
      );
      await repository.addConflict(
        CalendarSyncConflict(
          id: 'conflict_1',
          memyEventId: 'evt_1',
          localSnapshot: localEvent,
          externalSnapshot: ExternalEventSnapshot(
            title: 'Design Review (renamed on phone)',
            time: time,
          ),
          detectedAt: clock.now(),
        ),
      );

      await pumpMemyApp(
        tester,
        overrides: [
          appClockProvider.overrideWithValue(clock),
          calendarRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      await signInToToday(tester);

      final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
      router.go(RoutePaths.calendarConflicts);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('calendar_conflicts')), findsOneWidget);
      expect(find.byKey(const Key('conflict_conflict_1')), findsOneWidget);
      expect(find.textContaining('Design Review (moved)'), findsOneWidget);
      expect(
        find.textContaining('Design Review (renamed on phone)'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('conflict_keep_both_conflict_1')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('conflict_conflict_1')), findsNothing);
      expect(await repository.getConflicts(), isEmpty);

      final events = await repository.getEventsInRange(
        startUtc: DateTime.utc(2020),
        endUtc: DateTime.utc(2030),
      );
      expect(events, hasLength(2));
    },
  );
}
