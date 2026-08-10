# Health platform integration (read-only)

## Scope

- iOS: Apple HealthKit (read)
- Android: Health Connect (read)
- Metrics: steps, distance, active energy, heart rate, resting heart rate,
  sleep (**total asleep only** — no stage UI claims), workouts; optional weight
- Not requested: ECG, BP, glucose, SpO2, clinical records, medications,
  reproductive health, nutrition writes

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
| Health Connect app | Android 9+ (API 28+) for the store UI | Older devices get unavailable |

MeMy does not request Health Connect background or extended-history permissions.

## Permission model (truthful)

`HealthPermissionDisposition` per group:

| Disposition | Typical platform |
|-------------|------------------|
| `notRequested` | Never asked |
| `requestCompletedUnverified` | **iOS** after permission sheet — Apple does not disclose READ grants |
| `grantedVerified` / `deniedVerified` | **Android** Health Connect `hasPermissions` |
| `unavailable` / `needsSystemSettings` | Modeled for recovery UX |

iOS copy must **not** say “access granted.” Prefer:

> Your Health access request is complete. Apple does not tell apps which read
> categories you approved. Available data will appear when present.

Default first-run selection: Activity, Heart, Sleep, Workouts. **Weight off**
until the user opts in.

## Identity & aggregation

- Samples carry `providerRecordId` when the plugin supplies a UUID
- Deduplicate raw samples by stable provider ID (not timestamp+value alone)
- Steps prefer platform aggregate totals (`getTotalStepsInInterval`); distance
  and active energy use raw + dedupe when no aggregate is available
- Source attribution via `SourceAttributionFormatter` — never invent “Apple
  Watch” without device-model metadata

## Sleep

**Total asleep only** (`SLEEP_ASLEEP`). No stage breakdown in this milestone.
UI labels say “Sleep (asleep).”

## Modes

```bash
--dart-define=HEALTH_DATA_SOURCE=fake    # default / CI
--dart-define=HEALTH_DATA_SOURCE=system  # device
```

## Storage

Platform store is source of truth. Durable prefs: connection/onboarding,
dispositions, last refresh, schema version, recovery flag. No indefinite raw
sample retention. Disconnect clears derived cache. No backend/AI upload.

Corrupt prefs → `recoveryNeeded` (not silently “never connected”).

## UI

- `/health` overview (refresh action — no dead notification control)
- `/health/connect` + permission selection
- `/health/workouts`
- Today Health card (section-isolated)
- Medical/wellness disclaimer on Health screens
- Diagnostics: `/settings/connections/diagnostics`

## Physical-device status

See `docs/quality/health-device-test-matrix.md`. Scenarios remain **unexecuted**
until manually run on hardware.
