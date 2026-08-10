# Data deletion

## Action vocabulary
| Action | Meaning |
|--------|---------|
| Clear cache | Temporary / derived MeMy cache only |
| Disconnect | Stop MeMy access; clear connection state |
| Delete module data | MeMy-owned records for one module |
| Delete all local MeMy data | Compose module wipes with typed confirmation |
| Delete account | **Unavailable** in Demo Mode (no cloud account) |

## Boundaries
- Never delete Apple Health / Health Connect records.
- Never delete external device Calendar events via global reset.
- MeMy-created device Calendar events require a separate explicit confirmation
  when that Calendar-specific path is used.
- Goals API-backed records are not represented as local-only deletion.

## Confirmation
Global wipe requires typing: `DELETE LOCAL DATA`.
Results report deleted / skipped counts and warnings for partial failure.
