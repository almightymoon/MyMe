# MeMy mobile interaction audit (integrations)

**Updated:** 2026-08-10 (physical-device beta closure)  
**Scope:** Calendar, Health, Connected Apps, Today integration cards, diagnostics, create recovery.

| Status | Meaning |
|--------|---------|
| wired | Navigates or mutates real state |
| planned | Explicit “coming later” explanation |
| removed | Control deleted |

## Connected Apps (`/settings/connections`)

| Control | Status |
|---------|--------|
| Calendar row | wired → calendar or connect |
| Health row | wired → `/health` |
| Integration diagnostics | wired → `/settings/connections/diagnostics` |
| Calendar create recovery (when unresolved) | wired → `/calendar/recovery` |
| Integration Lab | wired in **debug only** → `/settings/connections/lab` |

## Calendar

| Control | Status |
|---------|--------|
| Connect / select / sync / conflicts / recovery / add / edit / copy | wired |
| Recovery: search again / link candidate / keep local / retry create / dismiss / remove | wired |
| Imported event Edit/Delete | removed (read-only; Copy allowed) |
| Empty notification-style dead icons | none found |

## Health

| Control | Status |
|---------|--------|
| Connect / permissions / workouts / disconnect | wired |
| Overview refresh | wired (replaces dead notifications control) |
| Restore backup (when recoveryNeeded) | wired |
| Disclaimer | always visible |

## Today

| Control | Status |
|---------|--------|
| Health card connect / open | wired |
| Calendar schedule from repository | wired |
| Section failure isolation | Goals/Finance/Habits survive Calendar/Health errors |

## Diagnostics

| Control | Status |
|---------|--------|
| Export / copy redacted JSON | wired |
| Calendar create recovery count + link | wired |
| Health backupAvailable / recoveryNeeded | wired |

## Diagnostics redaction

Export/copy JSON includes only operational counts, statuses, schema versions,
and sanitized error **codes**. Never titles, notes, Health values, or device IDs.

## Explicitly out of scope (not dead — deferred)

Google/Outlook OAuth, Health write/background, vendor wearables, AI on Health data.

## Known remaining placeholders (non-integration)

Settings rows without routes still show demo snackbars (Profile password,
Appearance, etc.) — accepted outside this milestone.
