# Privacy & Data Center

Route hub: `/privacy`

## Screens
| Route | Purpose |
|-------|---------|
| `/privacy` | Data inventory overview (from `DataModuleRegistry`) |
| `/privacy/export` | Module-selected local export (exportVersion 2) |
| `/privacy/delete` | Scoped wipe with plan preview + typed global confirm |
| `/privacy/ai` | AI data-use boundaries |

## Catalog
`PrivacyDataCatalogService` is derived from `DataModuleRegistry` capability
flags. Do not hardcode export/deletion claims in the UI separately.

Key facts in this milestone:
- Finance / Habits: on-device only; not sent to backend or AI
- Goals: local by default; backend only when `GOALS_DATA_SOURCE=api`
- Calendar: MeMy cache on device; source of truth may be device calendars
- Health: HealthKit / Health Connect is source of truth; MeMy stores connection
  config only; raw samples are never persisted; **not sent to AI**

## Export
JSON wrapper `exportVersion: 2` via `LocalDataExportService`.
Includes app version/build, locale/timezone, data-source modes, and counts.
Excludes secrets, raw Health values, and external Calendar content by default.
Temp files follow `ExportFileLifecycleService` cleanup.
Share via system share sheet — never auto-uploaded. Not encrypted.

## Deletion
`LocalDataDeletionCoordinator` scopes include goals (or goalsLocalCache),
finance, habits, calendarImportedCache, calendarMeMyLocalRecords,
calendarIntegrationState, healthDerivedCache,
healthConnectionConfiguration, preferences, and allLocalMeMyData.

Global wipe requires typed confirmation `DELETE LOCAL DATA`.
Partial step failures continue; failed steps can be retried.
Never deletes HealthKit / Health Connect records.
Never deletes external device Calendar events through general reset.
Demo Mode has no real cloud account to delete.
