# v1 Release Configuration

How the MeMy mobile app decides what it is allowed to show and do. Two layers:

1. **`EnvironmentConfig`** (`lib/core/config/environment_config.dart`) reads
   `--dart-define` values and resolves them to safe values.
2. **`ReleaseCapabilities`** (`lib/core/config/release_capabilities.dart`)
   turns those into typed feature flags the UI reads through
   `releaseCapabilitiesProvider`.

Nothing in the UI should branch on `kDebugMode` alone for product surface; ask
`ReleaseCapabilities` instead.

## Environments

`--dart-define=APP_ENV=development|internal|production` (default
`development`, so CI and existing tests keep their behaviour).

| | development | internal | production |
|---|---|---|---|
| Demo sign in | yes (default) | yes | **never** |
| First-run onboarding | when `AUTH_MODE=none` | yes | **always** |
| Coach Preview | yes | yes | no |
| Wardrobe / Body | yes | yes | no |
| Log Meal in Quick Add | yes | yes | no |
| Planned rows and badges | yes | yes | no |
| Integration Lab | debug only | debug + `ENABLE_INTEGRATION_LAB` | no |
| Goals / Finance / Habits | dart-define | dart-define | **local only** |
| Demo content seed | yes | yes | **no** (empty first run) |
| Calendar / Health | dart-define (default `fake`) | dart-define | **system only** |

## Dart-defines

| Define | Values | Default | Production behaviour |
|---|---|---|---|
| `APP_ENV` | `development`, `internal`, `production` | `development` | — |
| `AUTH_MODE` | `demo`, `none` | `demo` | forced to `none` |
| `ENABLE_AI_PREVIEW` | `true`/`false` | on outside production | forced off |
| `ENABLE_INTEGRATION_LAB` | `true`/`false` | `kDebugMode` | forced off |
| `ENABLE_DEVELOPER_MENU` | `true`/`false` | `false` | forced off |
| `SHOW_PLANNED_FEATURES` | `true`/`false` | on outside production | forced off |
| `GOALS_DATA_SOURCE` | `fake`, `local`, `api` | `local` | forced `local` |
| `FINANCE_DATA_SOURCE` | `fake`, `local` | `local` | forced `local` |
| `HABITS_DATA_SOURCE` | `fake`, `local` | `local` | forced `local` |
| `CALENDAR_DATA_SOURCE` | `fake`, `system` | `fake` | forced `system` |
| `HEALTH_DATA_SOURCE` | `fake`, `system` | `fake` | forced `system` |

"Forced" means the resolver ignores the define — a production build physically
cannot select a fake repository or the demo sign-in screens.

## Validation

`EnvironmentConfig.validate()` throws `EnvironmentConfigError` when a
production build was configured with `GOALS_DATA_SOURCE=fake|api`,
`FINANCE_DATA_SOURCE=fake`, `HABITS_DATA_SOURCE=fake`, or an explicit
`AUTH_MODE=demo`. `bootstrap()` calls it inside an `assert`, so debug and
profile builds fail fast while release builds still run with the safe
resolved values.

## Running each configuration

Development (the default — nothing to pass):

```bash
flutter run
```

Internal build with the coach preview and Integration Lab:

```bash
flutter run \
  --dart-define=APP_ENV=internal \
  --dart-define=ENABLE_AI_PREVIEW=true \
  --dart-define=ENABLE_INTEGRATION_LAB=true
```

Production (v1 shipping configuration):

```bash
flutter build apk --release \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=none

flutter build ipa --release \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=none
```

`CALENDAR_DATA_SOURCE` and `HEALTH_DATA_SOURCE` do not need to be passed for
production: both resolve to `system` automatically. Passing them is harmless.

## Testing the production surface

Tests override the provider rather than rebuilding with dart-defines:

```dart
await pumpMemyApp(
  tester,
  overrides: [
    releaseCapabilitiesProvider.overrideWithValue(
      ReleaseCapabilities.production(),
    ),
  ],
);
```

Data-source resolution is verified directly with the `environment:`/`raw:`
parameters on `EnvironmentConfig.resolve*DataSource`, so no separate
dart-define test run is required. See
`test/core/config/release_configuration_test.dart`.
