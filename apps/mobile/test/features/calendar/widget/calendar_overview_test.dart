import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/application/providers/core_providers.dart';
import 'package:memy/features/calendar/application/providers/calendar_providers.dart';
import 'package:memy/features/calendar/data/repositories/fake_calendar_repository.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_time.dart';
import 'package:memy/features/calendar/domain/entities/memy_calendar_event.dart';

import '../../../helpers/test_app.dart';

final _fixedNow = DateTime.utc(2026, 6, 15, 9);

MemyCalendarEvent _eventOn(
  DateTime day, {
  required String id,
  required String title,
}) {
  final start = DateTime.utc(day.year, day.month, day.day, 10);
  return MemyCalendarEvent(
    id: id,
    title: title,
    time: TimedCalendarEventTime(
      startUtc: start,
      endUtc: start.add(const Duration(hours: 1)),
    ),
    createdAt: _fixedNow,
    updatedAt: _fixedNow,
  );
}

Future<void> _openCalendar(WidgetTester tester) async {
  final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
  router.go(RoutePaths.calendar);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('calendar overview shows seeded agenda for the selected day', (
    tester,
  ) async {
    final clock = FixedAppClock(_fixedNow);
    await pumpMemyApp(
      tester,
      overrides: [
        appClockProvider.overrideWithValue(clock),
        calendarRepositoryProvider.overrideWith(
          (ref) => FakeCalendarRepository(
            clock: clock,
            seedEvents: [
              _eventOn(_fixedNow, id: 'evt_1', title: 'Design Review'),
            ],
          ),
        ),
      ],
    );
    await signInToToday(tester);
    await _openCalendar(tester);

    expect(find.byKey(const Key('calendar_overview')), findsOneWidget);
    expect(find.text('Design Review'), findsOneWidget);
    expect(find.byKey(const Key('calendar_connection_banner')), findsOneWidget);
  });

  testWidgets('calendar overview shows empty state for a day with no events', (
    tester,
  ) async {
    final clock = FixedAppClock(_fixedNow);
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
    await _openCalendar(tester);

    expect(find.text('No events'), findsOneWidget);
  });

  testWidgets('tapping + navigates to the add event screen', (tester) async {
    final clock = FixedAppClock(_fixedNow);
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
    await _openCalendar(tester);

    await tester.tap(find.byKey(const Key('calendar_add')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('add_calendar_event')), findsOneWidget);
  });
}
