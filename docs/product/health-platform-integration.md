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
| `requestCompletedUnverified` | **iOS** after successful permission sheet — Apple does not disclose READ grants |
| `requestCancelled` | **iOS** sheet dismissed / not authorized — **not** verified denial |
| `requestFailed` | Authorization call threw — **not** verified denial |
| `grantedVerified` / `deniedVerified` | **Android** Health Connect `hasPermissions` |
| `unavailable` / `needsSystemSettings` | Modeled for recovery UX |

Android refresh **rechecks** previously requested groups via `hasPermissions`
before querying; revoked groups clear from the current summary immediately.

Legacy permission JSON migration is **platform-aware** (`HealthPermissionMigrationService`):
iOS legacy grants → `requestCompletedUnverified` (never `grantedVerified`).

iOS copy must **not** say “access granted.” Prefer:

> Your Health access request is complete. Apple does not tell apps which read
> categories you approved. Available data will appear when present.

Default first-run selection: Activity, Heart, Sleep, Workouts. **Weight off**
until the user opts in.

## Identity & aggregation

- Composite identity: `sourcePlatform | metricType | providerRecordId`
  (`HealthSampleIdentity`) — same provider ID across metrics or platforms stays distinct
- Samples without a stable provider ID are kept but not treated as durable keys
- Steps prefer platform aggregate totals (`getTotalStepsInInterval`)
- Distance / active energy / exercise duration use typed aggregate APIs when
  available; otherwise raw + composite dedupe (never silent overlapping inflation)
- Source attribution via `SourceAttributionFormatter` — never invent “Apple
  Watch” without device-model metadata
- Aggregates may be labeled “Combined by Apple Health / Health Connect”

## Connection backup

Primary + last-known-good backup prefs (`memy_health_connection_primary` /
`memy_health_connection_backup`). Corrupt primary surfaces `recoveryNeeded`
with optional Restore Backup — never auto-restores silently. No sample values
in either payload.

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
