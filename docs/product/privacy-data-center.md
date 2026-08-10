# Privacy & Data Center

Route hub: `/privacy`

## Screens
| Route | Purpose |
|-------|---------|
| `/privacy` | Data inventory overview |
| `/privacy/export` | Module-selected local export |
| `/privacy/delete` | Cache / module / global wipe controls |
| `/privacy/ai` | AI data-use boundaries |

## Catalog
`PrivacyDataCatalogService` describes each module’s storage, exportability,
deletion, backend transfer, and AI transfer to match repository behavior.

Key facts in this milestone:
- Finance / Habits: on-device only; not sent to backend or AI
- Goals: local by default; backend only when `GOALS_DATA_SOURCE=api`
- Calendar: MeMy cache on device; source of truth may be device calendars
- Health: HealthKit / Health Connect is source of truth; MeMy stores connection
  config only; raw samples are never persisted; **not sent to AI**

## Export
JSON wrapper `exportVersion: 1` via `LocalDataExportService`.
Excludes secrets, raw Health values, and external Calendar content by default.
Share via system share sheet — never auto-uploaded.

## Deletion
`LocalDataDeletionCoordinator` scopes: goals, finance, habits, calendarCache,
memyCalendarEvents, healthConnectionConfiguration, allLocalMeMyData.

Global wipe requires typed confirmation `DELETE LOCAL DATA`.
Never deletes HealthKit / Health Connect records.
Never deletes external device Calendar events through general reset.
Demo Mode has no real cloud account to delete.
