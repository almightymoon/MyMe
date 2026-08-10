# MeMy mobile

Flutter production foundation for MeMy (MoonTech).

Organization / application id: `com.moontech.memy`

## Run

```bash
flutter pub get
flutter run
```

Data sources (defaults are local SharedPreferences):

```bash
flutter run --dart-define=GOALS_DATA_SOURCE=local
flutter run --dart-define=FINANCE_DATA_SOURCE=local
flutter run --dart-define=HABITS_DATA_SOURCE=local
flutter run --dart-define=CALENDAR_DATA_SOURCE=fake
flutter run --dart-define=HEALTH_DATA_SOURCE=fake
# device integrations (requires permissions + Health Connect / HealthKit):
# --dart-define=CALENDAR_DATA_SOURCE=system
# --dart-define=HEALTH_DATA_SOURCE=system
# optional in-memory demos:
# --dart-define=GOALS_DATA_SOURCE=fake
# --dart-define=FINANCE_DATA_SOURCE=fake
# --dart-define=HABITS_DATA_SOURCE=fake
```

Finance is local/fake only in this milestone (no bank sync, loans, or Finance API). See `docs/product/finance-feature.md`.
Habits are local/fake only in this milestone (no Habits API or notifications). See `docs/product/habits-feature.md`.
Calendar and Health default to **fake** gateways in CI; use `system` on devices. See `docs/product/device-calendar-sync.md` and `docs/product/health-platform-integration.md`.

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
