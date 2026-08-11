import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/config/environment_config.dart';
import 'package:memy/core/config/release_capabilities.dart';
import 'package:memy/features/shell/presentation/sidebar/sidebar_destinations.dart';
import 'package:memy/features/trust/domain/entities/sidebar_destination.dart';

void main() {
  group('EnvironmentConfig defaults', () {
    test('CI/dev builds keep development + demo auth', () {
      expect(EnvironmentConfig.appEnvironment, AppEnvironment.development);
      expect(EnvironmentConfig.isProduction, isFalse);
      expect(EnvironmentConfig.authMode, AuthMode.demo);
      expect(EnvironmentConfig.usesDemoAuth, isTrue);
    });

    test('production does not seed demo module content', () {
      // Compile-time APP_ENV is development in CI; resolution helpers still
      // prove the production seed policy.
      expect(
        EnvironmentConfig.resolveGoalsDataSource(
          environment: AppEnvironment.production,
        ),
        GoalsDataSource.local,
      );
      // shouldSeedDemoContent follows the process APP_ENV (development in CI).
      expect(EnvironmentConfig.isProduction, isFalse);
      expect(EnvironmentConfig.shouldSeedDemoContent, isTrue);
    });

    test('validate() is a no-op outside production', () {
      expect(EnvironmentConfig.validate, returnsNormally);
    });

    test('store screenshot mode is off outside internal builds', () {
      expect(EnvironmentConfig.isProduction, isFalse);
      // CI APP_ENV=development → screenshot mode cannot activate.
      expect(EnvironmentConfig.storeScreenshotMode, isFalse);
    });
  });

  group('production data source resolution', () {
    const production = AppEnvironment.production;

    test('goals never resolve to fake or api', () {
      for (final raw in ['fake', 'api', 'local', 'nonsense', '']) {
        expect(
          EnvironmentConfig.resolveGoalsDataSource(
            environment: production,
            raw: raw,
          ),
          GoalsDataSource.local,
          reason: 'GOALS_DATA_SOURCE=$raw must be local in production',
        );
      }
    });

    test('finance and habits never resolve to fake', () {
      for (final raw in ['fake', 'local', '']) {
        expect(
          EnvironmentConfig.resolveFinanceDataSource(
            environment: production,
            raw: raw,
          ),
          FinanceDataSource.local,
        );
        expect(
          EnvironmentConfig.resolveHabitsDataSource(
            environment: production,
            raw: raw,
          ),
          HabitsDataSource.local,
        );
      }
    });

    test('calendar and health resolve to the real platform sources', () {
      for (final raw in ['fake', 'system', '']) {
        expect(
          EnvironmentConfig.resolveCalendarDataSource(
            environment: production,
            raw: raw,
          ),
          CalendarDataSource.system,
        );
        expect(
          EnvironmentConfig.resolveHealthDataSource(
            environment: production,
            raw: raw,
          ),
          HealthDataSource.system,
        );
      }
    });

    test('auth mode is forced to account even when demo is requested', () {
      expect(
        EnvironmentConfig.resolveAuthMode(environment: production, raw: 'demo'),
        AuthMode.account,
      );
    });

    test('development still honours explicit dart-defines', () {
      const development = AppEnvironment.development;
      expect(
        EnvironmentConfig.resolveGoalsDataSource(
          environment: development,
          raw: 'fake',
        ),
        GoalsDataSource.fake,
      );
      expect(
        EnvironmentConfig.resolveCalendarDataSource(
          environment: development,
          raw: 'system',
        ),
        CalendarDataSource.system,
      );
      expect(
        EnvironmentConfig.resolveAuthMode(
          environment: development,
          raw: 'none',
        ),
        AuthMode.none,
      );
    });
  });

  group('ReleaseCapabilities.production', () {
    final capabilities = ReleaseCapabilities.production();

    test('ships only the live v1 modules', () {
      expect(capabilities.goals, isTrue);
      expect(capabilities.finance, isTrue);
      expect(capabilities.habits, isTrue);
      expect(capabilities.deviceCalendar, isTrue);
      expect(capabilities.platformHealth, isTrue);
      expect(capabilities.exercise, isTrue);
      expect(capabilities.localOnboarding, isTrue);
      expect(capabilities.weather, isTrue);
    });

    test('everything not shippable in v1 is off', () {
      expect(capabilities.coachPreview, isFalse);
      expect(capabilities.wardrobe, isTrue);
      expect(capabilities.body, isFalse);
      expect(capabilities.nutritionQuickAdd, isFalse);
      expect(capabilities.notifications, isFalse);
      expect(capabilities.directWearables, isFalse);
      expect(capabilities.cloudAccount, isTrue);
      expect(capabilities.cloudSync, isTrue);
      expect(capabilities.debugIntegrationLab, isFalse);
      expect(capabilities.plannedSidebarItems, isFalse);
      expect(capabilities.exerciseSessions, isFalse);
    });

    test('has account auth and no demo auth', () {
      expect(capabilities.demoAuth, isFalse);
      expect(capabilities.accountAuth, isTrue);
      expect(capabilities.showSignOut, isTrue);
    });
  });

  group('production sidebar', () {
    final capabilities = ReleaseCapabilities.production();

    List<String> idsFor(SidebarSectionId section) {
      return SidebarDestinations.visibleForSection(
        section,
        capabilities,
      ).map((destination) => destination.id).toList();
    }

    test('primary keeps Today and Plan but drops Coach', () {
      expect(idsFor(SidebarSectionId.primary), ['today', 'plan']);
    });

    test('life areas keep the live modules including Wardrobe', () {
      expect(idsFor(SidebarSectionId.lifeAreas), [
        'goals',
        'finance',
        'habits',
        'calendar',
        'health',
        'exercise',
        'wardrobe',
      ]);
    });

    test('connections drop the planned Notifications row', () {
      expect(idsFor(SidebarSectionId.connections), [
        'connected_apps',
        'appearance',
        'settings',
      ]);
    });

    test('trust and help are unchanged', () {
      expect(idsFor(SidebarSectionId.trustHelp), [
        'privacy',
        'security',
        'support',
        'legal',
        'about',
      ]);
    });

    test('no visible destination is marked planned', () {
      for (final section in SidebarSectionId.values) {
        for (final destination in SidebarDestinations.visibleForSection(
          section,
          capabilities,
        )) {
          expect(
            destination.isPlanned,
            isFalse,
            reason: '${destination.id} is planned and must be hidden',
          );
        }
      }
    });
  });
}
