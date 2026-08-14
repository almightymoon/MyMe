import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:memy/app/router/route_names.dart';
import 'package:memy/app/theme/app_colors.dart';
import 'package:memy/core/application/providers/app_info_providers.dart';
import 'package:memy/core/constants/app_strings.dart';
import 'package:memy/features/shell/presentation/memy_drawer.dart';
import 'package:memy/features/user/application/providers/user_providers.dart';
import 'package:memy/features/user/domain/entities/user_profile.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('drawer shows Demo Mode badge and Help navigates to support', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) {
            return Scaffold(
              endDrawer: const MemyDrawer(activeShellIndex: 0),
              body: Builder(
                builder: (context) {
                  return Center(
                    child: TextButton(
                      key: const Key('open_test_drawer'),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            );
          },
        ),
        GoRoute(
          path: RoutePaths.support,
          builder: (context, state) => const Scaffold(
            key: Key('support_screen'),
            body: Center(child: Text('Help & Support')),
          ),
        ),
        GoRoute(
          path: RoutePaths.profile,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Profile'))),
        ),
        GoRoute(
          path: RoutePaths.signIn,
          builder: (context, state) =>
              const Scaffold(body: Center(child: Text('Sign In'))),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith(
            (ref) async => const UserProfile(
              id: 'emma',
              displayName: 'Emma',
              fullName: 'Emma Chen',
              initials: 'EC',
            ),
          ),
          appVersionProvider.overrideWith((ref) async => '1.0.0'),
          selectedAvatarIdProvider.overrideWithValue('ember'),
        ],
        child: MaterialApp.router(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.ember),
            useMaterial3: true,
          ),
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open_test_drawer')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('memy_drawer')), findsOneWidget);
    expect(find.byKey(const Key('drawer_demo_badge')), findsOneWidget);
    expect(find.text(AppStrings.demoMode), findsOneWidget);
    expect(find.text('Emma Chen'), findsOneWidget);
    expect(find.text('Demo account'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('drawer_help')));
    await tester.pumpAndSettle();
    expect(find.text('Help & Support'), findsOneWidget);

    await tester.tap(find.byKey(const Key('drawer_help')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('support_screen')), findsOneWidget);
    expect(router.state.uri.path, RoutePaths.support);
  });

  testWidgets('drawer logout confirms then returns to sign in', (tester) async {
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) {
            return Scaffold(
              endDrawer: const MemyDrawer(),
              body: Builder(
                builder: (context) {
                  return Center(
                    child: TextButton(
                      key: const Key('open_test_drawer'),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      child: const Text('Open'),
                    ),
                  );
                },
              ),
            );
          },
        ),
        GoRoute(
          path: RoutePaths.signIn,
          builder: (context, state) => const Scaffold(
            key: Key('sign_in_screen'),
            body: Center(child: Text('Sign In')),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProfileProvider.overrideWith((ref) async => UserProfile.empty),
          appVersionProvider.overrideWith((ref) async => '9.9.9'),
          selectedAvatarIdProvider.overrideWithValue('ember'),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open_test_drawer')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drawer_version')), findsOneWidget);
    expect(find.textContaining('v9.9.9'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('drawer_logout')));
    await tester.tap(find.byKey(const Key('drawer_logout')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drawer_logout_confirm')), findsOneWidget);
    expect(
      find.textContaining('does not delete local MeMy data'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('drawer_logout_confirm_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('sign_in_screen')), findsOneWidget);
    expect(router.state.uri.path, RoutePaths.signIn);
  });
}
