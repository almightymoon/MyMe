# MeMy mobile

Flutter client for MeMy (MoonTech) — **v1 local-first release candidate track**.

Organization / application id: `com.moontech.memy`  
Tagline: **Your Personal Life Companion.**

## Run (production-shaped)

```bash
flutter pub get
flutter run --dart-define=APP_ENV=production
```

Production forces: local Goals/Finance/Habits, system Calendar/Health, no demo
auth, no Integration Lab, no Coach Preview, empty first-run module seed.

## Run (development / CI default)

```bash
flutter pub get
flutter run
```

Data sources (defaults keep CI safe with fake Calendar/Health):

```bash
flutter run --dart-define=GOALS_DATA_SOURCE=local
flutter run --dart-define=FINANCE_DATA_SOURCE=local
flutter run --dart-define=HABITS_DATA_SOURCE=local
flutter run --dart-define=CALENDAR_DATA_SOURCE=fake
flutter run --dart-define=HEALTH_DATA_SOURCE=fake
# device integrations (requires permissions + Health Connect / HealthKit):
# --dart-define=CALENDAR_DATA_SOURCE=system
# --dart-define=HEALTH_DATA_SOURCE=system
```

See `docs/architecture/v1-release-configuration.md` and `docs/product/v1-scope.md`.

## Verify

```bash
dart format .
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
# macOS / CI (requires CocoaPods + iOS Simulator runtime):
# flutter build ios --simulator --no-codesign
```

**Platform floors (plugin-driven):** Android `minSdk` 26+, iOS deployment target 14.0+.

The HTML prototype at `/app` remains the visual design reference.
