/**
 * Fail-fast guard so destructive E2E cleanup / migration never runs against
 * development, staging, or production databases.
 *
 * Framework-independent — usable from Jest, Nest bootstrap, and CLI scripts.
 */

export type E2eDatabaseGuardInput = {
  nodeEnv: string | undefined;
  /** Preferred: dedicated test URL. Required for prepare scripts. */
  databaseUrlTest: string | undefined;
  /** Optional fallback only when allowDatabaseUrlFallback is true (legacy e2e). */
  databaseUrl?: string | undefined;
  developmentDatabaseUrl?: string | undefined;
  /** When false (default for prepare), DATABASE_URL_TEST is mandatory. */
  allowDatabaseUrlFallback?: boolean;
};

export type ParsedDatabaseUrl = {
  href: string;
  host: string;
  port: string;
  databaseName: string;
  /** Redacted for logging — never includes password. */
  safeSummary: string;
};

export function parseDatabaseUrl(url: string): ParsedDatabaseUrl {
  let parsed: URL;
  try {
    parsed = new URL(url);
  } catch {
    throw new Error('E2E database URL is not a valid URL.');
  }

  const databaseName = parsed.pathname.replace(/^\//, '').split('?')[0] ?? '';
  if (!databaseName) {
    throw new Error('E2E database URL is missing a database name.');
  }

  const host = parsed.hostname || 'localhost';
  const port = parsed.port || (parsed.protocol === 'postgresql:' ? '5432' : '');
  const safeSummary = `${host}${port ? `:${port}` : ''}/${databaseName}`;

  return {
    href: url,
    host,
    port,
    databaseName,
    safeSummary,
  };
}

export function assertTestDatabaseName(databaseName: string): void {
  if (!databaseName.endsWith('_test')) {
    throw new Error(
      'E2E tests require an isolated database whose name ends with "_test".',
    );
  }
}

/**
 * Validates environment and returns the isolated test database URL.
 * Never returns a non-test database URL.
 */
export function assertSafeE2eDatabase(options: E2eDatabaseGuardInput): string {
  const {
    nodeEnv,
    databaseUrl,
    databaseUrlTest,
    developmentDatabaseUrl,
    allowDatabaseUrlFallback = false,
  } = options;

  if (nodeEnv === 'production') {
    throw new Error('E2E tests must not run when NODE_ENV=production.');
  }

  if (nodeEnv !== 'test') {
    throw new Error(
      'E2E tests require NODE_ENV=test. Refusing to run destructive cleanup.',
    );
  }

  let url = databaseUrlTest?.trim();
  if (!url) {
    if (allowDatabaseUrlFallback && databaseUrl?.trim()) {
      url = databaseUrl.trim();
    } else {
      throw new Error(
        'E2E tests require DATABASE_URL_TEST. Refusing to fall back to a development database.',
      );
    }
  }

  const parsed = parseDatabaseUrl(url);
  assertTestDatabaseName(parsed.databaseName);

  const devUrl = developmentDatabaseUrl?.trim();
  if (devUrl && devUrl === url) {
    throw new Error(
      'E2E DATABASE_URL_TEST must not equal the normal development DATABASE_URL.',
    );
  }

  return url;
}

export function databaseNameFromUrl(url: string): string {
  return parseDatabaseUrl(url).databaseName;
}
