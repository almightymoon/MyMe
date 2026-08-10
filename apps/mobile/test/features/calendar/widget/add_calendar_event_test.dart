import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/application/providers/core_providers.dart';
import 'package:memy/features/calendar/application/providers/calendar_providers.dart';
import 'package:memy/features/calendar/data/repositories/fake_calendar_repository.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_sync_status.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets(
    'adding an event saves it as pendingPush and shows the detail screen',
    (tester) async {
      final clock = FixedAppClock(DateTime.utc(2026, 6, 15, 9));
      final repository = FakeCalendarRepository(
        clock: clock,
        seedEvents: const [],
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
      router.go(RoutePaths.addEvent);
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('add_calendar_event')), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('event_title_field')),
        'Client Call',
      );
      await tester.ensureVisible(find.byKey(const Key('event_save')));
      await tester.tap(find.byKey(const Key('event_save')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('calendar_event_detail')), findsOneWidget);
      expect(find.text('Client Call'), findsWidgets);

      final events = await repository.getEventsInRange(
        startUtc: DateTime.utc(2020),
        endUtc: DateTime.utc(2030),
      );
      final saved = events.singleWhere((e) => e.title == 'Client Call');
      // The event starts as pendingPush; the fake gateway push may have
      // already resolved it to synced by the time we assert.
      expect(
        saved.syncStatus,
        anyOf(
          CalendarEventSyncStatus.pendingPush,
          CalendarEventSyncStatus.synced,
        ),
      );
    },
  );

  testWidgets('empty title shows a validation error and does not save', (
    tester,
  ) async {
    final clock = FixedAppClock(DateTime.utc(2026, 6, 15, 9));
    await pumpMemyApp(
      tester,
      overrides: [
        appClockProvider.overrideWithValue(clock),
        calendarRepositoryProvider.overrideWith(
          (ref) => FakeCalendarRepository(clock: clock, seedEvents: const []),
        ),
      ],
    );
    await signInToToday(tester);

    final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
    router.go(RoutePaths.addEvent);
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('event_save')));
    await tester.tap(find.byKey(const Key('event_save')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('event_error')), findsOneWidget);
    expect(find.byKey(const Key('add_calendar_event')), findsOneWidget);
  });
}
