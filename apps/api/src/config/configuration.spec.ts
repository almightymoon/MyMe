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
    API_PUBLIC_URL: 'https://api.example.com/api/v1',
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
        API_PUBLIC_URL: 'https://api.example.com/api/v1',
        JWT_ACCESS_SECRET: 'production-access-secret-min-32-chars',
        REFRESH_TOKEN_PEPPER: 'production-pepper',
        CORS_ORIGINS: 'https://app.example.com',
        OBJECT_STORAGE_ENDPOINT: 'http://minio:9000',
        OBJECT_STORAGE_ACCESS_KEY: 'minio-access-key',
        OBJECT_STORAGE_SECRET_KEY: 'minio-secret-key',
        OBJECT_STORAGE_BUCKET: 'memy-private',
        OBJECT_STORAGE_SIGNED_URL_SECONDS: 300,
      },
      { abortEarly: false, allowUnknown: true },
    );
    expect(error).toBeUndefined();
    expect(value.JWT_ACCESS_SECRET).toContain('production-access');
  });

  it('rejects CORS_ORIGINS=* in production', () => {
    const { error } = envValidationSchema.validate(
      {
        NODE_ENV: 'production',
        DATABASE_URL: base.DATABASE_URL,
        API_PUBLIC_URL: 'https://api.example.com/api/v1',
        JWT_ACCESS_SECRET: 'production-access-secret-min-32-chars',
        REFRESH_TOKEN_PEPPER: 'production-pepper',
        CORS_ORIGINS: '*',
        OBJECT_STORAGE_ENDPOINT: 'http://minio:9000',
        OBJECT_STORAGE_ACCESS_KEY: 'minio-access-key',
        OBJECT_STORAGE_SECRET_KEY: 'minio-secret-key',
        OBJECT_STORAGE_BUCKET: 'memy-private',
        OBJECT_STORAGE_SIGNED_URL_SECONDS: 300,
      },
      { abortEarly: false, allowUnknown: true },
    );
    expect(error).toBeDefined();
  });

  it('rejects placeholder `.invalid` API_PUBLIC_URL in production', () => {
    const { error } = envValidationSchema.validate(
      {
        NODE_ENV: 'production',
        DATABASE_URL: base.DATABASE_URL,
        API_PUBLIC_URL: 'https://api.example.invalid/api/v1',
        JWT_ACCESS_SECRET: 'production-access-secret-min-32-chars',
        REFRESH_TOKEN_PEPPER: 'production-pepper',
        CORS_ORIGINS: 'https://app.example.com',
        OBJECT_STORAGE_ENDPOINT: 'http://minio:9000',
        OBJECT_STORAGE_ACCESS_KEY: 'minio-access-key',
        OBJECT_STORAGE_SECRET_KEY: 'minio-secret-key',
        OBJECT_STORAGE_BUCKET: 'memy-private',
        OBJECT_STORAGE_SIGNED_URL_SECONDS: 300,
      },
      { abortEarly: false, allowUnknown: true },
    );
    expect(error).toBeDefined();
  });

  it('rejects non-https API_PUBLIC_URL in production', () => {
    const { error } = envValidationSchema.validate(
      {
        NODE_ENV: 'production',
        DATABASE_URL: base.DATABASE_URL,
        API_PUBLIC_URL: 'http://api.example.com/api/v1',
        JWT_ACCESS_SECRET: 'production-access-secret-min-32-chars',
        REFRESH_TOKEN_PEPPER: 'production-pepper',
        CORS_ORIGINS: 'https://app.example.com',
        OBJECT_STORAGE_ENDPOINT: 'http://minio:9000',
        OBJECT_STORAGE_ACCESS_KEY: 'minio-access-key',
        OBJECT_STORAGE_SECRET_KEY: 'minio-secret-key',
        OBJECT_STORAGE_BUCKET: 'memy-private',
        OBJECT_STORAGE_SIGNED_URL_SECONDS: 300,
      },
      { abortEarly: false, allowUnknown: true },
    );
    expect(error).toBeDefined();
  });

  it('rejects out-of-bounds signed URL expiry in production', () => {
    const { error } = envValidationSchema.validate(
      {
        NODE_ENV: 'production',
        DATABASE_URL: base.DATABASE_URL,
        API_PUBLIC_URL: 'https://api.example.com/api/v1',
        JWT_ACCESS_SECRET: 'production-access-secret-min-32-chars',
        REFRESH_TOKEN_PEPPER: 'production-pepper',
        CORS_ORIGINS: 'https://app.example.com',
        OBJECT_STORAGE_ENDPOINT: 'http://minio:9000',
        OBJECT_STORAGE_ACCESS_KEY: 'minio-access-key',
        OBJECT_STORAGE_SECRET_KEY: 'minio-secret-key',
        OBJECT_STORAGE_BUCKET: 'memy-private',
        OBJECT_STORAGE_SIGNED_URL_SECONDS: 30,
      },
      { abortEarly: false, allowUnknown: true },
    );
    expect(error).toBeDefined();
  });

  it('rejects invalid bucket names in production', () => {
    const { error } = envValidationSchema.validate(
      {
        NODE_ENV: 'production',
        DATABASE_URL: base.DATABASE_URL,
        API_PUBLIC_URL: 'https://api.example.com/api/v1',
        JWT_ACCESS_SECRET: 'production-access-secret-min-32-chars',
        REFRESH_TOKEN_PEPPER: 'production-pepper',
        CORS_ORIGINS: 'https://app.example.com',
        OBJECT_STORAGE_ENDPOINT: 'http://minio:9000',
        OBJECT_STORAGE_ACCESS_KEY: 'minio-access-key',
        OBJECT_STORAGE_SECRET_KEY: 'minio-secret-key',
        OBJECT_STORAGE_BUCKET: 'Invalid_Bucket',
        OBJECT_STORAGE_SIGNED_URL_SECONDS: 300,
      },
      { abortEarly: false, allowUnknown: true },
    );
    expect(error).toBeDefined();
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
