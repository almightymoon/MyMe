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
# Finance defaults to local; optional: --dart-define=FINANCE_DATA_SOURCE=fake
```

Local goals and finance use shared `MoneyMinor` (`BigInt`); legacy integer SharedPreferences goal amounts still load. Finance has no backend API yet — see `docs/product/finance-feature.md`.

### 7. Run tests

**Mobile**

```bash
cd apps/mobile
flutter pub get
dart format .
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

Large financial Goal flow (Quick Add → PKR 150,000,000 + two milestones) is covered in
`apps/mobile/test/features/goals/widget/large_financial_goal_flow_test.dart`.

Finance local flow (Quick Add → expense PKR 25,000 Food + persistence) is covered in
`apps/mobile/test/features/finance/widget/finance_flow_test.dart`.

**API**

```bash
cd apps/api
npm ci
npm run format
npm run format:check
npm run lint
npm run lint:check
npm test
npx prisma format
npx prisma validate
npx prisma generate
npm run build
cp -n .env.test.example .env.test
npm run test:e2e:prepare
npm run test:e2e
```

`test:e2e:prepare` loads `.env.test`, requires `NODE_ENV=test` and `DATABASE_URL_TEST`,
rejects any database that is not clearly a test DB (name `memy_test` or ending in `_test`),
rejects equality with `DEV_DATABASE_URL`, then runs `prisma migrate deploy` against that URL only.
Real `.env` / `.env.test` files stay gitignored; only `.env.example` and `.env.test.example` are committed.

### 8. CI

GitHub Actions:

- `.github/workflows/mobile-ci.yml` — format, analyze, test, debug APK
- `.github/workflows/api-ci.yml` — format:check, lint:check, unit, Prisma, build, E2E on `memy_test`

### Financial progress

When a Goal has usable `targetAmountMinor` + `currentAmountMinor`, the **API** stores
`floor(current × 100 ÷ target)` (clamped 0–100). Clients may send `progressPercent`, but it is ignored.
Flutter omits it on amount-based financial requests. Monetary JSON remains digit **strings** so values like
`"15000000000"` never pass through JavaScript `Number`.

Quality notes: [`docs/quality/mobile-interaction-audit.md`](docs/quality/mobile-interaction-audit.md), [`docs/product/goals-api-contract.md`](docs/product/goals-api-contract.md).

## Contribution conventions

- Do **not** delete or rewrite `/app`, root `/index.html`, or `/reference images`.
- Prefer small, focused PRs; document architecture under `docs/`.
- Do not commit secrets, `.env`, or `.env.test` files (examples only).
- Do not commit generated `*.tsbuildinfo` / `dist` / Flutter `build` artifacts.
- Run format / analyze / tests before submitting.
