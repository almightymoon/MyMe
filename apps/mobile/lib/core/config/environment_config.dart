/// Build-time environment for MeMy mobile.
///
/// Configure with `--dart-define`:
///
/// ```bash
/// # Goals data source: fake | local | api  (default: local)
/// --dart-define=GOALS_DATA_SOURCE=api
///
/// # Finance data source: fake | local  (default: local)
/// --dart-define=FINANCE_DATA_SOURCE=fake
///
/// # Habits data source: fake | local  (default: local)
/// --dart-define=HABITS_DATA_SOURCE=fake
///
/// # Calendar data source: fake | system  (default: fake)
/// `fake` uses an in-memory repository + FakeDeviceCalendarGateway — no
/// SQLite, no device permissions, safe for CI. `system` persists to a real
/// SQLite database via Drift and talks to the device's calendar provider
/// through `device_calendar` — requires a real device/simulator and
/// calendar permission, so it is never the CI default.
/// --dart-define=CALENDAR_DATA_SOURCE=system
///
/// # Health data source: fake | system  (default: fake)
/// `fake` uses FakePlatformHealthGateway — no HealthKit/Health Connect, no
/// device permissions, safe for CI/simulators. `system` wraps the `health`
/// plugin and requires a real device (or an iOS simulator with the Health
/// app / an Android emulator with Health Connect installed) — never the CI
/// default. Read-only in both modes; MeMy never writes to platform Health.
///
/// iOS also requires (already applied in this repo):
///   - `ios/Runner/Info.plist`: `NSHealthShareUsageDescription`. No
///     `NSHealthUpdateUsageDescription` — MeMy never writes to HealthKit.
///   - `ios/Runner/Runner.entitlements`: `com.apple.developer.healthkit`,
///     wired via `CODE_SIGN_ENTITLEMENTS` in `Runner.xcodeproj`. Xcode's
///     Signing & Capabilities tab should also show "HealthKit" enabled for
///     the Runner target (add the capability there if it doesn't yet, e.g.
///     after regenerating the project) — capabilities are partly tracked in
///     the provisioning profile/Apple Developer portal, not only the file.
///
/// Android also requires (already applied in this repo, see
/// `android/app/src/main/AndroidManifest.xml`):
///   - `android.permission.health.READ_STEPS`
///   - `android.permission.health.READ_DISTANCE`
///   - `android.permission.health.READ_ACTIVE_CALORIES_BURNED`
///   - `android.permission.health.READ_HEART_RATE`
///   - `android.permission.health.READ_RESTING_HEART_RATE`
///   - `android.permission.health.READ_EXERCISE`
///   - `android.permission.health.READ_SLEEP`
///   - `android.permission.health.READ_WEIGHT`
///   - `android.permission.ACTIVITY_RECOGNITION` (required for Steps)
///   - a `<queries>` entry for `com.google.android.apps.healthdata` (so
///     `checkAvailability()` can detect whether Health Connect is
///     installed) plus the `androidx.health.ACTION_SHOW_PERMISSIONS_
///     RATIONALE` intent-filter/query and `ViewPermissionUsageActivity`
///     alias Health Connect's permissions UI needs
///   - `MainActivity` extends `FlutterFragmentActivity` (Android 14+
///     permission requests need `registerForActivityResult`)
/// No `WRITE_*` health permission is ever declared — read-only end to end.
/// --dart-define=HEALTH_DATA_SOURCE=system
///
/// # API base including version prefix
/// # iOS simulator / desktop:
/// --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1
/// # Android emulator:
/// --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
/// # Physical device (LAN):
/// --dart-define=API_BASE_URL=http://192.168.x.x:3000/api/v1
///
/// # Development auth user (debug builds only; never sent in release)
/// --dart-define=DEV_USER_ID=00000000-0000-4000-8000-000000000001
///
/// # Support inbox for Help & Support mailto links (optional)
/// # When empty, contact actions show an in-app message instead of mailto.
/// --dart-define=SUPPORT_EMAIL=support@example.com
///
/// # Release environment: development | internal | production
/// # (default: development, so CI/tests keep their existing behaviour)
/// --dart-define=APP_ENV=production
///
/// # Auth mode: demo | none | account
/// # (default: demo; production always resolves account)
/// --dart-define=AUTH_MODE=none
///
/// # Optional feature gates (default off in production, on in dev/internal)
/// --dart-define=ENABLE_AI_PREVIEW=true
/// --dart-define=ENABLE_INTEGRATION_LAB=true
/// --dart-define=ENABLE_DEVELOPER_MENU=true
/// --dart-define=SHOW_PLANNED_FEATURES=true
/// ```
///
/// See `docs/architecture/v1-release-configuration.md` for the full matrix.
library;

import 'package:flutter/foundation.dart';

enum GoalsDataSource { fake, local, api }

enum FinanceDataSource { fake, local }

enum HabitsDataSource { fake, local }

enum CalendarDataSource { fake, system }

enum HealthDataSource { fake, system }

/// Build channel. `production` is the locked-down v1 shipping configuration.
enum AppEnvironment { development, internal, production }

/// `demo` shows the local fake email/password screens (non-production only).
/// `none` skips account auth and relies on local onboarding.
/// `account` is Google / Sign in with Apple. Production always resolves to
/// [account].
enum AuthMode { demo, none, account }

/// Raised by [EnvironmentConfig.validate] when dart-defines are contradictory.
class EnvironmentConfigError extends Error {
  EnvironmentConfigError(this.message);

  final String message;

  @override
  String toString() => 'EnvironmentConfigError: $message';
}

class EnvironmentConfig {
  const EnvironmentConfig._();

  /// Full API prefix, e.g. `http://127.0.0.1:3000/api/v1`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3000/api/v1',
  );

  /// `fake` | `local` | `api` — defaults to local offline persistence.
  static const String goalsDataSourceRaw = String.fromEnvironment(
    'GOALS_DATA_SOURCE',
    defaultValue: 'local',
  );

  /// `fake` | `local` — defaults to local offline persistence.
  static const String financeDataSourceRaw = String.fromEnvironment(
    'FINANCE_DATA_SOURCE',
    defaultValue: 'local',
  );

  /// `fake` | `local` — defaults to local offline persistence.
  static const String habitsDataSourceRaw = String.fromEnvironment(
    'HABITS_DATA_SOURCE',
    defaultValue: 'local',
  );

  /// `fake` | `system` — defaults to `fake` for CI/test safety. `system`
  /// requires a real device/simulator calendar provider and permission.
  static const String calendarDataSourceRaw = String.fromEnvironment(
    'CALENDAR_DATA_SOURCE',
    defaultValue: 'fake',
  );

  /// `fake` | `system` — defaults to `fake` for CI/simulator safety. `system`
  /// requires a real device with HealthKit/Health Connect and read
  /// permission granted by the user; MeMy never writes to platform Health.
  static const String healthDataSourceRaw = String.fromEnvironment(
    'HEALTH_DATA_SOURCE',
    defaultValue: 'fake',
  );

  /// Must match API `DEV_USER_ID`. Used only when [kDebugMode] is true.
  static const String devUserId = String.fromEnvironment(
    'DEV_USER_ID',
    defaultValue: '00000000-0000-4000-8000-000000000001',
  );

  /// Optional support inbox for Help & Support contact actions.
  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: '',
  );

  static bool get hasSupportEmail => supportEmail.trim().isNotEmpty;

  /// `development` | `internal` | `production`.
  ///
  /// Defaults to `development` so existing CI, tests and local runs keep the
  /// demo-auth behaviour they were written against.
  static const String appEnvironmentRaw = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'development',
  );

  /// `demo` | `none` | `account`. Ignored in production (always `account`).
  static const String authModeRaw = String.fromEnvironment(
    'AUTH_MODE',
    defaultValue: 'demo',
  );

  /// Empty means "unset" so each flag can pick an environment-aware default.
  static const String enableAiPreviewRaw = String.fromEnvironment(
    'ENABLE_AI_PREVIEW',
  );
  static const String enableIntegrationLabRaw = String.fromEnvironment(
    'ENABLE_INTEGRATION_LAB',
  );
  static const String enableDeveloperMenuRaw = String.fromEnvironment(
    'ENABLE_DEVELOPER_MENU',
  );
  static const String showPlannedFeaturesRaw = String.fromEnvironment(
    'SHOW_PLANNED_FEATURES',
  );

  /// Internal-only deterministic screenshot capture. Always false in production.
  static const String storeScreenshotModeRaw = String.fromEnvironment(
    'STORE_SCREENSHOT_MODE',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  static AppEnvironment get appEnvironment {
    switch (appEnvironmentRaw.trim().toLowerCase()) {
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'internal':
        return AppEnvironment.internal;
      case 'development':
      case 'dev':
      default:
        return AppEnvironment.development;
    }
  }

  static bool get isProduction => appEnvironment == AppEnvironment.production;

  /// Production never exposes the demo sign-in screens, whatever AUTH_MODE says.
  static AuthMode get authMode => resolveAuthMode();

  /// True only for non-production builds that still route through demo sign-in.
  static bool get usesDemoAuth => authMode == AuthMode.demo;

  static bool get usesAccountAuth => authMode == AuthMode.account;

  /// Local, non-live coach preview. Never available in production.
  static bool get enableAiPreview =>
      _resolveGate(enableAiPreviewRaw, defaultWhenUnset: !isProduction);

  /// Debug Integration Lab entry point. Still additionally gated by
  /// [kDebugMode] at the route and UI level.
  static bool get enableIntegrationLab =>
      _resolveGate(enableIntegrationLabRaw, defaultWhenUnset: kDebugMode);

  static bool get enableDeveloperMenu =>
      _resolveGate(enableDeveloperMenuRaw, defaultWhenUnset: false);

  /// Controls "Planned" rows/badges for features that do not work yet.
  static bool get showPlannedFeatures =>
      _resolveGate(showPlannedFeaturesRaw, defaultWhenUnset: !isProduction);

  /// Deterministic store-screenshot mode.
  ///
  /// Only available for `internal` builds when explicitly enabled. Production
  /// and development defaults keep this off. Forces fake Calendar/Health
  /// gateways and a fixed demo clock via [ReleaseCapabilities] / providers.
  static bool get storeScreenshotMode {
    if (isProduction) return false;
    if (appEnvironment != AppEnvironment.internal) return false;
    return _resolveGate(storeScreenshotModeRaw, defaultWhenUnset: false);
  }

  /// Production forces every preview gate off, regardless of dart-defines.
  static bool _resolveGate(String raw, {required bool defaultWhenUnset}) {
    if (isProduction) return false;
    final value = raw.trim().toLowerCase();
    if (value.isEmpty) return defaultWhenUnset;
    return value == 'true' || value == '1' || value == 'yes';
  }

  /// Production ships local persistence only — never fakes, never the API.
  static GoalsDataSource resolveGoalsDataSource({
    AppEnvironment? environment,
    String? raw,
  }) {
    if ((environment ?? appEnvironment) == AppEnvironment.production) {
      return GoalsDataSource.local;
    }
    switch ((raw ?? goalsDataSourceRaw).trim().toLowerCase()) {
      case 'api':
        return GoalsDataSource.api;
      case 'fake':
        return GoalsDataSource.fake;
      case 'local':
      default:
        return GoalsDataSource.local;
    }
  }

  static FinanceDataSource resolveFinanceDataSource({
    AppEnvironment? environment,
    String? raw,
  }) {
    if ((environment ?? appEnvironment) == AppEnvironment.production) {
      return FinanceDataSource.local;
    }
    switch ((raw ?? financeDataSourceRaw).trim().toLowerCase()) {
      case 'fake':
        return FinanceDataSource.fake;
      case 'local':
      default:
        return FinanceDataSource.local;
    }
  }

  static HabitsDataSource resolveHabitsDataSource({
    AppEnvironment? environment,
    String? raw,
  }) {
    if ((environment ?? appEnvironment) == AppEnvironment.production) {
      return HabitsDataSource.local;
    }
    switch ((raw ?? habitsDataSourceRaw).trim().toLowerCase()) {
      case 'fake':
        return HabitsDataSource.fake;
      case 'local':
      default:
        return HabitsDataSource.local;
    }
  }

  /// Production always talks to the real device calendar provider.
  static CalendarDataSource resolveCalendarDataSource({
    AppEnvironment? environment,
    String? raw,
  }) {
    final env = environment ?? appEnvironment;
    if (env == AppEnvironment.production) {
      return CalendarDataSource.system;
    }
    if (storeScreenshotMode && env == AppEnvironment.internal) {
      return CalendarDataSource.fake;
    }
    switch ((raw ?? calendarDataSourceRaw).trim().toLowerCase()) {
      case 'system':
        return CalendarDataSource.system;
      case 'fake':
      default:
        return CalendarDataSource.fake;
    }
  }

  /// Production always talks to HealthKit / Health Connect (read-only).
  static HealthDataSource resolveHealthDataSource({
    AppEnvironment? environment,
    String? raw,
  }) {
    final env = environment ?? appEnvironment;
    if (env == AppEnvironment.production) {
      return HealthDataSource.system;
    }
    if (storeScreenshotMode && env == AppEnvironment.internal) {
      return HealthDataSource.fake;
    }
    switch ((raw ?? healthDataSourceRaw).trim().toLowerCase()) {
      case 'system':
        return HealthDataSource.system;
      case 'fake':
      default:
        return HealthDataSource.fake;
    }
  }

  /// Auth mode for an arbitrary environment — production is always [account].
  static AuthMode resolveAuthMode({AppEnvironment? environment, String? raw}) {
    if ((environment ?? appEnvironment) == AppEnvironment.production) {
      return AuthMode.account;
    }
    switch ((raw ?? authModeRaw).trim().toLowerCase()) {
      case 'none':
        return AuthMode.none;
      case 'account':
        return AuthMode.account;
      case 'demo':
      default:
        return AuthMode.demo;
    }
  }

  static GoalsDataSource get goalsDataSource => resolveGoalsDataSource();

  static FinanceDataSource get financeDataSource => resolveFinanceDataSource();

  static HabitsDataSource get habitsDataSource => resolveHabitsDataSource();

  static CalendarDataSource get calendarDataSource =>
      resolveCalendarDataSource();

  static HealthDataSource get healthDataSource => resolveHealthDataSource();

  /// Whether first-run local stores may load bundled sample content.
  ///
  /// Production always starts empty so shipping builds never present demo Goals,
  /// Finance, Habits, or Today checklist items as the user's own data.
  /// Development and internal builds keep seeds for faster iteration.
  static bool get shouldSeedDemoContent => !isProduction;

  /// Fails fast on dart-define combinations that would ship demo data or demo
  /// auth in a production build. Call from bootstrap behind an `assert`.
  static void validate() {
    if (!isProduction) return;

    final problems = <String>[];
    if (goalsDataSourceRaw.trim().toLowerCase() == 'fake') {
      problems.add('GOALS_DATA_SOURCE=fake');
    }
    if (goalsDataSourceRaw.trim().toLowerCase() == 'api') {
      problems.add('GOALS_DATA_SOURCE=api (no cloud account in v1)');
    }
    if (financeDataSourceRaw.trim().toLowerCase() == 'fake') {
      problems.add('FINANCE_DATA_SOURCE=fake');
    }
    if (habitsDataSourceRaw.trim().toLowerCase() == 'fake') {
      problems.add('HABITS_DATA_SOURCE=fake');
    }
    if (_authModeExplicitlyDemo) {
      problems.add('AUTH_MODE=demo');
    }
    if (bool.hasEnvironment('STORE_SCREENSHOT_MODE') &&
        storeScreenshotModeRaw.trim().toLowerCase() == 'true') {
      problems.add('STORE_SCREENSHOT_MODE=true');
    }

    if (problems.isNotEmpty) {
      throw EnvironmentConfigError(
        'APP_ENV=production is incompatible with: ${problems.join(', ')}. '
        'Production resolves these to safe values, but the build defines '
        'should be corrected.',
      );
    }
  }

  /// `AUTH_MODE` defaults to `demo`, so only treat it as a production conflict
  /// when the build explicitly asked for it.
  static const bool _authModeExplicitlyDemo =
      bool.hasEnvironment('AUTH_MODE') &&
      String.fromEnvironment('AUTH_MODE') == 'demo';
}
