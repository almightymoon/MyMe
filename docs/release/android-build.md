# Android Build (Release Candidate)

## Tooling

| Item | Value |
|---|---|
| Flutter | 3.44.9 |
| Dart | 3.12.2 |
| `applicationId` / `namespace` | `com.moontech.memy` |
| `minSdk` | `max(flutter.minSdkVersion, 26)` → **26** |
| `compileSdk` / `targetSdk` | Flutter defaults (**36** on current Flutter 3.44.9) |
| Version | `1.0.0+1` → versionName 1.0.0 / versionCode 1 |

Source: `apps/mobile/android/app/build.gradle.kts`.

## Production dart-defines

```bash
cd apps/mobile

flutter build appbundle --release \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=none
```

Optional but recommended for store contact:

```bash
  --dart-define=SUPPORT_EMAIL=you@your-domain.example
```

`SUPPORT_EMAIL` is **empty by default**. Owner must set a real inbox before relying on mailto contact in Help & Support.

Production resolution (forced regardless of other defines):

- Goals / Finance / Habits → `local`
- Calendar / Health → `system`
- No fake repos, no Integration Lab, no live AI / Coach Preview, no demo seed
- `STORE_SCREENSHOT_MODE` forced off (and rejected by `EnvironmentConfig.validate()` if set `true`)

## Signing — owner action required

`build.gradle.kts` currently assigns the **debug** keystore to the release build type for local convenience:

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("debug")
    }
}
```

**Do not upload a debug-signed AAB to Play as the production artifact.** Owner must:

1. Create a Play App Signing–compatible upload keystore.
2. Wire `signingConfigs.release` from env / `key.properties` (never commit secrets).
3. Enable Play App Signing in Play Console.
4. Rebuild the AAB with the upload key before production submission.

## Smoke commands (local)

```bash
flutter analyze
flutter test
flutter build apk --release \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=none
```

## Remote CI

Workflows exist under `.github/workflows/` (`mobile-ci.yml`, etc.). **Remote CI pass/fail was not verified in the session that authored this release pack.** Owner should confirm green checks on the release commit before store upload.

## Screenshot mode (not for production)

Deterministic screenshots use an **internal** build only:

```bash
flutter run \
  --dart-define=APP_ENV=internal \
  --dart-define=STORE_SCREENSHOT_MODE=true
```

Never ship `APP_ENV=production` with `STORE_SCREENSHOT_MODE=true`.
