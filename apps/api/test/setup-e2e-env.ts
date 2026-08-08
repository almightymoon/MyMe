import { readFileSync, existsSync } from 'fs';
import { resolve } from 'path';

/**
 * Load apps/api/.env.test into process.env before the Nest app boots.
 * Fail fast if the file is missing — never silently use the development DB.
 */
function loadEnvTest(): void {
  const path = resolve(__dirname, '../.env.test');
  if (!existsSync(path)) {
    throw new Error(
      'Missing apps/api/.env.test. Copy .env.test.example to .env.test and create the memy_test database before running E2E tests.',
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
    // Prefer explicit shell overrides; otherwise set from file.
    if (process.env[key] === undefined) {
      process.env[key] = value;
    }
  }
  process.env.NODE_ENV = 'test';
}

loadEnvTest();
