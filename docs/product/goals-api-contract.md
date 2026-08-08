# Goals API contract

Contract for the Goals vertical slice shared by `apps/api` and (later) `apps/mobile` remote repository.

Base path: `/api/v1`

Authentication (development): header `X-Dev-User-Id: <DEV_USER_ID>` or `Authorization: Bearer dev <DEV_USER_ID>`.

## Resources

### Goals

| Method | Path | Description |
| --- | --- | --- |
| GET | `/goals` | List current user's goals (`status`, `includeArchived` query) |
| POST | `/goals` | Create goal |
| GET | `/goals/:id` | Goal detail + milestones + progress history + forecast |
| PATCH | `/goals/:id` | Partial update |
| DELETE | `/goals/:id` | Hard delete |
| POST | `/goals/:id/archive` | Set status `archived` + `archivedAt` |
| POST | `/goals/:id/progress` | Append `GoalProgressEntry` and update amounts/percent |

### Milestones

| Method | Path | Description |
| --- | --- | --- |
| POST | `/goals/:goalId/milestones` | Create |
| PATCH | `/goals/:goalId/milestones/:milestoneId` | Update |
| DELETE | `/goals/:goalId/milestones/:milestoneId` | Delete |
| POST | `/goals/:goalId/milestones/:milestoneId/complete` | Complete |
| POST | `/goals/:goalId/milestones/:milestoneId/reopen` | Reopen |

### Today

| Method | Path | Description |
| --- | --- | --- |
| GET | `/today` | Active goal count, due soon, at risk, top active, average progress |

### Health

| Method | Path | Auth |
| --- | --- | --- |
| GET | `/health` | Public |

## Enums

- **GoalCategory**: `financial`, `career`, `education`, `fitness`, `health`, `personalDevelopment`, `business`, `travel`, `custom`
- **GoalPriority**: `low`, `medium`, `high`, `critical`
- **GoalStatus**: `active`, `paused`, `completed`, `archived`
- **ForecastStatus**: `completed`, `overdue`, `atRisk`, `onTrack`, `insufficientData`

## Money

Amounts are **integer minor units** (`targetAmountMinor`, `currentAmountMinor`). Currency is ISO-4217 (`currencyCode`).

When recording progress with only `currentAmountMinor` and a positive target, `progressPercent` is derived as `min(100, max(0, current/target*100))`.

## Ownership

Every goal query filters by authenticated `userId`. Cross-user access returns **403** (`OWNERSHIP_FORBIDDEN`) when the id exists for another user, otherwise **404**.

Never trust a client-provided `userId`.

## Error shape

```json
{
  "statusCode": 400,
  "code": "GOAL_VALIDATION_ERROR",
  "message": "Human-readable message",
  "details": {},
  "timestamp": "2026-08-08T00:00:00.000Z",
  "path": "/api/v1/goals"
}
```

## Deterministic forecasting (mobile ↔ server)

Implemented in:

- Flutter: `apps/mobile/.../goal_forecast_service.dart`
- API: `apps/api/src/goals/forecast/goal-forecast.service.ts`

### Formula

```
remaining = max(0, targetAmountMinor - max(0, currentAmountMinor))
daysRemaining = deadlineDate - asOfDate   // date-only
effectiveDays = daysRemaining == 0 ? 1 : daysRemaining
monthsRemaining = max(1, ceil(effectiveDays / 30.4375))
requiredMonthlyContribution = ceil(remaining / monthsRemaining)
requiredWeeklyContribution = ceil(remaining / max(1, ceil(effectiveDays / 7)))
```

Optional known monthly contribution:

```
monthsNeeded = ceil(remaining / knownMonthlyContributionMinor)
projectedCompletionDate = asOf + ceil(monthsNeeded * 30.4375) days
```

### Status rules

| Status | Rule |
| --- | --- |
| `completed` | Goal status completed, or remaining == 0 with valid target |
| `overdue` | Deadline before asOf and not completed |
| `atRisk` | Projection after deadline, or ≤14 days left with remaining > 50% of target, or deadline is today |
| `onTrack` | Otherwise when amounts are present |
| `insufficientData` | Missing/invalid target |

No OpenAI / ML is used for these calculations.

## Example create body

```json
{
  "name": "Emergency fund",
  "description": "Six months of expenses",
  "category": "financial",
  "priority": "high",
  "targetAmountMinor": 50000000,
  "currentAmountMinor": 10000000,
  "currencyCode": "PKR",
  "deadline": "2026-12-31T00:00:00.000Z",
  "progressPercent": 20
}
```
