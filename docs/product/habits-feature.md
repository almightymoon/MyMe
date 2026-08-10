# Habits feature (local-first vertical slice)

## MVP scope

Local-first Habits management in the Flutter app:

- Binary, count, and duration Habits
- Daily, selected-weekday, and times-per-week schedules
- Check-ins with upsert (one record per Habit per local date)
- Current / longest streaks and weekly completion
- Overview, Add, Edit, Detail screens
- Today quick check-in + Plan module summary
- Fake and local repositories (`HABITS_DATA_SOURCE`)

## Deferred

- NestJS Habits API / `ApiHabitRepository`
- Push or local notification scheduling (reminder fields are informational only)
- Health-device sync, social, challenges, XP, AI motivation
- Complex fractional quantities

## Domain

Typed entities live under `apps/mobile/lib/features/habits/domain/`.

- `Habit` — schedule, goal type, target (minutes for duration), status
- `HabitCheckIn` — `LocalDate` + value + completion flag
- Derived: `HabitTodayItem`, `HabitStreakSummary`, `HabitWeeklySummary`, `HabitsOverviewSummary`

Presentation labels are not stored on entities.

## Date-only and clock

- `LocalDate` (`YYYY-MM-DD`) in `lib/core/domain/value_objects/local_date.dart`
- Week starts **Monday** (ISO-8601)
- `AppClock` / `SystemAppClock` / `FixedAppClock` in `lib/core/domain/clock/app_clock.dart`
- Habit services use the injectable clock; widgets should not call `DateTime.now()` for scheduling logic

## Schedule semantics

`HabitScheduleService`:

- Active Habits only generate scheduled dates
- Dates before `startDate` are never scheduled
- Paused / archived Habits are not scheduled
- Daily: every day on/after start
- Selected weekdays: only listed ISO weekdays
- Times-per-week: any day may host an occurrence; weekly target is enforced in progress/streak logic
- Editing a schedule affects future scheduling only; historical check-ins are preserved

## Streak semantics

`HabitProgressService`:

- Daily / selected weekdays: consecutive completed **scheduled** occurrences
- Incomplete **current** day does not break the prior streak until the day ends
- A missed past scheduled day resets the current streak
- Times-per-week: consecutive successful **calendar weeks** (week streak); incomplete current week does not break until the week ends
- Future dates never contribute

## Persistence

`LocalHabitRepository`:

| Key | Purpose |
|-----|---------|
| `memy_habits_v1` | JSON payload `{ schemaVersion, habits, checkIns }` |
| `memy_habits_initialized_v1` | First-run seed flag |

- Demo seed runs once on first launch
- Deleting all Habits does **not** reseed
- Malformed records are skipped; a corrupt blob yields empty-safe state without clearing the initialized flag
- Check-ins dedupe by `habitId|localDate`

## Repository modes

```bash
--dart-define=HABITS_DATA_SOURCE=local   # default
--dart-define=HABITS_DATA_SOURCE=fake
```

## Routes

| Path | Screen |
|------|--------|
| `/habits` | Overview |
| `/habits/new` | Add |
| `/habits/:habitId` | Detail |
| `/habits/:habitId/edit` | Edit |

## Today / Plan

- Today composes live scheduled Habit rows (max three) with quick binary toggle / count increment
- Habit repository failures do not wipe Goals or Finance on Today
- Plan includes a live Habits module and live Finance balance (no hardcoded PKR 245K)

## Future API migration

Introduce `ApiHabitRepository` behind the same `HabitRepository` contract and extend `HABITS_DATA_SOURCE` with `api`, mirroring Goals.
