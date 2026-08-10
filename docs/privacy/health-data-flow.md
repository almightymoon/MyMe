# Health data flow

```
HealthKit / Health Connect
        │  read-only gateway
        ▼
PlatformHealthGateway (fake | system)
        │  normalize + aggregate in memory
        ▼
HealthRepository → DailyHealthSummary
        │
        ├── Health screens
        └── Today Health section
```

## Classification

Wellness telemetry (non-clinical).

## Leaves the device?

**No** in this milestone. Not sent to MeMy API, OpenAI, analytics, or ads.

## Logging

Only provider, operation, success/failure, duration, counts, sanitized error codes. Values, source device IDs, and sample IDs are redacted.

## Disconnect

Clears MeMy-derived Health cache and connection prefs. Does not modify the platform health store.

## Deletion

User can Clear Health Cache from Settings / Connections.
