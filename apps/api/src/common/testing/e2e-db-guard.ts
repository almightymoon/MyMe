/**
 * Fail-fast guard so destructive E2E cleanup never runs against
 * development, staging, or production databases.
 */
export function assertSafeE2eDatabase(options: {
  nodeEnv: string | undefined;
  databaseUrl: string | undefined;
  databaseUrlTest: string | undefined;
  developmentDatabaseUrl?: string | undefined;
}): string {
  const { nodeEnv, databaseUrl, databaseUrlTest, developmentDatabaseUrl } =
    options;

  if (nodeEnv === 'production') {
    throw new Error('E2E tests must not run when NODE_ENV=production.');
  }

  if (nodeEnv !== 'test') {
    throw new Error(
      'E2E tests require NODE_ENV=test. Refusing to run destructive cleanup.',
    );
  }

  const url = (databaseUrlTest ?? databaseUrl)?.trim();
  if (!url) {
    throw new Error(
      'E2E tests require DATABASE_URL_TEST (preferred) or DATABASE_URL when NODE_ENV=test.',
    );
  }

  let parsed: URL;
  try {
    parsed = new URL(url);
  } catch {
    throw new Error('E2E database URL is not a valid URL.');
  }

  const dbName = parsed.pathname.replace(/^\//, '').split('?')[0] ?? '';
  if (!dbName.endsWith('_test')) {
    throw new Error(
      'E2E tests require an isolated database whose name ends with "_test".',
    );
  }

  const devUrl = developmentDatabaseUrl?.trim();
  if (devUrl && devUrl === url) {
    throw new Error(
      'E2E DATABASE_URL_TEST must not equal the normal DATABASE_URL.',
    );
  }

  return url;
}

export function databaseNameFromUrl(url: string): string {
  const parsed = new URL(url);
  return parsed.pathname.replace(/^\//, '').split('?')[0] ?? '';
}
