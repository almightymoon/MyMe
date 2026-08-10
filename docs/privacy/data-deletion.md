# Data deletion

## Action vocabulary
| Action | Meaning |
|--------|---------|
| Clear cache | Temporary / derived MeMy cache only |
| Disconnect | Stop MeMy access; clear connection state |
| Delete module data | MeMy-owned records for one module |
| Delete all local MeMy data | Compose module wipes with typed confirmation |
| Delete account | **Unavailable** in Demo Mode (no cloud account) |

## Scopes
| Scope | Clears | Leaves |
|-------|--------|--------|
| `goals` / `goalsLocalCache` | Local Goals or API Goals cache | Backend Goals when `GOALS_DATA_SOURCE=api` |
| `finance` | Transactions; categories reset to seed defaults | Seed category catalog |
| `habits` | Habits + check-ins | — |
| `calendarImportedCache` | Imported external event cache + related links | MeMy-owned events, connection config, device calendars |
| `calendarMeMyLocalRecords` | MeMy-authored local events + related links | Imported cache, connection config, device calendars |
| `calendarIntegrationState` | Calendar connection configuration | Event rows unless also selected |
| `calendarCache` | Imported + MeMy local records (combined) | Connection config unless `calendarIntegrationState` also selected; never device events |
| `healthDerivedCache` | In-memory daily summaries | Connection prefs + platform Health |
| `healthConnectionConfiguration` | MeMy Health connection prefs (incl. legacy key) + derived cache | HealthKit / Health Connect |
| `preferences` | Appearance / reduce-motion prefs | Other SharedPreferences keys |
| `allLocalMeMyData` | Expands to goals, finance, habits, calendar imported + MeMy records + integration state, health derived + connection, preferences | Device calendar events, platform Health, backend Goals |
| `calendarDeviceEvents` | **Never** part of global wipe | Separate Calendar path only |

## Boundaries
- Never delete Apple Health / Health Connect records.
- Never delete external device Calendar events via global reset.
- MeMy-created device Calendar events require a separate explicit confirmation
  when that Calendar-specific path is used.
- Goals API-backed records are not deleted remotely; only the on-device cache
  is cleared (`clearLocalCacheOnly` — never `deleteGoal`).
- Partial step failures continue remaining selected steps and report per-step
  status with safe messages.

## Confirmation
Global wipe requires typing: `DELETE LOCAL DATA` (case-sensitive; leading and
trailing whitespace are trimmed).
Plan preview lists what will be deleted and what remains (backend Goals when
API mode, device calendars, platform Health).
Results report overall status (`Completed`, `Completed with issues`, etc.),
per-step outcomes, and a **Retry failed steps** action that re-runs only
failed retryable scopes.
