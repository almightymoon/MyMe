# MeMy mobile interaction audit (integrations)

**Updated:** 2026-08-10 (device-integration hardening)  
**Scope:** Calendar, Health, Connected Apps, Today integration cards, diagnostics.

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
| Integration Lab | wired in **debug only** → `/settings/connections/lab` |

## Calendar

| Control | Status |
|---------|--------|
| Connect / select / sync / conflicts / add / edit / copy | wired |
| Imported event Edit/Delete | removed (read-only; Copy allowed) |
| Empty notification-style dead icons | none found |

## Health

| Control | Status |
|---------|--------|
| Connect / permissions / workouts / disconnect | wired |
| Overview refresh | wired (replaces dead notifications control) |
| Disclaimer | always visible |

## Today

| Control | Status |
|---------|--------|
| Health card connect / open | wired |
| Calendar schedule from repository | wired |
| Section failure isolation | Goals/Finance/Habits survive Calendar/Health errors |

## Diagnostics redaction

Export/copy JSON includes only operational counts, statuses, schema versions,
and sanitized error **codes**. Never titles, notes, Health values, or device IDs.

## Known remaining placeholders (non-integration)

Settings rows without routes still show demo snackbars (Profile password,
Appearance, etc.) — accepted outside this milestone.
