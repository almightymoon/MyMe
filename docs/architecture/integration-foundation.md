# Integration foundation

Shared domain for Connected Apps & Devices.

## Location

`apps/mobile/lib/core/integrations/`

- `domain/` — providers, connection status, sync results, typed errors, log redaction
- `application/providers/` — connection composition for Settings
- `presentation/` — shared connection UI pieces when needed

## Rules

1. Flutter plugin types never enter domain entities.
2. Every native API is behind a MeMy gateway (`DeviceCalendarGateway`, `PlatformHealthGateway`).
3. Fake gateways are the CI default (`CALENDAR_DATA_SOURCE=fake`, `HEALTH_DATA_SOURCE=fake`).
4. Operational logs use `LogRedaction` — never event titles, notes, attendees, health values, or device IDs.
5. Calendar and Health permission prompts are separate user flows.
6. Calendar missing-event inference requires complete read batches only.
7. HealthKit READ grants stay `requestCompletedUnverified` — never claim verified grant on iOS.
8. Diagnostics (`/settings/connections/diagnostics`) export redacted operational JSON only.
9. Integration Lab (`/settings/connections/lab`) is debug-build only.

## Shared infrastructure

| Concern | Location |
|---------|----------|
| `AppClock` / `appClockProvider` | `lib/core/domain/clock`, `lib/core/application/providers/core_providers.dart` |
| `LocalDate` | `lib/core/domain/value_objects/local_date.dart` |
| `sharedPreferencesProvider` / `uuidProvider` | `core_providers.dart` |
| Diagnostics report | `lib/core/integrations/domain/integration_diagnostics_report.dart` |

## Planned providers (UI only)

Google Calendar, Outlook, Garmin, Fitbit, Oura, WHOOP appear as unavailable/planned on `/settings/connections`.

## Physical-device vs foundation

Integration foundation + fake-gateway CI tests are implemented. Physical-device
matrices under `docs/quality/*-device-test-matrix.md` remain **unexecuted** until
hardware QA — do not treat blank Pass/fail columns as passes.
