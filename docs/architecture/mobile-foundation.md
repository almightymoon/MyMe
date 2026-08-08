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

- `EnvironmentConfig` — `--dart-define` for `API_BASE_URL`, `GOALS_DATA_SOURCE`, `DEV_USER_ID`
- `ApiClient` — Dio wrapper, timeouts, debug-only logging (no sensitive payloads)
- `ApiErrorParser` / `AppException` — consistent user-facing errors
- Dev auth header only when `kDebugMode`

### Goals repositories

| Mode | Class |
|------|--------|
| `fake` | `FakeGoalRepository` |
| `local` | `LocalGoalRepository` |
| `api` | `ApiGoalRepository` (+ local read-cache) |

Selected via `goalRepositoryProvider` / `goalsDataSourceProvider`. Widgets depend on `GoalRepository` only.

## Navigation

- **go_router** with `StatefulShellRoute.indexedStack` for Today / Plan / Coach / More
- Quick Add is a shell modal

## State management

- **flutter_riverpod**
- Goals: stream providers over `GoalRepository.watchGoals()` so list, detail, Plan, and Today stay in sync after mutations

## Run with API mode

See root `README.md` for PostgreSQL + API + Flutter commands.
