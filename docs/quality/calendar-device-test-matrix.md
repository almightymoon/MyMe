# Calendar device test matrix

Manual acceptance — physical devices. Record OS, account type, result, redacted notes.

## iOS

| Scenario | Expected | Result | Notes |
|----------|----------|--------|-------|
| No permission | Connect CTA; no silent request at launch | | |
| Full calendar access granted | Calendars listed; selection works | | |
| Permission revoked in Settings | Disconnected / manage access; cache retained until user clears | | |
| iCloud calendar | Import read-only external events | | |
| Google account in iOS Calendar | Import with source label | | |
| Subscribed read-only calendar | Cannot set as write target | | |
| Create MeMy event | Appears in MeMy + device calendar | | |
| Edit in system Calendar | Sync pull updates MeMy | | |
| Edit both sides | Conflict sheet; no silent overwrite | | |
| All-day event | Date-only rendering | | |
| DST transition event | Correct local display | | |
| Device timezone change | Timed events shift correctly | | |

## Android

| Scenario | Expected | Result | Notes |
|----------|----------|--------|-------|
| No permission | Connect CTA | | |
| Grant READ/WRITE | Selection + writable target | | |
| Revoke permission | Safe disconnect UX | | |
| Google account calendar | Import | | |
| Local calendar | Import / write when allowed | | |
| Read-only calendar | Not writable destination | | |
| Create / edit / delete MeMy event | Explicit deletion choices | | |
| Conflict | Conflict UI | | |
| All-day / DST / timezone | Correct | | |

**Physical-device runs:** not executed in this automation session unless checked off above.
