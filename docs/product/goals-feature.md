# Goals feature

Goal management for MeMy mobile (Flutter), with pluggable persistence:

| Mode (`GOALS_DATA_SOURCE`) | Implementation |
| --- | --- |
| `local` (default) | `LocalGoalRepository` — SharedPreferences offline/demo |
| `api` | `ApiGoalRepository` — NestJS `/api/v1/goals` + local read-cache |
| `fake` | `FakeGoalRepository` — in-memory for demos/tests |

UI never talks to Dio or parses JSON. Screens use `goalRepositoryProvider` only.

## User flow

1. Demo sign-in → Today
2. Quick Add → **Add Goal** (real form)
3. Save goal → success snackbar → Goal detail
4. Goal appears in **Goals** list (filters: All / Active / Completed / Archived)
5. Active goals appear on **Today** and **Plan** automatically
6. Open goal → update progress / complete milestones → forecast recalculates
7. Restart app → local mode restores SharedPreferences; API mode refreshes from server (cache used offline)

## Domain model

`Goal` stores identity, classification, **`MoneyMinor`** amounts + currency, schedule, progress, milestones.

`MoneyMinor` is a non-negative `BigInt` minor-unit value object:

- Wire / persistence: decimal digit **string** (e.g. `"15000000000"`)
- Legacy local JSON **ints** still deserialize
- New local writes always use strings
- Corrupt monetary values yield `null` on local read (do not crash the app)

Enums: `GoalCategory`, `GoalPriority`, `GoalStatus`.

PRD example: **PKR 150,000,000** → `"15000000000"` minor units.

## Forecast formula

`GoalForecastService` is pure and deterministic (no AI), using `BigInt` arithmetic. Same formula as the NestJS server — see `docs/product/goals-api-contract.md`. Required contributions **ceil** upward.

## Repository selection

Build-time / environment (see `EnvironmentConfig`):

```bash
--dart-define=GOALS_DATA_SOURCE=api
--dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1
--dart-define=DEV_USER_ID=00000000-0000-4000-8000-000000000001
```

`goalRepositoryProvider` switches implementations. Override `goalsDataSourceProvider` in tests.

## API mode

- `createGoal` sends **one** `POST /goals` including nested milestones (atomic)
- Financial create/update/progress requests **omit** `progressPercent` when amounts exist; the NestJS server calculates `floor(current×100÷target)` (clamped 0–100)
- `addMilestone` expects `{ goal, createdMilestone }` and uses the exact created id
- Successful list/detail responses call `LocalGoalRepository.replaceAll` / `upsert`
- Network/timeout on **reads** → return previously cached goals
- Network on **writes** → `AppException.connectionRequired` — no fake offline sync
- Save is guarded with `isSubmitting` so rapid taps create only one Goal

## Error handling

Failures map to `AppException` kinds: validation, unauthorized, forbidden, not found, conflict, network unavailable, timeout, server failure, connection required, unknown.

UI uses `userFacingErrorMessage` — never raw Dio or stack traces.

Dev auth header `X-Dev-User-Id` is sent **only in debug builds** (`kDebugMode`).

## Local persistence format

SharedPreferences keys:

- `memy_goals_initialized_v1`
- `memy_goals_v1` — `{ "schemaVersion": 1, "goals": [ ... ] }`

Money fields in `goals` are digit strings after this migration. Legacy integer amounts remain readable via `MoneyMinor.fromJson`.

Seed demo goals only when initialized flag is absent (local mode). API mode seeds an empty cache.

## Edge cases

- Duplicate save prevented via `isSubmitting` on add form
- Missing target → forecast `insufficientData`
- Offline write does not pretend success
- Current amount cannot exceed target (client + server validation)
