# Data export

`LocalDataExportService` builds a versioned JSON file and shares it through the
system share sheet. Nothing is uploaded automatically.

## Wrapper
```json
{
  "exportVersion": 1,
  "appVersion": "...",
  "buildNumber": "...",
  "createdAt": "...",
  "modules": { }
}
```

## Included when selected
- Profile / preferences metadata
- Goals
- Finance transactions (monetary minor units as strings) and categories
- Habits and check-ins
- MeMy-owned calendar events
- Calendar / Health connection configuration summaries
- App metadata

## Excluded
- Raw Health samples / values
- External Calendar titles, notes, locations, attendees (default)
- Auth secrets, API tokens, passwords
- Support message bodies / diagnostic logs

Warn the user that the file may contain personal and financial information.
