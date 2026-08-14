# Data export

`LocalDataExportService` builds a versioned JSON file and shares it through the
system share sheet. Nothing is uploaded automatically.

Temp files use `memy-data-export-<utcTimestamp>.json` (no user PII in the
filename). Stale `memy-data-export-*.json` / legacy `memy-export-*.json` files
older than 24 hours are cleaned on app startup.

## Wrapper (exportVersion 2)
```json
{
  "exportVersion": 2,
  "app": {
    "name": "MeMy",
    "version": "...",
    "buildNumber": "...",
    "environment": "demo"
  },
  "createdAtUtc": "...",
  "locale": "...",
  "timezone": "...",
  "dataSourceModes": {
    "goals": "local|api|fake",
    "finance": "local|fake",
    "habits": "local|fake",
    "wardrobe": "local",
    "calendar": "fake|system",
    "health": "fake|system"
  },
  "selectedModules": [],
  "recordCounts": {},
  "modules": {},
  "warnings": []
}
```

## Included when selected
- Preferences metadata
- Profile display name and avatar id (no photo)
- Goals (API mode: local cache snapshot only, with an explicit warning)
- Finance transactions, categories, budgets, and money-owed entries (monetary minor units as strings)
- Wardrobe items/outfits/plans/wear metadata (image files not included)
- Habits and check-ins
- MeMy-owned calendar events (optional)
- Calendar / Health connection configuration summaries
- App metadata

## Excluded
- Wardrobe original/thumbnail image files
- Raw Health samples / values
- External Calendar titles, notes, locations, attendees (default)
- Auth secrets, API tokens, passwords
- Support message bodies / diagnostic logs

Export failures surface a safe message (`ExportFailure`); the UI never shows
raw exception text.

Warn the user that the file may contain personal and financial information.
