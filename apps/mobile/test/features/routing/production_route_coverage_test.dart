import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/config/release_capabilities.dart';
import 'package:memy/core/widgets/coming_soon_view.dart';
import 'package:memy/features/auth/application/auth_session_controller.dart';
import 'package:memy/features/auth/domain/secure_session_store.dart';
import 'package:memy/features/onboarding/data/onboarding_preferences.dart';

import '../../helpers/test_app.dart';

/// Production routes that must open without throwing.
///
/// Parameterized templates are exercised with stand-in ids (empty detail
/// screens are acceptable as long as they do not crash).
final _productionRoutes = <String>[
  RoutePaths.today,
  RoutePaths.plan,
  RoutePaths.more,
  RoutePaths.goals,
  RoutePaths.addGoal,
  '/goals/missing-goal',
  RoutePaths.habits,
  RoutePaths.addHabit,
  '/habits/missing-habit',
  '/habits/missing-habit/edit',
  RoutePaths.finance,
  RoutePaths.addTransaction,
  RoutePaths.transactionHistory,
  '/finance/tx/missing-tx',
  '/finance/tx/missing-tx/edit',
  RoutePaths.financeBudgets,
  RoutePaths.addBudget,
  '/finance/budgets/missing-budget',
  '/finance/budgets/missing-budget/edit',
  RoutePaths.financeReports,
  RoutePaths.financeCategories,
  RoutePaths.financeMoneyOwed,
  RoutePaths.addMoneyOwed,
  '/finance/owed/missing-owed',
  '/finance/owed/missing-owed/edit',
  RoutePaths.calendar,
  RoutePaths.addEvent,
  RoutePaths.calendarConnect,
  RoutePaths.calendarSelection,
  RoutePaths.calendarConflicts,
  RoutePaths.calendarRecovery,
  '/calendar/event/missing-event',
  '/calendar/event/missing-event/edit',
  RoutePaths.health,
  RoutePaths.healthConnect,
  RoutePaths.healthPermissions,
  RoutePaths.healthWorkouts,
  RoutePaths.exercise,
  RoutePaths.exerciseLibrary,
  RoutePaths.settings,
  RoutePaths.connectedApps,
  RoutePaths.integrationDiagnostics,
  RoutePaths.appearance,
  RoutePaths.profile,
  RoutePaths.editProfile,
  RoutePaths.privacy,
  RoutePaths.privacyExport,
  RoutePaths.privacyDeletion,
  RoutePaths.privacyAiDataUse,
  RoutePaths.security,
  RoutePaths.support,
  RoutePaths.helpArticlePath('getting-started'),
  RoutePaths.helpContact,
  RoutePaths.helpReportProblem,
  RoutePaths.helpFeatureRequest,
  RoutePaths.legal,
  RoutePaths.legalDocumentPath('privacy-policy'),
  RoutePaths.about,
  RoutePaths.whatsNew,
  RoutePaths.onboarding,
  RoutePaths.wardrobe,
  RoutePaths.wardrobeItems,
  RoutePaths.addWardrobeItem,
  '/wardrobe/items/missing-item',
  '/wardrobe/items/missing-item/edit',
  RoutePaths.wardrobeOutfits,
  RoutePaths.addOutfit,
  '/wardrobe/outfits/missing-outfit',
  '/wardrobe/outfits/missing-outfit/edit',
  RoutePaths.wardrobeSuggestions,
  RoutePaths.wardrobePlanner,
  RoutePaths.wardrobeHistory,
  RoutePaths.wardrobeSettings,
];

const _hiddenProductionRoutes = <String, String>{
  RoutePaths.coach: RoutePaths.today,
  RoutePaths.body: RoutePaths.today,
  RoutePaths.nutritionComingSoon: RoutePaths.today,
  RoutePaths.workoutSession: RoutePaths.exercise,
  RoutePaths.notifications: RoutePaths.settings,
  RoutePaths.signIn: RoutePaths.today,
  RoutePaths.signUp: RoutePaths.today,
  RoutePaths.forgotPassword: RoutePaths.today,
};

void main() {
  testWidgets('every production route opens without throwing', (tester) async {
    final prefs = await setupTestPreferences();
    await OnboardingPreferences.markComplete(prefs);
    await pumpMemyApp(
      tester,
      prefs: prefs,
      overrides: [
        releaseCapabilitiesProvider.overrideWithValue(
          ReleaseCapabilities.production(),
        ),
        authSessionProvider.overrideWith(
          (ref) => AuthSessionController(
            InMemorySecureSessionStore(),
            initial: StoredAuthSession(
              userId: '11111111-1111-4111-8111-111111111111',
              deviceId: '22222222-2222-4222-8222-222222222222',
              clientGeneratedDeviceId: 'test-device-aaaaaaaa',
              provider: 'google',
              refreshToken: 'test-refresh',
              authenticatedAt: DateTime.utc(2026, 8, 11),
            ),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('nav_today'))),
    );

    for (final path in _productionRoutes) {
      router.go(path);
      await tester.pump();
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 40));
      }
      expect(
        tester.takeException(),
        isNull,
        reason: 'opening $path must not throw',
      );
      expect(
        find.byType(ComingSoonView),
        findsNothing,
        reason: '$path must not render ComingSoonView in production',
      );
    }
  });

  testWidgets('hidden production routes redirect to safe destinations', (
    tester,
  ) async {
    final prefs = await setupTestPreferences();
    await OnboardingPreferences.markComplete(prefs);
    await pumpMemyApp(
      tester,
      prefs: prefs,
      overrides: [
        releaseCapabilitiesProvider.overrideWithValue(
          ReleaseCapabilities.production(),
        ),
        authSessionProvider.overrideWith(
          (ref) => AuthSessionController(
            InMemorySecureSessionStore(),
            initial: StoredAuthSession(
              userId: '11111111-1111-4111-8111-111111111111',
              deviceId: '22222222-2222-4222-8222-222222222222',
              clientGeneratedDeviceId: 'test-device-aaaaaaaa',
              provider: 'google',
              refreshToken: 'test-refresh',
              authenticatedAt: DateTime.utc(2026, 8, 11),
            ),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    final router = GoRouter.of(
      tester.element(find.byKey(const Key('nav_today'))),
    );

    for (final entry in _hiddenProductionRoutes.entries) {
      router.go(entry.key);
      await tester.pumpAndSettle();
      expect(
        router.state.uri.path,
        entry.value,
        reason: '${entry.key} must redirect to ${entry.value}',
      );
    }
  });
}
