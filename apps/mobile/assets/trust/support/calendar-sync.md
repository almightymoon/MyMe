# Calendar sync basics

MeMy can show a local agenda and optionally sync with calendars on your device.

## Modes

- **Fake / demo mode** — in-memory calendar for CI and simulators.
- **System mode** — Drift SQLite cache plus the device calendar provider.

## What stays local

Titles, times, and sync metadata in MeMy’s cache stay on the device. This build does not upload calendar content to a MeMy backend or AI.

## Disconnect & wipe

Disconnecting clears MeMy connection configuration. Wiping the calendar cache removes MeMy’s local rows. It does **not** delete events from your phone’s calendar apps unless you explicitly choose a device-delete flow elsewhere.
