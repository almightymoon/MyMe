import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('Dashboard shows module grid and coach strip', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    await tester.tap(find.byKey(const Key('nav_plan')));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Modules'), findsOneWidget);
    expect(find.byKey(const Key('dashboard_module_goals')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_module_finance')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_module_health')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_module_calendar')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_module_wardrobe')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_module_nutrition')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_module_body')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_module_insights')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_coach_strip')), findsOneWidget);
    expect(find.textContaining('Team Meeting'), findsOneWidget);
  });

  testWidgets('Dashboard Goals module opens goals list', (tester) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    await tester.tap(find.byKey(const Key('nav_plan')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dashboard_module_goals')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('goals_list')), findsOneWidget);
  });
}
