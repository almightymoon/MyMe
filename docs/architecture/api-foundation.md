# API foundation

## Purpose

`apps/api` is the first production backend vertical slice for MeMy. It provides a NestJS HTTP API backed by PostgreSQL (Prisma) for Goals and related Today summary data.

Out of scope for this foundation: OpenAI, finance modules, health records, calendar, weather, wardrobe, file uploads, and production identity providers (Firebase/Auth0).

## Layout

```
apps/api/
  prisma/           schema, migrations, seed
  src/
    auth/           RequestUser, CurrentUser, AuthGuard, DevAuthGuard
    common/         exception filter, logging interceptor, error codes
    config/         Joi-validated environment configuration
    goals/          Goals + milestones + progress + forecast
    health/         GET /health
    prisma/         PrismaModule / PrismaService
    today/          GET /today goal summary
  test/             e2e specs
docker-compose.yml  (repo root) local PostgreSQL
```

## Runtime conventions

| Concern | Choice |
| --- | --- |
| Global prefix | `/api/v1` |
| Validation | `ValidationPipe` with `transform`, `whitelist`, `forbidNonWhitelisted` |
| Errors | `{ statusCode, code, message, details, timestamp, path }` — no stack traces in production responses |
| Logging | Method, path, status, duration — no request body payloads |
| CORS | `CORS_ORIGINS` (comma-separated or `*`) |
| Shutdown | Nest `enableShutdownHooks()` + Prisma disconnect |
| Docs | Swagger UI at `/docs` |

## Authentication abstraction

- `RequestUser` — authenticated principal attached to the request
- `@CurrentUser()` — parameter decorator
- `AuthGuard` — abstract base
- `DevAuthGuard` — development-only; enabled via `APP_GUARD`
- `@Public()` — skips auth (health)

`DevAuthGuard` **throws** when `NODE_ENV=production`. It never silently accepts development credentials in production.

Client-supplied `userId` fields are ignored. Ownership is always taken from `RequestUser.id`.

## Data

Prisma models: `User`, `Goal`, `GoalMilestone`, `GoalProgressEntry`.

Money uses **integer minor units**. Timestamps are ISO-8601 UTC via Prisma `DateTime`.

## Local infrastructure

From repository root:

```bash
docker compose up -d
```

Defaults (overridable via env): database `memy`, user `memy`, password `memy_dev_password`, host port **`5433`** (container 5432). Host port 5433 avoids clashing with other local Postgres instances on 5432.

Then in `apps/api`:

```bash
cp .env.example .env
npx prisma migrate dev
npx prisma db seed
npm run start:dev
```

## Health

`GET /api/v1/health` is public and returns service status plus database connectivity.
