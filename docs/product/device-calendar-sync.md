# Device calendar sync

## Scope

- iOS EventKit / Android Calendar Provider via `device_calendar` plugin
- Wrapped by `DeviceCalendarGateway`
- External events: import read-only (enforced in repository/controllers, not only UI)
- MeMy-owned events: create/update/delete with explicit user choices
- Conflicts: never silent overwrite (Keep MeMy / Keep Device / Keep Both / Later)

## Persistence

Drift/SQLite schema **v3** (`calendar_database.dart`) — not SharedPreferences —
for range queries, external IDs, links, conflicts, sync outbox, create-recovery
cases, lookup dispositions, and migrations.

Unique: `(externalCalendarId, externalEventId)`.

### Config (v3)

- `readableCalendarIds` — multi-select import sources (may include read-only)
- `defaultWritableCalendarId` — single write target (never inferred from list order)
- `dedicatedMeMyCalendarId` — optional on-device MeMy calendar
- Rolling windows: `syncPastWindowDays` (default 30) / `syncFutureWindowDays` (default 365)
- `lastSuccessfulPullAt` / `lastSuccessfulPushAt` tracked independently
- Lookup disposition columns on links; `calendar_create_recovery_cases` for
  ambiguous create outcomes

v1 `selectedCalendarIds` migrate to readable only; writable stays null until the
user confirms a destination. v2→v3 adds recovery + lookup metadata.

## Sync window

**Rolling** relative to `AppClock` on every full pull:

`[now − pastWindow, now + futureWindow)`.

Frozen connect-time anchors are deprecated and unused. Events outside the
active window are **not** treated as deleted.

## Typed direct lookup

`DeviceCalendarGateway.getEventById` returns `CalendarEventLookupResult`:

| Result | Meaning |
|--------|---------|
| `CalendarEventFound` | Present |
| `CalendarEventNotFound` | Absence verified (complete batch / map miss) |
| `CalendarEventLookupUnknown` | Provider failure / incomplete knowledge |
| `CalendarEventLookupUnsupported` | Platform cannot verify (e.g. partial batch) |

Unknown/unsupported **never** confirm deletion.

## Missing-event safety

`CalendarReadBatch.completeness` must be `complete` before absence counting.

1. First complete-batch miss → `suspectedMissing` (no hard delete)
2. Second miss + typed `getEventById`:
   - Found → back to `present`
   - Unknown/Unsupported → stay suspected / `lookupUnknown` (no tombstone)
   - NotFound → imported soft-hide; MeMy-owned → `externallyMissingMeMyOwned`
3. Partial/unknown batches, permission failures, and out-of-range events never
   advance missing counts

## Marker reconciliation & create recovery

Marker search returns `CalendarMarkerSearchResult` (never `found.first`):

| Matches | Outcome |
|---------|---------|
| 0 | `unknownOutcome` + recovery case `noMatchUnknownOutcome` |
| 1 | Link + complete |
| 2+ | `requiresUserAction` + recovery case `multipleMarkerMatches` |

User recovery UI: `/calendar/recovery` (search again, link one candidate, keep
local only, retry create after confirmation, dismiss, remove MeMy event).
Deletion of device duplicates requires explicit confirmation.

## Push outbox / idempotency

`CalendarSyncOperations` table for **create, update, and delete**:

`prepared` → `inFlight` → `completed` | `retryableFailure` | `unknownOutcome` |
`permanentlyFailed` | `requiresUserAction`.

Creates carry `memy://calendar-event/<id>` markers. Unknown outcomes after
inFlight do **not** auto-retry creates. Restart reconciles stuck `inFlight`
ops via marker lookup (create) or typed ID lookup (update/delete).

## Connection restore

`CalendarIntegrationBootstrapService` runs after startup: reloads config,
checks permission/calendars, hydrates `IntegrationConnectionRegistry`,
reconciles in-flight ops.

Hydration **never** reports healthy `connected` after a failed provider check.
Degraded statuses include `staleCacheAvailable`, `partiallyConnected`,
`permissionStatusUnknown`, `providerUnavailable`, `configurationInvalid`.

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
`/calendar/conflicts`, `/calendar/recovery`, `/calendar/event/:id`,
`/calendar/event/:id/edit`

Quick Add → `/calendar/new`.

Diagnostics: `/settings/connections/diagnostics` (redacted).
Debug lab: `/settings/connections/lab` (debug builds only).

## Physical-device status

See `docs/quality/calendar-device-test-matrix.md`. Scenarios remain **unexecuted**
until manually run on hardware — do not treat matrices as pass evidence.
