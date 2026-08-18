import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/features/onboarding/data/onboarding_preferences.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('unknown route shows page not found and can return home', (
    tester,
  ) async {
    final prefs = await setupTestPreferences();
    await OnboardingPreferences.markComplete(prefs);
    await pumpMemyApp(tester, prefs: prefs);
    await signInToToday(tester);

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('nav_today'))),
    );
    router.go('/this-route-does-not-exist');
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page_not_found')), findsOneWidget);
    expect(find.text('Page not found'), findsOneWidget);
    expect(
      find.text(
        '“/this-route-does-not-exist” is not in MeMy. Head home and continue from there.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('Go home'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('page_not_found')), findsNothing);
    expect(router.state.uri.path, RoutePaths.today);
    expect(find.byKey(const Key('nav_today')), findsOneWidget);
  });
}
