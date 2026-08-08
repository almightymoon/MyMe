/// Build-time environment for MeMy mobile.
///
/// Configure with `--dart-define`:
///
/// ```bash
/// # Goals data source: fake | local | api  (default: local)
/// --dart-define=GOALS_DATA_SOURCE=api
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
}
