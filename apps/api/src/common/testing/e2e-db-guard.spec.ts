import { assertSafeE2eDatabase } from './e2e-db-guard';

describe('assertSafeE2eDatabase', () => {
  const safe =
    'postgresql://memy:memy_dev_password@localhost:5433/memy_test?schema=public';
  const unsafe =
    'postgresql://memy:memy_dev_password@localhost:5433/memy?schema=public';

  it('accepts memy_test with NODE_ENV=test', () => {
    expect(
      assertSafeE2eDatabase({
        nodeEnv: 'test',
        databaseUrl: unsafe,
        databaseUrlTest: safe,
        developmentDatabaseUrl: unsafe,
      }),
    ).toBe(safe);
  });

  it('rejects non-test NODE_ENV', () => {
    expect(() =>
      assertSafeE2eDatabase({
        nodeEnv: 'development',
        databaseUrl: safe,
        databaseUrlTest: safe,
      }),
    ).toThrow(/NODE_ENV=test/);
  });

  it('rejects production', () => {
    expect(() =>
      assertSafeE2eDatabase({
        nodeEnv: 'production',
        databaseUrl: safe,
        databaseUrlTest: safe,
      }),
    ).toThrow(/production/);
  });

  it('rejects database name that is not *_test', () => {
    expect(() =>
      assertSafeE2eDatabase({
        nodeEnv: 'test',
        databaseUrl: unsafe,
        databaseUrlTest: unsafe,
        developmentDatabaseUrl: 'postgresql://x/other',
      }),
    ).toThrow(/_test/);
  });

  it('rejects when test URL equals development URL', () => {
    expect(() =>
      assertSafeE2eDatabase({
        nodeEnv: 'test',
        databaseUrl: safe,
        databaseUrlTest: safe,
        developmentDatabaseUrl: safe,
      }),
    ).toThrow(/must not equal/);
  });
});
