# Health data flow

```
HealthKit / Health Connect
        │  read-only gateway
        ▼
PlatformHealthGateway (fake | system)
        │  normalize + aggregate in memory
        │  (dedupe by providerRecordId; prefer step totals API when present)
        ▼
HealthRepository → DailyHealthSummary
        │
        ├── Health screens
        └── Today Health section
```

## Classification

Wellness telemetry (non-clinical).

## Permission uncertainty

- **iOS:** HealthKit does not disclose which READ categories were approved. MeMy records `requestCompletedUnverified` and may attempt reads; UI copy explains this uncertainty.
- **Android:** Health Connect grants are verified per group.
- **Sleep:** Only total time asleep (`SLEEP_ASLEEP`) — no stage breakdown in product or UI.

## Leaves the device?

**No** in this milestone. Not sent to MeMy API, OpenAI, analytics, or ads.

## Logging

Only provider, operation, success/failure, duration, counts, sanitized error codes. Values, source device IDs, and sample IDs are redacted. Source attribution UI never displays opaque device IDs.

## Disconnect

Clears MeMy-derived Health cache and connection prefs. Does not modify the platform health store. Corrupt prefs flag `recoveryNeeded` instead of silently resetting to “never connected.”

## Deletion

User can Clear Health Cache from Settings / Connections.
