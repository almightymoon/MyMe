# Calendar device test matrix

Manual acceptance — physical devices only. **Do not mark Pass unless executed.**

| Column | Meaning |
|--------|---------|
| Device / OS | Model + OS version |
| Provider | Plugin / calendar account context |
| Build | App build number |
| Permission | none / full / revoked |
| Expected | Spec expectation |
| Actual | What happened |
| Pass/fail | blank until run |
| Issue | Redacted ticket/link |
| Tester / Date | Who + when |

## iOS

| Scenario | Device / OS | Provider | Build | Permission | Expected | Actual | Pass/fail | Issue | Tester | Date |
|----------|-------------|----------|-------|------------|----------|--------|-----------|-------|--------|------|
| No permission | | | | none | Connect CTA; no silent request at launch | | | | | |
| Full calendar access | | | | full | Calendars listed; selection works | | | | | |
| Permission revoked | | | | revoked | Manage access; cache labeled stale | | | | | |
| iCloud calendar | | | | full | Import read-only external events | | | | | |
| Google account in iOS Calendar | | | | full | Import with safe source label | | | | | |
| Subscribed read-only calendar | | | | full | Shown readable; not writable destination | | | | | |
| Dedicated MeMy calendar | | | | full | Create/select MeMy write target | | | | | |
| Create MeMy event | | | | full | Appears in MeMy + device | | | | | |
| Edit in system Calendar | | | | full | Pull updates MeMy | | | | | |
| Edit both sides | | | | full | Conflict sheet; no silent overwrite | | | | | |
| All-day one-day | | | | full | Date-only rendering | | | | | |
| Multi-day all-day | | | | full | Exclusive end preserved | | | | | |
| DST transition | | | | full | Correct local display | | | | | |
| Device timezone change | | | | full | Timed events shift correctly | | | | | |
| Recurring instance | | | | full | Read-only occurrence display | | | | | |
| Reminder | | | | full | Mapped when plugin supports | | | | | |
| Kill app during create | | | | full | No duplicate after restart reconcile | | | | | |
| Restart after connect | | | | full | Connection restored without reconnect | | | | | |

## Android

| Scenario | Device / OS | Provider | Build | Permission | Expected | Actual | Pass/fail | Issue | Tester | Date |
|----------|-------------|----------|-------|------------|----------|--------|-----------|-------|--------|------|
| No permission | | | | none | Connect CTA | | | | | |
| Grant READ/WRITE | | | | full | Selection + writable target | | | | | |
| Revoke permission | | | | revoked | Safe disconnect UX | | | | | |
| Google account calendar | | | | full | Import | | | | | |
| Local device calendar | | | | full | Import / write when allowed | | | | | |
| Read-only calendar | | | | full | Not writable destination | | | | | |
| Writable target removed | | | | full | Error / reselect required | | | | | |
| Create / edit / delete | | | | full | Explicit deletion choices | | | | | |
| Conflict | | | | full | Conflict UI | | | | | |
| All-day / DST / timezone | | | | full | Correct | | | | | |
| Recurring event | | | | full | Read-only | | | | | |
| Kill during sync | | | | full | Outbox recoverable; no dup create | | | | | |
| Duplicate-retry verification | | | | full | Unknown outcome not auto-retried | | | | | |

**Physical-device runs:** not executed in automation. Leave Pass/fail blank until hardware QA.
