/**
 * Guarded E2E database preparation.
 *
 * Loads `.env.test`, validates DATABASE_URL_TEST via assertSafeE2eDatabase,
 * then runs `prisma migrate deploy` against that isolated database only.
 *
 * Usage: `npm run test:e2e:prepare`
 */
import { existsSync, readFileSync } from 'fs';
import { resolve } from 'path';
import { spawnSync } from 'child_process';
import {
  assertSafeE2eDatabase,
  parseDatabaseUrl,
} from '../src/common/testing/e2e-db-guard';

function loadEnvFile(path: string): void {
  if (!existsSync(path)) {
    throw new Error(
      `Missing ${path}. Copy .env.test.example to .env.test before preparing the E2E database.`,
    );
  }
  const raw = readFileSync(path, 'utf8');
  for (const line of raw.split('\n')) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith('#')) continue;
    const eq = trimmed.indexOf('=');
    if (eq <= 0) continue;
    const key = trimmed.slice(0, eq).trim();
    let value = trimmed.slice(eq + 1).trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    // Prefer explicit shell overrides.
    if (process.env[key] === undefined) {
      process.env[key] = value;
    }
  }
}

function main(): void {
  const envPath = resolve(__dirname, '../.env.test');
  loadEnvFile(envPath);

  // Do NOT overwrite NODE_ENV — an unsafe environment must stay visible to
  // assertSafeE2eDatabase rather than being silently rewritten to "test".
  const testUrl = assertSafeE2eDatabase({
    nodeEnv: process.env.NODE_ENV,
    databaseUrlTest: process.env.DATABASE_URL_TEST,
    developmentDatabaseUrl:
      process.env.DEV_DATABASE_URL ?? process.env.DATABASE_URL,
    allowDatabaseUrlFallback: false,
  });

  const parsed = parseDatabaseUrl(testUrl);
  // Set Prisma URL only after validation — never before.
  process.env.DATABASE_URL = testUrl;

  // eslint-disable-next-line no-console
  console.log(
    `Preparing E2E database ${parsed.safeSummary} (password redacted)`,
  );

  const result = spawnSync('npx', ['prisma', 'migrate', 'deploy'], {
    cwd: resolve(__dirname, '..'),
    env: process.env,
    stdio: 'inherit',
    shell: process.platform === 'win32',
  });

  if (result.status !== 0) {
    process.exit(result.status ?? 1);
  }

  // eslint-disable-next-line no-console
  console.log(`E2E database ready: ${parsed.safeSummary}`);
}

try {
  main();
} catch (error) {
  const message = error instanceof Error ? error.message : String(error);
  // eslint-disable-next-line no-console
  console.error(`E2E database preparation failed: ${message}`);
  process.exit(1);
}
