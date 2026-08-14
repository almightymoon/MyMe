import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/app/theme/app_theme.dart';
import 'package:memy/core/application/providers/core_providers.dart';
import 'package:memy/features/trust/presentation/privacy/privacy_data_center_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('privacy data center loads catalog', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const PrivacyDataCenterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('privacy_data_center')), findsOneWidget);
    expect(find.text('Privacy & Data'), findsOneWidget);
    expect(find.text('Health'), findsWidgets);
    expect(find.text('Finance'), findsWidgets);
    expect(find.byKey(const Key('privacy_export')), findsOneWidget);
  });
}
