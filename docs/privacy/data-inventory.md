# Data inventory

| Module | Stored in MeMy | Source of truth | Backend | AI | Export | Delete |
|--------|----------------|-----------------|---------|----|--------|--------|
| Profile / prefs | Device | MeMy | No* | No | Yes (prefs) | Preferences with wipe |
| Goals | Device (default) | MeMy / API when configured | Only if `GOALS_DATA_SOURCE=api` | No | Yes (API: cache snapshot + warning) | Module / wipe (cache-only in API mode) |
| Finance | Device | MeMy | No | No | Yes | Wipe transactions; reset categories to seed |
| Habits | Device | MeMy | No | No | Yes | Module / wipe |
| Calendar imported cache | Device SQLite | Device calendars | No | No | Off by default | `calendarImportedCache` (keeps config) |
| Calendar MeMy events | Device SQLite | MeMy | No | No | Optional MeMy-owned | `calendarMeMyLocalRecords` |
| Calendar integration state | Device SQLite | MeMy | No | No | Config summary | `calendarIntegrationState` |
| External calendar events | Not owned | Device Calendar | No | No | Off by default | Never via app reset |
| Health connection config | Device prefs | MeMy | No | No | Summary only | Disconnect / wipe (clears legacy key too) |
| Health samples | Memory only (derived) | HealthKit / Health Connect | No | **No** | Never values | Never platform delete |
| Diagnostics | Generated | MeMy | No | No | Allowlisted operational fields only | N/A |

Capability claims are derived from `DataModuleRegistry` (see Privacy Data Center
catalog). Support reports use `SupportDiagnosticsReport` mapped from
`IntegrationDiagnosticsReport` with allowlisted fields only — never event
titles, health sample values, or tokens.

\* Demo authentication has no production cloud account.
