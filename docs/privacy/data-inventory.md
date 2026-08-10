# Data inventory

| Module | Stored in MeMy | Source of truth | Backend | AI | Export | Delete |
|--------|----------------|-----------------|---------|----|--------|--------|
| Profile / prefs | Device | MeMy | No* | No | Yes | With wipe |
| Goals | Device (default) | MeMy / API when configured | Only if `GOALS_DATA_SOURCE=api` | No | Yes | Module / wipe |
| Finance | Device | MeMy | No | No | Yes | Module / wipe |
| Habits | Device | MeMy | No | No | Yes | Module / wipe |
| Calendar cache / MeMy events | Device SQLite | MeMy + device calendars | No | No | MeMy-owned optional | Cache vs MeMy events separated |
| External calendar events | Not owned | Device Calendar | No | No | Off by default | Never via app reset |
| Health connection config | Device prefs | MeMy | No | No | Summary only | Disconnect / wipe |
| Health samples | Memory only (derived) | HealthKit / Health Connect | No | **No** | Never values | Never platform delete |
| Diagnostics | Generated | MeMy | No | No | Redacted | N/A |

\* Demo authentication has no production cloud account.
