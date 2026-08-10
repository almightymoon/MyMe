import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/domain/clock/app_clock.dart';
import 'package:memy/core/application/providers/core_providers.dart';
import 'package:memy/features/calendar/application/providers/calendar_providers.dart';
import 'package:memy/features/calendar/data/gateways/fake_device_calendar_gateway.dart';
import 'package:memy/features/calendar/data/repositories/fake_calendar_repository.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets(
    'connect → choose calendars → sync navigates back to the calendar and clears the banner',
    (tester) async {
      final clock = FixedAppClock(DateTime.utc(2026, 6, 15, 9));
      final gateway = FakeDeviceCalendarGateway();
      gateway.seedCalendar(id: 'cal_1', name: 'Personal', isDefault: true);
      final repository = FakeCalendarRepository(
        clock: clock,
        seedEvents: const [],
      );

      await pumpMemyApp(
        tester,
        overrides: [
          appClockProvider.overrideWithValue(clock),
          deviceCalendarGatewayProvider.overrideWithValue(gateway),
          calendarRepositoryProvider.overrideWith((ref) => repository),
        ],
      );
      await signInToToday(tester);

      final router = GoRouter.of(tester.element(find.textContaining('Hi,')));
      router.go(RoutePaths.calendar);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('calendar_connection_banner')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('calendar_connect_cta')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('calendar_connection')), findsOneWidget);

      await tester.tap(find.byKey(const Key('calendar_connect_button')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('calendar_choose_calendars_button')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const Key('calendar_choose_calendars_button')),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('calendar_selection')), findsOneWidget);
      expect(find.byKey(const Key('calendar_option_cal_1')), findsOneWidget);

      await tester.tap(find.byKey(const Key('calendar_selection_confirm')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('calendar_overview')), findsOneWidget);
      expect(find.byKey(const Key('calendar_connection_banner')), findsNothing);

      final config = await repository.getConfig();
      expect(config.readableCalendarIds, ['cal_1']);
      expect(config.defaultWritableCalendarId, 'cal_1');
    },
  );
}
