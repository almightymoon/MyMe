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
/// ```
enum GoalsDataSource { fake, local, api }

enum FinanceDataSource { fake, local }

enum HabitsDataSource { fake, local }

enum CalendarDataSource { fake, system }

enum HealthDataSource { fake, system }

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

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 20);

  static GoalsDataSource get goalsDataSource {
    switch (goalsDataSourceRaw.trim().toLowerCase()) {
      case 'api':
        return GoalsDataSource.api;
      case 'fake':
        return GoalsDataSource.fake;
      case 'local':
      default:
        return GoalsDataSource.local;
    }
  }

  static FinanceDataSource get financeDataSource {
    switch (financeDataSourceRaw.trim().toLowerCase()) {
      case 'fake':
        return FinanceDataSource.fake;
      case 'local':
      default:
        return FinanceDataSource.local;
    }
  }

  static HabitsDataSource get habitsDataSource {
    switch (habitsDataSourceRaw.trim().toLowerCase()) {
      case 'fake':
        return HabitsDataSource.fake;
      case 'local':
      default:
        return HabitsDataSource.local;
    }
  }

  static CalendarDataSource get calendarDataSource {
    switch (calendarDataSourceRaw.trim().toLowerCase()) {
      case 'system':
        return CalendarDataSource.system;
      case 'fake':
      default:
        return CalendarDataSource.fake;
    }
  }

  static HealthDataSource get healthDataSource {
    switch (healthDataSourceRaw.trim().toLowerCase()) {
      case 'system':
        return HealthDataSource.system;
      case 'fake':
      default:
        return HealthDataSource.fake;
    }
  }
}
