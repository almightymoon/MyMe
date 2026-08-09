import {
  assertSafeE2eDatabase,
  parseDatabaseUrl,
  assertTestDatabaseName,
} from './e2e-db-guard';

describe('e2e-db-guard', () => {
  const safe =
    'postgresql://memy:memy_dev_password@localhost:5433/memy_test?schema=public';
  const unsafe =
    'postgresql://memy:memy_dev_password@localhost:5433/memy?schema=public';
  const specialPassword =
    'postgresql://memy:p%40ss%3Aw0rd@localhost:5433/memy_test?schema=public';

  describe('parseDatabaseUrl', () => {
    it('extracts database name and redacts password from summary', () => {
      const parsed = parseDatabaseUrl(specialPassword);
      expect(parsed.databaseName).toBe('memy_test');
      expect(parsed.host).toBe('localhost');
      expect(parsed.port).toBe('5433');
      expect(parsed.safeSummary).toBe('localhost:5433/memy_test');
      expect(parsed.safeSummary).not.toContain('p@ss');
      expect(parsed.safeSummary).not.toContain('%40');
    });

    it('rejects invalid URL', () => {
      expect(() => parseDatabaseUrl('not-a-url')).toThrow(/valid URL/);
    });

    it('preserves schema query parameter on href', () => {
      const parsed = parseDatabaseUrl(safe);
      expect(parsed.href).toContain('schema=public');
      expect(parsed.databaseName).toBe('memy_test');
    });
  });

  describe('assertTestDatabaseName', () => {
    it('accepts memy_test', () => {
      expect(() => assertTestDatabaseName('memy_test')).not.toThrow();
    });

    it('accepts names ending with _test', () => {
      expect(() => assertTestDatabaseName('goals_ci_test')).not.toThrow();
    });

    it('rejects memy', () => {
      expect(() => assertTestDatabaseName('memy')).toThrow(/_test/);
    });

    it('rejects production', () => {
      expect(() => assertTestDatabaseName('production')).toThrow(/_test/);
    });
  });

  describe('assertSafeE2eDatabase', () => {
    it('accepts memy_test with NODE_ENV=test', () => {
      expect(
        assertSafeE2eDatabase({
          nodeEnv: 'test',
          databaseUrlTest: safe,
          developmentDatabaseUrl: unsafe,
        }),
      ).toBe(safe);
    });

    it('rejects when NODE_ENV is not test', () => {
      expect(() =>
        assertSafeE2eDatabase({
          nodeEnv: 'development',
          databaseUrlTest: safe,
        }),
      ).toThrow(/NODE_ENV=test/);
    });

    it('rejects production', () => {
      expect(() =>
        assertSafeE2eDatabase({
          nodeEnv: 'production',
          databaseUrlTest: safe,
        }),
      ).toThrow(/production/);
    });

    it('rejects missing DATABASE_URL_TEST without fallback', () => {
      expect(() =>
        assertSafeE2eDatabase({
          nodeEnv: 'test',
          databaseUrlTest: undefined,
          databaseUrl: unsafe,
          allowDatabaseUrlFallback: false,
        }),
      ).toThrow(/DATABASE_URL_TEST/);
    });

    it('rejects database name that is not *_test', () => {
      expect(() =>
        assertSafeE2eDatabase({
          nodeEnv: 'test',
          databaseUrlTest: unsafe,
          developmentDatabaseUrl: 'postgresql://x/other',
        }),
      ).toThrow(/_test/);
    });

    it('rejects when test URL equals development URL', () => {
      expect(() =>
        assertSafeE2eDatabase({
          nodeEnv: 'test',
          databaseUrlTest: safe,
          developmentDatabaseUrl: safe,
        }),
      ).toThrow(/must not equal/);
    });

    it('accepts passwords with special URL encoding', () => {
      expect(
        assertSafeE2eDatabase({
          nodeEnv: 'test',
          databaseUrlTest: specialPassword,
          developmentDatabaseUrl: unsafe,
        }),
      ).toBe(specialPassword);
    });
  });
});
