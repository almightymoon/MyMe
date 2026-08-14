import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/core/application/providers/core_providers.dart';
import 'package:memy/features/onboarding/data/onboarding_preferences.dart';
import 'package:memy/features/profile/presentation/edit_profile_screen.dart';
import 'package:memy/features/user/domain/entities/profile_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SharedPreferences> pumpEdit(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final router = GoRouter(
      initialLocation: RoutePaths.editProfile,
      routes: [
        GoRoute(
          path: RoutePaths.profile,
          builder: (context, state) =>
              const Scaffold(key: Key('profile_stub'), body: SizedBox()),
        ),
        GoRoute(
          path: RoutePaths.editProfile,
          builder: (context, state) => const EditProfileScreen(),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    return prefs;
  }

  testWidgets('requires a name and persists chosen avatar', (tester) async {
    final prefs = await pumpEdit(tester);
    expect(find.byKey(const Key('profile_avatar_picker')), findsOneWidget);
    expect(find.text('Choose an avatar'), findsOneWidget);

    await tester.tap(find.byKey(const Key('edit_profile_save_button')));
    await tester.pump();
    expect(find.text('Name is required'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('edit_profile_name_field')),
      'Moon',
    );
    await tester.ensureVisible(
      find.byKey(const Key('profile_avatar_memy_3d_02')),
    );
    await tester.tap(find.byKey(const Key('profile_avatar_memy_3d_02')));
    await tester.tap(find.byKey(const Key('edit_profile_save_button')));
    await tester.pump();

    expect(OnboardingPreferences.readDisplayName(prefs), 'Moon');
    expect(OnboardingPreferences.readAvatarId(prefs), 'memy_3d_02');
  });

  test('catalog ids are unique and resolve unknown values', () {
    expect(ProfileAvatarCatalog.ids.toSet(), hasLength(12));
    expect(
      ProfileAvatarCatalog.resolve('nope'),
      ProfileAvatarCatalog.defaultId,
    );
    expect(ProfileAvatarCatalog.byId('gold').id, 'memy_3d_06');
    expect(ProfileAvatarCatalog.byId('ember').id, 'memy_3d_01');
    expect(ProfileAvatarCatalog.byId('memy_illustrated_01').id, 'memy_3d_01');
  });
}
