# Device calendar sync

## Scope

- iOS EventKit / Android Calendar Provider via `device_calendar` plugin
- Wrapped by `DeviceCalendarGateway`
- External events: import read-only
- MeMy-owned events: create/update/delete with explicit user choices
- Conflicts: never silent overwrite (Keep MeMy / Keep Device / Keep Both / Later)

## Persistence

Drift/SQLite (`calendar_database.dart`) — not SharedPreferences — for range queries, external IDs, links, conflicts, and migrations.

Unique: `(externalCalendarId, externalEventId)`.

## Modes

```bash
--dart-define=CALENDAR_DATA_SOURCE=fake    # default / CI
--dart-define=CALENDAR_DATA_SOURCE=system
```

## Sync window

Initial bounded pull: past 30 days → future 365 days (configurable).

## All-day events

Represented with `AllDayCalendarEventTime` (`LocalDate` start + exclusive end). Never local-midnight timestamps.

## Routes

`/calendar`, `/calendar/new`, `/calendar/connect`, `/calendar/connect/select`, `/calendar/conflicts`, `/calendar/event/:id`, `/calendar/event/:id/edit`

Quick Add → `/calendar/new`.
