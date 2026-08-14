# Health Store Declarations

## Product facts

- MeMy reads **selected** health metrics for a personal wellness dashboard.
- MeMy **never writes** to HealthKit or Health Connect.
- Metrics in scope: steps, distance, active calories, heart rate, resting heart rate, sleep, weight, workouts / exercise.
- No medical diagnosis, treatment, or device claims.
- No direct wearable vendor SDKs (Garmin, Fitbit, Whoop, etc.).

## Apple (HealthKit)

| Item | Status |
|---|---|
| Entitlement `com.apple.developer.healthkit` | Required on App ID |
| `NSHealthShareUsageDescription` | Present |
| `NSHealthUpdateUsageDescription` | Omitted intentionally |
| App Review notes | Explain read-only; permission only after Connect |
| Medical claims in listing | **Forbidden** — do not claim diagnosis/cure |

## Google Play (Health Connect)

| Item | Status |
|---|---|
| `READ_*` health permissions | Declared; no `WRITE_*` |
| `ACTIVITY_RECOGNITION` | Declared for Steps |
| Health Connect permission rationale / usage activity | Declared in manifest |
| Play Console health declarations | Complete when submitting; link Privacy Policy |
| Medical claims in listing | **Forbidden** |

## In-app legal

Health disclaimer remains **Draft**: `apps/mobile/assets/trust/legal/health-disclaimer.md`. Owner/legal must approve before treating as binding.

## Reviewer guidance (short)

> MeMy optionally connects to Apple Health / Health Connect to **display** activity and wellness summaries the user already stores on device. MeMy does not write health data, does not upload samples to MeMy servers, and does not provide medical advice.
