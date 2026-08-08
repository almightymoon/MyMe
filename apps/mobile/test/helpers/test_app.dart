import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memy/app/app.dart';
import 'package:memy/core/data/fake_repository_config.dart';

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

Future<void> pumpMemyApp(
  WidgetTester tester, {
  FakeRepositoryConfig? config,
  List<Override> overrides = const [],
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
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
