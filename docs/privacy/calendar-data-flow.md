# Calendar data flow

```
Device calendars (EventKit / Calendar Provider)
        │  gateway
        ▼
DeviceCalendarGateway (fake | system)
        │
        ▼
CalendarSyncService ⇄ Drift local DB (events, links, conflicts, config)
        │
        ├── Calendar screens
        └── Today schedule (ScheduleItem mapper)
```

## Classification

Personal schedule metadata (titles, times, locations). Treated as sensitive in logs (redacted).

## Cloud OAuth?

**Not in this phase.** No Google/Outlook tokens.

## Disconnect choices

- Remove MeMy imported cache only
- Keep MeMy-created device events
- Optionally remove MeMy-created device events after confirmation

Permission revocation alone never deletes device events.

## Conflicts

Both sides changed after last sync fingerprint → unresolved conflict UI.
