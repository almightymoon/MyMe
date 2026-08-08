# MeMy API

NestJS + Prisma + PostgreSQL backend for the MeMy personal life OS.

This package implements the first production vertical slice: **Goals**, **Milestones**, **Goal progress entries**, and a **Today** goal summary.

## Stack

- NestJS (TypeScript strict)
- PostgreSQL
- Prisma ORM
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
npx prisma migrate dev
npx prisma db seed
npm run start:dev
```

- API: `http://localhost:3000/api/v1`
- Health: `http://localhost:3000/api/v1/health`
- Swagger: `http://localhost:3000/docs`

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

## Scripts

| Command | Purpose |
| --- | --- |
| `npm run start:dev` | Watch mode |
| `npm run build` | Production build |
| `npm run lint` | ESLint |
| `npm run format` | Prettier |
| `npm test` | Unit tests |
| `npm run test:e2e` | E2E tests (needs Postgres + migrations) |
| `npm run prisma:validate` | Validate Prisma schema |
| `npm run prisma:migrate:status` | Migration status |
| `npm run prisma:seed` | Seed development users/goals |

## Environment

See `.env.example`. Never commit real credentials. Root `.gitignore` ignores `.env`.

## Docs

- [`docs/architecture/api-foundation.md`](../../docs/architecture/api-foundation.md)
- [`docs/product/goals-api-contract.md`](../../docs/product/goals-api-contract.md)
