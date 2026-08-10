# Local data vs backend data

MeMy stores most personal information on your device. Some Goals builds also
talk to a MeMy API.

## Local MeMy data

Stored on this phone or tablet:

- Goals (when `GOALS_DATA_SOURCE=local` or `fake`)
- Finance transactions and categories
- Habits and check-ins
- MeMy calendar cache and MeMy-authored local events
- Health connection configuration (not raw samples)
- Appearance preferences

**Delete local data** only removes MeMy-owned local records and caches.

## Backend Goals

When Goals use the API (`GOALS_DATA_SOURCE=api`):

- Authoritative Goals live on the MeMy backend.
- This device may keep a **local cache**.
- Local wipe clears the cache only. Backend Goals remain.
- There is no production account-deletion flow in this build.

## External platforms

These are **not** deleted by MeMy local wipe:

- Events that already exist in your device calendars
- Apple Health / Health Connect records

Deleting MeMy-created device calendar events is a separate, explicit Calendar
action and is never part of “Delete all local MeMy data”.

## Export completeness

Export version 2 includes app version, build, data-source modes, and counts.
API Goals export is a **cached snapshot**, not a complete backend account
export, and is labeled with a warning.
