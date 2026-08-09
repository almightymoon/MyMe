# MeMy mobile foundation

## Why Flutter is being introduced

The HTML/CSS/JavaScript application under `/app` is the approved **visual prototype**. Production MeMy needs a native-quality mobile client beside that prototype.

## How the prototype and mobile app coexist

| Path | Role |
|------|------|
| `/app` | Design prototype — do not convert wholesale |
| `/apps/mobile` | Production Flutter mobile client |
| `/apps/api` | NestJS Goals API |
| `/reference images` | Visual references |

## Architecture

Feature-first layout under `apps/mobile/lib`:

```
lib/
  app/          # bootstrap, router, theme
  core/         # config, network, errors, shared widgets
  features/     # feature modules (domain / data / application / presentation)
```

### Networking (Goals vertical slice)

- `EnvironmentConfig` — `--dart-define` for `API_BASE_URL`, `GOALS_DATA_SOURCE`, `FINANCE_DATA_SOURCE`, `DEV_USER_ID`
- `ApiClient` — Dio wrapper, timeouts, debug-only logging (no sensitive payloads)
- `ApiErrorParser` / `AppException` — consistent user-facing errors
- Dev auth header only when `kDebugMode`

### Shared money

- `MoneyMinor` / `MoneyFormat` live under `lib/core/domain/` and are reused by Goals and Finance (Goals paths re-export for compatibility)

### Goals repositories

| Mode | Class |
|------|--------|
| `fake` | `FakeGoalRepository` |
| `local` | `LocalGoalRepository` |
| `api` | `ApiGoalRepository` (+ local read-cache) |

Selected via `goalRepositoryProvider` / `goalsDataSourceProvider`. Widgets depend on `GoalRepository` only.

### Finance repositories

| Mode | Class |
|------|--------|
| `fake` | `FakeFinanceRepository` |
| `local` | `LocalFinanceRepository` (default) |

Selected via `financeRepositoryProvider` / `financeDataSourceProvider`. No Finance API yet. Summary math is pure (`FinanceSummaryService`). Today composes live finance when the ledger is non-empty.

## Navigation

- **go_router** with `StatefulShellRoute.indexedStack` for Today / Plan / Coach / More
- Quick Add is a shell modal

## State management

- **flutter_riverpod**
- Goals: stream providers over `GoalRepository.watchGoals()` so list, detail, Plan, and Today stay in sync after mutations
- Finance: stream providers over `FinanceRepository.watchTransactions()` so overview, history, detail, and Today stay in sync

## Run with API mode

See root `README.md` for PostgreSQL + API + Flutter commands.
