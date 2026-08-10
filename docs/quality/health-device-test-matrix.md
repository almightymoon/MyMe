# Health device test matrix

Manual acceptance — physical devices only. **Do not mark Pass unless executed.**

| Column | Meaning |
|--------|---------|
| Device / OS | Model + OS version |
| Provider | HealthKit / Health Connect version |
| Build | App build number |
| Permission | none / partial / full / revoked |
| Expected | Spec expectation |
| Actual | What happened |
| Pass/fail | blank until run |
| Issue | Redacted ticket/link |
| Tester / Date | Who + when |

## iOS

| Scenario | Device / OS | Provider | Build | Permission | Expected | Actual | Pass/fail | Issue | Tester | Date |
|----------|-------------|----------|-------|------------|----------|--------|-----------|-------|--------|------|
| iPhone, no Watch | | | | partial/full | Totals without inventing Watch source | | | | | |
| Paired Apple Watch | | | | full | Attribution only if metadata supports | | | | | |
| Automatic Watch samples | | | | full | Honest source line | | | | | |
| Manual Health sample | | | | full | Manual indicator when known | | | | | |
| Declined read type | | | | partial | No-data ≠ denied on iOS | | | | | |
| Protected data unavailable | | | | full | Distinct locked-state UX | | | | | |
| No matching data | | | | unverified | Empty, not “denied” | | | | | |
| Activity totals | | | | full | Aggregate/deduped steps | | | | | |
| Sleep total | | | | full | Asleep duration only | | | | | |
| Workout | | | | full | List with safe attribution | | | | | |
| Disconnect / reconnect | | | | — | Cache cleared on disconnect | | | | | |
| App restart | | | | prior | Connection prefs restored | | | | | |

## Android

| Scenario | Device / OS | Provider | Build | Permission | Expected | Actual | Pass/fail | Issue | Tester | Date |
|----------|-------------|----------|-------|------------|----------|--------|-----------|-------|--------|------|
| Android 14+ Health Connect | | | | full | Verified grants per group | | | | | |
| Android 13 + HC app | | | | full | Available when installed | | | | | |
| Unsupported device | | | | — | Unavailable explanation | | | | | |
| Provider update required | | | | — | Update-required state | | | | | |
| Phone + watch sources | | | | full | Aggregate / dedupe, no double count | | | | | |
| Two source apps | | | | full | Deduped totals | | | | | |
| Partial permission | | | | partial | Only granted groups render | | | | | |
| Revoked permission | | | | revoked | Values removed on refresh | | | | | |
| Manual record | | | | full | Preserved unless user hides | | | | | |
| Duplicate Activity records | | | | full | Identity-based dedupe | | | | | |
| Weight default off | | | | first run | Weight not preselected | | | | | |
| App restart | | | | prior | Dispositions restored | | | | | |

**Physical-device runs:** not executed in automation. Leave Pass/fail blank until hardware QA.
