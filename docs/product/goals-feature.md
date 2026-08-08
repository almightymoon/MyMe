# Goals feature

Locally persisted goal management for MeMy mobile (Flutter).

## User flow

1. Demo sign-in → Today
2. Quick Add → **Add Goal** (real form, not a placeholder)
3. Save goal → success snackbar → Goal detail
4. Goal appears in **Goals** list (filters: All / Active / Completed / Archived)
5. Active goals appear on **Today** and **Plan** automatically
6. Open goal → update progress / complete milestones → forecast recalculates
7. Restart app → SharedPreferences restores goals (no reseed after user clears all)

## Domain model

`Goal` stores:

- identity & copy: `id`, `name`, `description`, `notes`
- classification: `category`, `customCategoryName`, `priority`, `status`
- money as **integer minor units** + `currencyCode` (never floating point in storage)
- schedule: `deadline`, `createdAt`, `updatedAt`, `archivedAt`
- `progressPercent` (derived), `milestones[]`

`GoalMilestone`: `id`, `goalId`, `title`, `description?`, `targetDate?`, `isCompleted`, `completedAt?`, `order`

Enums: `GoalCategory`, `GoalPriority`, `GoalStatus` (see `goal_enums.dart`).

## Forecast formula

`GoalForecastService` is pure and deterministic (no AI).

For financial goals with a positive target:

```
remaining = max(0, targetAmountMinor - max(0, currentAmountMinor))
daysRemaining = deadlineDate - asOfDate   // date-only
effectiveDays = daysRemaining == 0 ? 1 : daysRemaining
monthsRemaining = max(1, ceil(effectiveDays / 30.4375))
requiredMonthlyContribution = ceil(remaining / monthsRemaining)
requiredWeeklyContribution = ceil(remaining / max(1, ceil(effectiveDays / 7)))
```

Optional known monthly contribution projects a completion date.

Status: `completed` | `overdue` | `atRisk` | `onTrack` | `insufficientData`.

## Persistence format

SharedPreferences keys:

- `memy_goals_initialized_v1` — set once after first load
- `memy_goals_v1` — JSON document:

```json
{
  "schemaVersion": 1,
  "goals": [ /* Goal.toJson() */ ]
}
```

Rules:

- Seed demo goals only when initialized flag is absent
- Deleting all goals does **not** reseed
- Malformed JSON / bad entries → empty or partial list, never crash

Implementation: `LocalGoalRepository` behind `GoalRepository` (swap-ready for `ApiGoalRepository`).

## Edge cases

- Missing target → forecast `insufficientData`
- Past deadline with remaining amount → `overdue`
- Target reached / status completed → `completed`
- Deadline today → one-day runway, typically `atRisk`
- Negative current amount treated as 0 for remaining
- Current > target blocked on create validation
- Duplicate save prevented via `isSubmitting` on add form

## Future API migration

1. Keep `GoalRepository` method surface
2. Add `ApiGoalRepository` mapping DTO ↔ `Goal`
3. Override `goalRepositoryProvider` by environment
4. Migrate local JSON once, or dual-run sync
5. Leave `GoalForecastService` client-side until server provides forecasts
