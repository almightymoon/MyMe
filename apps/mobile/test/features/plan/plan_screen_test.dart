import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/goals/data/seed/goals_seed.dart';
import 'package:memy/features/habits/data/seed/habits_seed.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('Plan shows populated goals, habits, and calendar sections', (
    tester,
  ) async {
    await pumpMemyApp(tester);
    await signInToToday(tester);

    await tester.tap(find.byKey(const Key('nav_plan')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('plan_summary')), findsOneWidget);
    expect(find.byKey(const Key('plan_goals_populated')), findsOneWidget);
    expect(find.byKey(const Key('plan_habits_populated')), findsOneWidget);
    expect(find.byKey(const Key('plan_calendar_populated')), findsOneWidget);
    expect(find.text(GoalsSeed.demoGoals.first.title), findsOneWidget);
    expect(
      find.textContaining(HabitsSeed.demoHabits.first.title),
      findsOneWidget,
    );
    expect(find.textContaining('Team Meeting'), findsOneWidget);
  });
}
