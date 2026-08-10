# Health device test matrix

Manual acceptance — physical devices. Never paste raw heart-rate, sleep, or workout values into tickets/logs.

## iPhone

| Scenario | Expected | Result | Notes |
|----------|----------|--------|-------|
| No Apple Watch | Platform data still readable if present | | |
| Paired Apple Watch | Source attribution honest | | |
| Partial permissions | Only granted groups render | | |
| Denied / revoked | Clear CTA; no fake numbers | | |
| Protected data unavailable | Typed error; retry later | | |
| No data | Empty state ≠ permission denied | | |
| Manual entry in Health | Identified when metadata available | | |
| Sleep overnight | Assigned per documented wake-up rule | | |
| Workout | Listed with duration/type | | |

## Android

| Scenario | Expected | Result | Notes |
|----------|----------|--------|-------|
| Android 14+ Health Connect | Connect flow works | | |
| Android 13 + HC provider | Available when installed | | |
| Unsupported / update required | Typed unavailable/updateRequired | | |
| Partial / revoked permissions | Partial UI | | |
| Multi-source apps | Dedup by provider IDs | | |
| Manual record | Preference to hide | | |

**Physical-device runs:** not executed in this automation session unless checked off above.
