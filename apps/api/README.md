# MeMy API

NestJS + Prisma + PostgreSQL backend for the MeMy personal life OS.

This package implements the first production vertical slice: **Goals**, **Milestones**, **Goal progress entries**, and a **Today** goal summary.

## Stack

- NestJS (TypeScript strict)
- PostgreSQL
- Prisma ORM (`Decimal(30,0)` for monetary minor units)
- Swagger / OpenAPI (`/docs`)
- class-validator DTOs
- Docker Compose PostgreSQL (repo root)

## Quick start

From the **repository root**:

```bash
docker compose up -d
```

PostgreSQL is published on host port **5433** by default (see `.env.example`).

From **`apps/api`**:

```bash
cp .env.example .env
npm install
npx prisma migrate deploy
npx prisma db seed
npm run start:dev
```

- API: `http://localhost:3000/api/v1`
- Health: `http://localhost:3000/api/v1/health`
- Swagger: `http://localhost:3000/docs`

## Money

- DB: `DECIMAL(30,0)` — supports PKR 150,000,000 as `15000000000` paisa
- API JSON: **strings only** (never JavaScript `Number` for stored money)
- Services use `Prisma.Decimal` / `bigint`
- Financial `progressPercent` is **server-authoritative**:
  `floor(currentAmountMinor × 100 ÷ targetAmountMinor)`, clamped to 0–100,
  whenever both amounts exist. Client `progressPercent` is ignored in that case
  (create / update / record-progress). Manual percent remains for non-financial goals.

## Development authentication

No production IdP yet. Outside `NODE_ENV=production`, send:

```http
X-Dev-User-Id: 00000000-0000-4000-8000-000000000001
```

Or:

```http
Authorization: Bearer dev 00000000-0000-4000-8000-000000000001
```

The value must match `DEV_USER_ID`. Production refuses development authentication.

## E2E tests (isolated database)

E2E cleanup is destructive and **requires** a dedicated test database.

1. Create the database (once):

```bash
docker exec memy-postgres psql -U memy -d postgres -c 'CREATE DATABASE memy_test;'
```

2. Copy env and run the guarded prepare + suite:

```bash
cp .env.test.example .env.test
npm run test:e2e:prepare
npm run test:e2e
```

`scripts/prepare-e2e-db.ts` (and the shared `assertSafeE2eDatabase` guard):

- requires `NODE_ENV=test` and `DATABASE_URL_TEST`
- parses the URL and requires the DB name to be `memy_test` or end with `_test`
- rejects production and rejects equality with `DEV_DATABASE_URL` / development `DATABASE_URL`
- sets `process.env.DATABASE_URL` to the validated test URL only after those checks
- prints host + database name with the password redacted
- never silently falls back to another database

Never run E2E against the development `memy` database. Never commit real `.env.test` files.

## Scripts

| Command | Purpose |
| --- | --- |
| `npm run start:dev` | Watch mode |
| `npm run build` | Production build |
| `npm run format` | Prettier write |
| `npm run format:check` | Prettier check (CI) |
| `npm run lint` | ESLint with `--fix` |
| `npm run lint:check` | ESLint without write (CI) |
| `npm test` | Unit tests |
| `npm run test:e2e:prepare` | Guarded migrate deploy for `DATABASE_URL_TEST` |
| `npm run test:e2e` | Prepare + E2E against `memy_test` |
| `npm run prisma:validate` | Validate Prisma schema |
| `npm run prisma:migrate:status` | Migration status |
| `npm run prisma:seed` | Seed development users/goals |

## CI

`.github/workflows/api-ci.yml` runs format:check, lint:check, unit tests, Prisma validate/generate, build, and guarded E2E against a `memy_test` service container.

## Environment

NestJS runtime configuration validates **only** values the application consumes:

- `DATABASE_URL` (Prisma / Nest)
- `DEV_USER_*`, `API_PORT`, `API_GLOBAL_PREFIX`, `CORS_ORIGINS`, `NODE_ENV`

Docker Compose `POSTGRES_*` variables initialize the Postgres container; they are **not** required by Nest ConfigModule. Prefer composing `DATABASE_URL` for application connectivity.

See `.env.example` and `.env.test.example`. Never commit real credentials. `.env` and `.env.test` are gitignored; the `*.example` files are allowed.

## Docs

- [`docs/architecture/api-foundation.md`](../../docs/architecture/api-foundation.md)
- [`docs/product/goals-api-contract.md`](../../docs/product/goals-api-contract.md)
