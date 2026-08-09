# Goals API contract

Contract for the Goals vertical slice shared by `apps/api` and `apps/mobile` (`ApiGoalRepository`).

Base path: `/api/v1`

Authentication (development): header `X-Dev-User-Id: <DEV_USER_ID>` or `Authorization: Bearer dev <DEV_USER_ID>`.

Flutter sends `X-Dev-User-Id` **only in debug builds**. Release builds must not include development authentication.

## Resources

### Goals

| Method | Path | Description |
| --- | --- | --- |
| GET | `/goals` | List current user's goals (`status`, `includeArchived` query) |
| POST | `/goals` | Create goal **atomically** (optional nested `milestones[]`) |
| GET | `/goals/:id` | Goal detail + milestones + progress history + forecast |
| PATCH | `/goals/:id` | Partial update |
| DELETE | `/goals/:id` | Hard delete |
| POST | `/goals/:id/archive` | Set status `archived` + `archivedAt` |
| POST | `/goals/:id/progress` | Append `GoalProgressEntry` and update amounts/percent |

### Milestones

| Method | Path | Description |
| --- | --- | --- |
| POST | `/goals/:goalId/milestones` | Create — response `{ goal, createdMilestone }` |
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
| GET | `/health` | Public (503 when database unreachable) |

## Enums

- **GoalCategory**: `financial`, `career`, `education`, `fitness`, `health`, `personalDevelopment`, `business`, `travel`, `custom`
- **GoalPriority**: `low`, `medium`, `high`, `critical`
- **GoalStatus**: `active`, `paused`, `completed`, `archived`
- **ForecastStatus**: `completed`, `overdue`, `atRisk`, `onTrack`, `insufficientData`

## Money

### Storage

PostgreSQL / Prisma: `Decimal(30, 0)` minor units (whole numbers only). Never IEEE float.

Example: **PKR 150,000,000** → minor units **`15000000000`** (paisa).

### API JSON (strings only)

All monetary fields are **decimal digit strings** (or `null`):

- `targetAmountMinor`, `currentAmountMinor`
- `previousAmountMinor`, `newAmountMinor`
- forecast: `remainingAmountMinor`, `requiredMonthlyContributionMinor`, `requiredWeeklyContributionMinor`

Correct:

```json
{
  "targetAmountMinor": "15000000000",
  "currentAmountMinor": "0"
}
```

Incorrect: JSON numbers (`15000000000`), floats (`"100.5"`), signed values, commas, scientific notation, whitespace padding.

### Rules

- `targetAmountMinor` > 0 when supplied
- `currentAmountMinor` ≥ 0
- `currentAmountMinor` ≤ `targetAmountMinor` when both set
- `currencyCode` required when any amount is supplied — exactly three uppercase ASCII letters (`PKR`)
- Financial progress percent is **server-authoritative** whenever both
  `targetAmountMinor` and an effective `currentAmountMinor` are present:

```
progressPercent = floor(currentAmountMinor × 100 ÷ targetAmountMinor)
# then clamp to [0, 100]
# current ≥ target → 100; current ≤ 0 → 0
```

  Client-supplied `progressPercent` is **accepted but ignored** in that case
  (create, update, and record-progress). The response always returns the
  calculated value. Flutter omits `progressPercent` from amount-based
  financial request bodies so the client never ships contradictory values.

  Manual `progressPercent` remains supported for non-financial goals that
  lack usable monetary amounts.

## Atomic create

`POST /goals` accepts optional `milestones[]`. Goal + milestones are written in one Prisma transaction (all-or-nothing). Flutter `ApiGoalRepository.createGoal` sends a **single** request.

## Milestone create response

```json
{
  "goal": { "...": "..." },
  "createdMilestone": { "id": "...", "title": "...", "...": "..." }
}
```

Clients must use `createdMilestone.id` — never match by title (duplicate titles are allowed).

## Ownership

Every goal query filters by authenticated `userId`. Cross-user access returns **403** (`OWNERSHIP_FORBIDDEN`) when the id exists for another user, otherwise **404**.

Never trust a client-provided `userId`.

## Domain error codes

| Code | Meaning |
| --- | --- |
| `GOAL_VALIDATION_ERROR` | Generic / class-validator failure |
| `GOAL_NAME_REQUIRED` | Missing or whitespace-only name |
| `GOAL_DEADLINE_IN_PAST` | Active create with past deadline |
| `GOAL_TARGET_AMOUNT_INVALID` | Bad or non-positive target |
| `GOAL_CURRENT_AMOUNT_EXCEEDS_TARGET` | Current > target |
| `GOAL_CURRENCY_REQUIRED` | Missing/invalid currency with amounts |
| `GOAL_CUSTOM_CATEGORY_REQUIRED` | `custom` without name |
| `GOAL_MILESTONE_INVALID` | Bad milestone payload |
| `OWNERSHIP_FORBIDDEN` | Cross-user access |
| `RESOURCE_NOT_FOUND` | Missing resource |

## Error shape

```json
{
  "statusCode": 400,
  "code": "GOAL_CURRENT_AMOUNT_EXCEEDS_TARGET",
  "message": "Human-readable message",
  "details": {},
  "timestamp": "2026-08-08T00:00:00.000Z",
  "path": "/api/v1/goals"
}
```

## Deterministic forecasting (mobile ↔ server)

Implemented in:

- Flutter: `apps/mobile/.../goal_forecast_service.dart` (`MoneyMinor` / `BigInt`)
- API: `apps/api/src/goals/forecast/goal-forecast.service.ts` (`bigint` / `Prisma.Decimal`)

### Formula

```
remaining = max(0, targetAmountMinor - max(0, currentAmountMinor))
daysRemaining = deadlineDate - asOfDate   // UTC date-only
effectiveDays = daysRemaining == 0 ? 1 : daysRemaining
monthsRemaining = max(1, ceil(effectiveDays / 30.4375))
requiredMonthlyContribution = ceil(remaining / monthsRemaining)   // upward
requiredWeeklyContribution = ceil(remaining / max(1, ceil(effectiveDays / 7)))
```

**Rounding:** required contributions always **ceil** to the next whole minor unit so the user is never told to save less than required.

### Test vector

| Field | Value |
| --- | --- |
| Target | `"15000000000"` (PKR 150,000,000) |
| Current | `"0"` |
| Currency | `PKR` |

Vary deadline (today / +60 days / past) and assert string remaining + ceiling monthly/weekly.

### Status rules

| Status | Rule |
| --- | --- |
| `completed` | Goal status completed, or remaining == 0 with valid target |
| `overdue` | Deadline before asOf and not completed |
| `atRisk` | Projection after deadline, or ≤14 days left with remaining > 50% of target, or deadline is today |
| `onTrack` | Otherwise when amounts are present |
| `insufficientData` | Missing/invalid target |

## Example create body

```json
{
  "name": "Buy a House",
  "description": "Purchase a family home",
  "category": "financial",
  "priority": "high",
  "deadline": "2027-12-31T00:00:00.000Z",
  "targetAmountMinor": "15000000000",
  "currentAmountMinor": "0",
  "currencyCode": "PKR",
  "milestones": [
    {
      "title": "Build deposit fund",
      "description": "Save the initial deposit",
      "order": 0
    },
    {
      "title": "Complete financing review",
      "order": 1
    }
  ]
}
```

Do **not** send `progressPercent` with the amounts above — the server stores `0`
(`floor(0 × 100 ÷ 15000000000)`). Conflicting client values are ignored:

| Request amounts | Client `progressPercent` | Stored |
| --- | --- | --- |
| target `10000`, current `10000` | `5` | `100` |
| target `10000`, current `2500` | `80` | `25` |
| progress `currentAmountMinor: "5000"` (target `10000`) | `99` | `50` |

## Flutter client

- `MoneyMinor` (`BigInt`) value object — JSON digit strings; legacy local `int` still readable
- `ApiGoalRepository` implements `GoalRepository`
- DTO mapping: `GoalApiMapper` (widgets never parse JSON)
- Financial create/update/progress bodies **omit** `progressPercent` when amounts are present
- Modes: `--dart-define=GOALS_DATA_SOURCE=fake|local|api`
- Base URL: `--dart-define=API_BASE_URL=...` (include `/api/v1`)
