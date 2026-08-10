# Integration beta release gate

Physical-device beta closure checklist for Device Calendar and read-only Health.

**Rule:** Do not mark any scenario Pass unless it was actually executed on hardware.
Cursor and CI prepare matrices and automated support only. Blank Pass/fail means unexecuted.

Related:

- [calendar-device-test-matrix.md](./calendar-device-test-matrix.md)
- [health-device-test-matrix.md](./health-device-test-matrix.md)
- [mobile-interaction-audit.md](./mobile-interaction-audit.md)

## Software gates (must be green before hardware)

| Gate | Status |
|------|--------|
| Flutter format / analyze / unit+widget tests | Required |
| Android debug APK | Required |
| iOS simulator build (`--no-codesign`) | Required where macOS available |
| API format / lint / unit / e2e | Required |
| Drift schema migrations (Calendar v3) | Required |
| Integration Lab absent from release navigation (`kDebugMode`) | Required |
| Diagnostics export redacted (no titles / Health values / device IDs) | Required |

## Calendar — required physical scenarios

Record for each: device model, OS, app build, plugin versions, date, tester, permission state, expected, actual, pass/fail, redacted issue link.

| Scenario | iPhone | Android |
|----------|--------|---------|
| Permission grant and revoke | | |
| iCloud calendar | | N/A |
| Google calendar account via device Calendar | | |
| Read-only subscribed calendar | | |
| Explicit writable destination | | |
| Create event | | |
| Update event | | |
| Delete event | | |
| App termination during create | | |
| App termination during update | | |
| App termination during delete | | |
| Multiple MeMy marker matches | | |
| Zero marker matches / unknown create | | |
| All-day event | | |
| Multi-day all-day event | | |
| Recurring occurrence | | |
| Timezone change | | |
| DST transition | | |
| Restart and state restoration | | |
| Failed lookup does not delete | | |
| Stale cached connection after provider failure | | |

## Health — required physical scenarios

| Scenario | iPhone | Android |
|----------|--------|---------|
| Phone without watch | | |
| Phone with paired watch | | |
| Health Connect installed | N/A | |
| Partial permission | | |
| Permission revocation (refresh detects) | | |
| iOS declined / cancelled request | | N/A |
| No data | | |
| Manual data | | |
| Automatic data | | |
| Platform aggregate steps | | |
| Platform aggregate distance | | |
| Platform aggregate active energy | | |
| Sleep duration (asleep only) | | |
| Source attribution truthful | | |
| Protected data unavailable | | |
| Restart | | |
| Config backup recovery | | |

## Execution log

| Date | Tester | Device | Result summary |
|------|--------|--------|----------------|
| — | — | — | **No physical-device scenarios executed in this milestone.** |

## Remaining release blockers

1. Physical Calendar matrices unexecuted.
2. Physical Health matrices unexecuted.
3. Real-device confirmation of EventKit / Health Connect aggregate accuracy.
4. Real-device confirmation of create/update/delete crash recovery.

## Non-claims

This gate does **not** claim:

- Production readiness
- App Store / Play approval
- Completed physical validation
- Background Health access
- Health write access
- Cloud Calendar or Health sync
