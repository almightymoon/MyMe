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
# optional in-memory demos:
# --dart-define=GOALS_DATA_SOURCE=fake
# --dart-define=FINANCE_DATA_SOURCE=fake
```

Finance is local/fake only in this milestone (no bank sync, loans, or Finance API). See `docs/product/finance-feature.md`.

## Verify

```bash
dart format .
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

The HTML prototype at `/app` remains the visual design reference.
