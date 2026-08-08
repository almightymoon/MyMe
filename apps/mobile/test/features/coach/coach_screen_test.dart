import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memy/core/constants/app_strings.dart';
import 'package:memy/core/data/fake_repository_config.dart';
import 'package:memy/features/coach/data/seed/coach_seed.dart';
import 'package:memy/features/coach/presentation/coach_screen.dart';
import 'package:memy/features/user/application/providers/user_providers.dart';
import 'package:memy/features/user/data/seed/user_seed.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Future<void> pumpCoach(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          fakeRepositoryConfigProvider.overrideWithValue(
            FakeRepositoryConfig(delay: Duration.zero),
          ),
          userProfileProvider.overrideWith((ref) async => UserSeed.demoProfile),
        ],
        child: const MaterialApp(home: Scaffold(body: CoachScreen())),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Coach demo prompt creates a labeled demo response', (
    tester,
  ) async {
    await pumpCoach(tester);

    expect(find.byKey(const Key('coach_prompts')), findsOneWidget);

    final prompt = CoachSeed.suggestedPrompts.first;
    await tester.ensureVisible(find.byKey(Key('coach_prompt_${prompt.id}')));
    await tester.tap(find.byKey(Key('coach_prompt_${prompt.id}')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('coach_conversation')), findsOneWidget);
    expect(find.text(prompt.prompt), findsWidgets);
    expect(find.text(AppStrings.demoResponseLabel), findsWidgets);
    expect(find.textContaining('Live AI is not connected'), findsWidgets);
  });

  testWidgets('Coach composer appends a local demo response', (tester) async {
    await pumpCoach(tester);

    await tester.enterText(
      find.byKey(const Key('coach_composer')),
      'Help me prioritize',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('coach_send')));
    await tester.pumpAndSettle();

    expect(find.text('Help me prioritize'), findsOneWidget);
    expect(find.text(AppStrings.demoResponseLabel), findsWidgets);
  });
}
