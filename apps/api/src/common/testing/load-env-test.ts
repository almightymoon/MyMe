import { existsSync, readFileSync } from 'fs';

/**
 * Shared `.env.test` loader for E2E prepare + Jest setup.
 * Never falls back to `.env`. Prefer explicit shell / CI overrides.
 */
export function loadEnvTestFile(path: string): void {
  if (!existsSync(path)) {
    throw new Error(
      `Missing ${path}. Copy .env.test.example to .env.test and create the memy_test database before running E2E tests.`,
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
    // Prefer explicit shell / CI overrides; otherwise set from file.
    if (process.env[key] === undefined) {
      process.env[key] = value;
    }
  }
  // Do not overwrite NODE_ENV — callers must supply NODE_ENV=test explicitly
  // (via .env.test or the shell). Forcing it here would hide unsafe envs.
}
