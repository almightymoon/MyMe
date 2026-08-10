# Health platform integration (read-only)

## Scope

- iOS: Apple HealthKit (read)
- Android: Health Connect (read)
- Metrics: steps, distance, active energy, heart rate, resting heart rate, sleep, workouts; optional weight
- Not requested: ECG, BP, glucose, SpO2, clinical records, medications, reproductive health, nutrition writes

## Packages

| Package | Role |
|---------|------|
| `health` ^13.3.1 | Plugin behind `SystemPlatformHealthGateway` |
| `permission_handler` ^11.4.0 | Android activity recognition / auxiliary prompts |

Domain code depends on `PlatformHealthGateway`, never on plugin sample classes.

## Platform requirements

| Platform | Requirement | Why |
|----------|-------------|-----|
| Android `minSdk` | **26+** | Required by the `health` plugin / Health Connect client |
| iOS deployment target | **14.0+** | Required by the `health` iOS pod |
| Health Connect app | Android 9+ (API 28+) for the store UI | Older devices get an unavailable / update-required state |

MeMy does not request Health Connect background or extended-history permissions in this milestone.

## Modes

```bash
--dart-define=HEALTH_DATA_SOURCE=fake    # default / CI
--dart-define=HEALTH_DATA_SOURCE=system  # device
```

## Aggregation

Pure `HealthAggregationService` computes daily summaries from normalized samples. No opaque Health Score. No diagnosis language.

## Storage

Platform store is source of truth. MeMy may keep connection prefs + short-lived derived daily summaries; disconnect clears derived cache. No indefinite raw sample retention. No backend upload. No AI upload.

## UI

- `/health` overview
- `/health/connect` + permission selection
- `/health/workouts`
- Today Health card (section-isolated)
- Medical disclaimer on Health overview
