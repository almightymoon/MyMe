import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memy/app/app.dart';
import 'package:memy/core/data/fake_repository_config.dart';
import 'package:memy/features/goals/application/providers/goal_providers.dart';
import 'package:memy/features/goals/data/repositories/local_goal_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

FakeRepositoryConfig createTestFakeConfig({
  Duration delay = Duration.zero,
  bool forceEmpty = false,
  bool forceFailure = false,
}) {
  return FakeRepositoryConfig(
    delay: delay,
    forceEmpty: forceEmpty,
    forceFailure: forceFailure,
  );
}

/// [seedGoals]: when true (default), first launch seeds demo goals.
/// When false, marks storage initialized with an empty goal list.
Future<SharedPreferences> setupTestPreferences({bool seedGoals = true}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  if (!seedGoals) {
    await prefs.setBool(LocalGoalRepository.initializedKey, true);
    await prefs.setString(
      LocalGoalRepository.storageKey,
      '{"schemaVersion":1,"goals":[]}',
    );
  }
  return prefs;
}

Future<void> pumpMemyApp(
  WidgetTester tester, {
  FakeRepositoryConfig? config,
  List<Override> overrides = const [],
  bool seedGoals = true,
  SharedPreferences? prefs,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  final preferences = prefs ?? await setupTestPreferences(seedGoals: seedGoals);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        fakeRepositoryConfigProvider.overrideWithValue(
          config ?? createTestFakeConfig(),
        ),
        ...overrides,
      ],
      child: const MemyApp(),
    ),
  );
}

Future<void> signInToToday(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('continue_to_memy')));
  await tester.pumpAndSettle();
  expect(find.textContaining('Good day,'), findsOneWidget);
}
