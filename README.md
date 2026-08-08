# MeMy

MeMy is a personal life-operating system by **MoonTech** — goals, habits, calendar, finance, health, and an AI coach in one calm daily surface.

This repository currently holds:

1. An approved **HTML/CSS/JavaScript visual prototype** (design reference)
2. A **Flutter mobile application** under `apps/mobile`
3. A **NestJS Goals API** under `apps/api` (PostgreSQL + Prisma)

The HTML application is the design prototype. Do not convert it line-for-line into Flutter.

## Repository structure

```
/
├── index.html
├── app/                       # Interactive web prototype (do not remove)
├── apps/
│   ├── mobile/                # Flutter client (Android + iOS)
│   └── api/                   # NestJS API (Goals vertical slice)
├── docker-compose.yml         # Local PostgreSQL
├── docs/
└── reference images/
```

## Development status

| Area | Status |
|------|--------|
| Web prototype (`/app`) | Approved visual reference — keep intact |
| Flutter mobile (`/apps/mobile`) | Goals local + API repository modes |
| NestJS API (`/apps/api`) | Goals / milestones / progress / today summary |
| Production auth / AI / sensors | Not in this milestone |

## Verified local development sequence

Run these steps from a clean checkout. Values below match `apps/api/.env.example`.

### 1. Start PostgreSQL

```bash
docker compose up -d
docker compose ps
```

Host port **5433** maps to container `5432`.  
Default credentials: user/db `memy`, password `memy_dev_password`.

For E2E tests, also create an isolated database (once):

```bash
docker exec memy-postgres psql -U memy -d postgres -c 'CREATE DATABASE memy_test;'
```

### 2. Run migrations

```bash
cd apps/api
cp -n .env.example .env
npm install
npx prisma migrate deploy
```

Monetary columns use `DECIMAL(30,0)` so values such as PKR 150,000,000 (`15000000000` paisa) are safe.

### 3. Seed development data

```bash
cd apps/api
npx prisma db seed
```

### 4. Start NestJS

```bash
cd apps/api
npm run start:dev
```

- Health: `http://localhost:3000/api/v1/health`
- Swagger: `http://localhost:3000/docs`
- Dev auth: header `X-Dev-User-Id` matching `DEV_USER_ID`
- Money in JSON is always a **string** (e.g. `"15000000000"`)

### 5. Run Flutter in API mode

**iOS simulator / macOS desktop:**

```bash
cd apps/mobile
flutter pub get
flutter run --dart-define=GOALS_DATA_SOURCE=api \
  --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1 \
  --dart-define=DEV_USER_ID=00000000-0000-4000-8000-000000000001
```

**Android emulator:** use `http://10.0.2.2:3000/api/v1`.

### 6. Run Flutter in local mode

```bash
cd apps/mobile
flutter run
# or: flutter run --dart-define=GOALS_DATA_SOURCE=local
```

Local goals use `MoneyMinor` (`BigInt`); legacy integer SharedPreferences amounts still load.

### 7. Run tests

**Mobile**

```bash
cd apps/mobile
dart format .
flutter analyze
flutter test
```

**API**

```bash
cd apps/api
npm run format
npm run lint
npm test
cp -n .env.test.example .env.test
npm run test:e2e:prepare
npm run test:e2e
npm run build
npx prisma validate
```

E2E refuses any database whose name does not end with `_test`.

Quality notes: [`docs/quality/mobile-interaction-audit.md`](docs/quality/mobile-interaction-audit.md), [`docs/product/goals-api-contract.md`](docs/product/goals-api-contract.md).

## Contribution conventions

- Do **not** delete or rewrite `/app`, root `/index.html`, or `/reference images`.
- Prefer small, focused PRs; document architecture under `docs/`.
- Do not commit secrets or `.env` files.
- Run format / analyze / tests before submitting.
