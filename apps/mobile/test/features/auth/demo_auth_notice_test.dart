import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/constants/app_strings.dart';

import '../../helpers/test_app.dart';

void main() {
  testWidgets('Sign In shows demo authentication notice', (tester) async {
    await pumpMemyApp(tester);

    expect(find.byKey(const Key('demo_auth_notice')), findsOneWidget);
    expect(find.text(AppStrings.demoAuthNote), findsWidgets);
    expect(
      find.text('Demo mode — authentication is not connected yet.'),
      findsOneWidget,
    );
  });

  testWidgets('Sign Up shows demo authentication notice', (tester) async {
    await pumpMemyApp(tester);
    await tester.tap(find.byKey(const Key('auth_go_signup')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('demo_auth_notice')), findsOneWidget);
    expect(
      find.text('Demo mode — authentication is not connected yet.'),
      findsOneWidget,
    );
  });
}
