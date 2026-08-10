# Device calendar sync

## Scope

- iOS EventKit / Android Calendar Provider via `device_calendar` plugin
- Wrapped by `DeviceCalendarGateway`
- External events: import read-only (enforced in repository/controllers, not only UI)
- MeMy-owned events: create/update/delete with explicit user choices
- Conflicts: never silent overwrite (Keep MeMy / Keep Device / Keep Both / Later)

## Persistence

Drift/SQLite schema **v2** (`calendar_database.dart`) — not SharedPreferences —
for range queries, external IDs, links, conflicts, sync outbox, and migrations.

Unique: `(externalCalendarId, externalEventId)`.

### Config (v2)

- `readableCalendarIds` — multi-select import sources (may include read-only)
- `defaultWritableCalendarId` — single write target (never inferred from list order)
- `dedicatedMeMyCalendarId` — optional on-device MeMy calendar
- Rolling windows: `syncPastWindowDays` (default 30) / `syncFutureWindowDays` (default 365)
- `lastSuccessfulPullAt` / `lastSuccessfulPushAt` tracked independently

v1 `selectedCalendarIds` migrate to readable only; writable stays null until the
user confirms a destination.

## Sync window

**Rolling** relative to `AppClock` on every full pull:

`[now − pastWindow, now + futureWindow)`.

Frozen connect-time anchors are deprecated and unused. Events outside the
active window are **not** treated as deleted.

## Missing-event safety

`CalendarReadBatch.completeness` must be `complete` before absence counting.

1. First complete-batch miss → `suspectedMissing` (no hard delete)
2. Second miss + failed `getEventById` → `confirmedMissing`
3. Imported → soft-hide (`hidden`); MeMy-owned → `externallyMissing`
4. Partial/unknown batches, permission failures, and out-of-range events never
   advance missing counts

## Push outbox / idempotency

`CalendarSyncOperations` table: prepare → inFlight → completed.

Creates carry `memy://calendar-event/<id>` markers. Unknown outcomes after
inFlight do **not** auto-retry. Restart reconciles stuck `inFlight` creates via
marker lookup.

## Connection restore

`CalendarIntegrationBootstrapService` runs after startup: reloads config,
checks permission/calendars, hydrates `IntegrationConnectionRegistry`,
reconciles in-flight creates. Users do not reconnect after every restart.

## Modes

```bash
--dart-define=CALENDAR_DATA_SOURCE=fake    # default / CI
--dart-define=CALENDAR_DATA_SOURCE=system
```

## All-day events

Represented with `AllDayCalendarEventTime` (`LocalDate` start + exclusive end).
Never local-midnight timestamps.

## Routes

`/calendar`, `/calendar/new`, `/calendar/connect`, `/calendar/connect/select`,
`/calendar/conflicts`, `/calendar/event/:id`, `/calendar/event/:id/edit`

Quick Add → `/calendar/new`.

Diagnostics: `/settings/connections/diagnostics` (redacted).
Debug lab: `/settings/connections/lab` (debug builds only).

## Physical-device status

See `docs/quality/calendar-device-test-matrix.md`. Scenarios remain **unexecuted**
until manually run on hardware — do not treat matrices as pass evidence.
