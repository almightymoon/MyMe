import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/application/providers/core_providers.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/features/calendar/application/providers/calendar_providers.dart';
import 'package:memy/features/calendar/data/repositories/fake_calendar_repository.dart';
import 'package:memy/features/calendar/domain/entities/calendar_create_recovery_case.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_sync_status.dart';
import 'package:memy/features/calendar/domain/entities/calendar_event_time.dart';
import 'package:memy/features/calendar/domain/entities/memy_calendar_event.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('recovery screen empty state', (tester) async {
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
    router.go(RoutePaths.calendarRecovery);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar_recovery')), findsOneWidget);
    expect(find.textContaining('No create-recovery cases'), findsOneWidget);
  });

  testWidgets('recovery screen shows one unresolved case', (tester) async {
    final clock = FixedAppClock(DateTime.utc(2026, 6, 15, 9));
    final repository = FakeCalendarRepository(
      clock: clock,
      seedEvents: [
        MemyCalendarEvent(
          id: 'evt_recovery_1',
          title: 'Should not appear in recovery UI',
          time: TimedCalendarEventTime(
            startUtc: DateTime.utc(2026, 6, 15, 10),
            endUtc: DateTime.utc(2026, 6, 15, 11),
          ),
          syncStatus: CalendarEventSyncStatus.pendingPush,
          createdAt: clock.now(),
          updatedAt: clock.now(),
        ),
      ],
    );
    await repository.saveRecoveryCase(
      CalendarCreateRecoveryCase(
        id: 'case_1',
        syncOperationId: 'op_1',
        memyEventId: 'evt_recovery_1',
        recoveryType: CalendarCreateRecoveryType.noMatchUnknownOutcome,
        status: CalendarCreateRecoveryStatus.unresolved,
        candidates: const [],
        createdAt: clock.now(),
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
    router.go(RoutePaths.calendarRecovery);
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('calendar_recovery')), findsOneWidget);
    expect(find.byKey(const Key('recovery_case_case_1')), findsOneWidget);
    expect(find.textContaining('No match on device'), findsOneWidget);
    expect(find.textContaining('Should not appear'), findsNothing);
  });
}
