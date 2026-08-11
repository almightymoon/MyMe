import { envValidationSchema } from './configuration';

/**
 * Proves Nest runtime validation matches AppConfig dependencies:
 * DATABASE_URL + DEV_USER_* — not Docker Compose POSTGRES_* pieces.
 */
describe('envValidationSchema', () => {
  const base = {
    NODE_ENV: 'test',
    DATABASE_URL:
      'postgresql://memy:memy_dev_password@localhost:5433/memy_test?schema=public',
    DEV_USER_ID: '00000000-0000-4000-8000-000000000001',
    DEV_USER_EMAIL: 'emma@example.com',
    DEV_USER_DISPLAY_NAME: 'Emma Chen',
    DEV_USER_TIMEZONE: 'Asia/Karachi',
    DEV_USER_CURRENCY: 'PKR',
  };

  it('accepts DATABASE_URL and application settings without POSTGRES_*', () => {
    const { error, value } = envValidationSchema.validate(base, {
      abortEarly: false,
      allowUnknown: true,
    });
    expect(error).toBeUndefined();
    expect(value.DATABASE_URL).toBe(base.DATABASE_URL);
    expect(value.DEV_USER_ID).toBe(base.DEV_USER_ID);
  });

  it('accepts unknown POSTGRES_* keys without requiring them', () => {
    const { error } = envValidationSchema.validate(
      {
        ...base,
        POSTGRES_HOST: 'localhost',
        POSTGRES_PASSWORD: 'ignored',
      },
      { abortEarly: false, allowUnknown: true },
    );
    expect(error).toBeUndefined();
  });

  it('fails when DATABASE_URL is missing', () => {
    const withoutDb = { ...base } as Record<string, string>;
    delete withoutDb.DATABASE_URL;
    const { error } = envValidationSchema.validate(withoutDb, {
      abortEarly: false,
      allowUnknown: true,
    });
    expect(error).toBeDefined();
    expect(error?.message).toMatch(/DATABASE_URL/);
  });

  it('fails when DEV_USER_ID is missing outside production', () => {
    const withoutUser = { ...base } as Record<string, string>;
    delete withoutUser.DEV_USER_ID;
    const { error } = envValidationSchema.validate(withoutUser, {
      abortEarly: false,
      allowUnknown: true,
    });
    expect(error).toBeDefined();
    expect(error?.message).toMatch(/DEV_USER_ID/);
  });

  it('requires JWT secrets in production and not DEV_USER_ID', () => {
    const { error, value } = envValidationSchema.validate(
      {
        NODE_ENV: 'production',
        DATABASE_URL: base.DATABASE_URL,
        JWT_ACCESS_SECRET: 'production-access-secret-min-32-chars',
        REFRESH_TOKEN_PEPPER: 'production-pepper',
        CORS_ORIGINS: 'https://app.example.invalid',
      },
      { abortEarly: false, allowUnknown: true },
    );
    expect(error).toBeUndefined();
    expect(value.JWT_ACCESS_SECRET).toContain('production-access');
  });

  it('fails when DATABASE_URL is not a URI', () => {
    const { error } = envValidationSchema.validate(
      { ...base, DATABASE_URL: 'not-a-url' },
      { abortEarly: false, allowUnknown: true },
    );
    expect(error).toBeDefined();
    expect(error?.message).toMatch(/DATABASE_URL/);
  });
});
