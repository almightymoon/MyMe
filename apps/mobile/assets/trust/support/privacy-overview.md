# Privacy & your data

Open **Privacy & Data Center** for a module-by-module catalog derived from the
live `DataModuleRegistry` (capabilities change with data-source modes).

## Highlights

- Finance and Habits are on-device only in this build.
- Goals may use the MeMy API only when built with `GOALS_DATA_SOURCE=api`.
  Local wipe then clears the **cache only** — backend Goals remain.
- Health samples stay on the platform; MeMy keeps config + in-memory summaries.
- Calendar wipe clears MeMy cache / MeMy local records / integration state —
  never imported device events as part of global wipe.
- Diagnostics reports use a typed allowlist only (no event titles, amounts,
  Health values, tokens).

## Global wipe

Type `DELETE LOCAL DATA` (exact, after trimming spaces) to confirm.

Use Export carefully — files are temporary JSON (exportVersion 2), not
encrypted, and never auto-uploaded.
