import * as Joi from 'joi';

/**
 * NestJS ConfigModule validation — only variables the application runtime
 * actually consumes. Database connectivity uses DATABASE_URL (Prisma).
 *
 * Docker Compose POSTGRES_* variables are infrastructure concerns and must
 * not be required here.
 */
export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'test', 'production')
    .default('development'),
  API_PORT: Joi.number().port().default(3000),
  API_GLOBAL_PREFIX: Joi.string().default('api/v1'),
  CORS_ORIGINS: Joi.string()
    .allow('')
    .when('NODE_ENV', {
      is: 'production',
      then: Joi.string().invalid('*').required(),
      otherwise: Joi.string().default('*'),
    }),

  DATABASE_URL: Joi.string().uri().required(),

  // Public URL is used by clients + used for safe production config checks.
  API_PUBLIC_URL: Joi.string()
    .uri({ scheme: ['https'] })
    .custom((value, helpers) => {
      const host = new URL(value).hostname;
      if (host.includes('.invalid')) {
        return helpers.error('any.invalid');
      }
      const lowered = host.toLowerCase();
      if (
        lowered === 'localhost' ||
        lowered === '127.0.0.1' ||
        lowered.endsWith('.local') ||
        lowered.startsWith('10.') ||
        lowered.startsWith('192.168.') ||
        lowered.startsWith('172.16.') ||
        lowered.startsWith('172.17.') ||
        lowered.startsWith('172.18.') ||
        lowered.startsWith('172.19.') ||
        lowered.startsWith('172.2') || // matches 172.20-172.29
        lowered.startsWith('172.3') || // matches 172.30-172.31
        lowered.startsWith('169.254.')
      ) {
        return helpers.error('any.invalid');
      }
      return value;
    })
    .when('NODE_ENV', {
      is: 'production',
      then: Joi.required(),
      otherwise: Joi.optional(),
    }),

  OBJECT_STORAGE_ENDPOINT: Joi.string().min(1).when('NODE_ENV', {
    is: 'production',
    then: Joi.required(),
    otherwise: Joi.optional(),
  }),
  OBJECT_STORAGE_REGION: Joi.string().allow('').optional(),
  OBJECT_STORAGE_ACCESS_KEY: Joi.string().min(8).when('NODE_ENV', {
    is: 'production',
    then: Joi.required(),
    otherwise: Joi.optional(),
  }),
  OBJECT_STORAGE_SECRET_KEY: Joi.string().min(8).when('NODE_ENV', {
    is: 'production',
    then: Joi.required(),
    otherwise: Joi.optional(),
  }),
  OBJECT_STORAGE_BUCKET: Joi.string()
    .pattern(/^[a-z0-9](?:[a-z0-9-]{1,61}[a-z0-9])?$/)
    .when('NODE_ENV', {
      is: 'production',
      then: Joi.required(),
      otherwise: Joi.optional(),
    }),
  OBJECT_STORAGE_SIGNED_URL_SECONDS: Joi.number()
    .integer()
    .min(60)
    .max(3600)
    .when('NODE_ENV', {
      is: 'production',
      then: Joi.required(),
      otherwise: Joi.optional(),
    }),

  DEV_USER_ID: Joi.string().uuid().when('NODE_ENV', {
    is: 'production',
    then: Joi.optional(),
    otherwise: Joi.required(),
  }),
  DEV_USER_EMAIL: Joi.string().email().optional(),
  DEV_USER_DISPLAY_NAME: Joi.string().default('Dev User'),
  DEV_USER_TIMEZONE: Joi.string().default('UTC'),
  DEV_USER_CURRENCY: Joi.string().length(3).default('PKR'),
  JWT_ACCESS_SECRET: Joi.string()
    .min(32)
    .when('NODE_ENV', {
      is: 'production',
      then: Joi.required(),
      otherwise: Joi.optional().default('memy-dev-access-secret-min-32-chars'),
    }),
  REFRESH_TOKEN_PEPPER: Joi.string()
    .min(16)
    .when('NODE_ENV', {
      is: 'production',
      then: Joi.required(),
      otherwise: Joi.optional().default('memy-dev-refresh-pepper'),
    }),
  GOOGLE_CLIENT_ID: Joi.string().allow('').optional(),
  APPLE_CLIENT_ID: Joi.string().allow('').optional(),
  ADMIN_BOOTSTRAP_EMAIL: Joi.string().email().optional(),
  ADMIN_BOOTSTRAP_PASSWORD: Joi.string().min(12).max(128).optional(),
});

export type AppConfig = {
  nodeEnv: string;
  apiPort: number;
  globalPrefix: string;
  corsOrigins: string[];
  databaseUrl: string;
  devUser: {
    id: string;
    email?: string;
    displayName: string;
    timezone: string;
    currencyCode: string;
  };
  auth: {
    accessSecret: string;
    refreshPepper: string;
    googleClientId?: string;
    appleClientId?: string;
  };
  admin: {
    bootstrapEmail?: string;
    bootstrapPassword?: string;
  };
};

export default (): AppConfig => {
  const corsRaw = process.env.CORS_ORIGINS ?? '*';
  return {
    nodeEnv: process.env.NODE_ENV ?? 'development',
    apiPort: Number(process.env.API_PORT ?? 3000),
    globalPrefix: process.env.API_GLOBAL_PREFIX ?? 'api/v1',
    corsOrigins:
      corsRaw.trim() === '*'
        ? ['*']
        : corsRaw
            .split(',')
            .map((origin) => origin.trim())
            .filter(Boolean),
    databaseUrl: process.env.DATABASE_URL ?? '',
    devUser: {
      id: process.env.DEV_USER_ID ?? '',
      email: process.env.DEV_USER_EMAIL,
      displayName: process.env.DEV_USER_DISPLAY_NAME ?? 'Dev User',
      timezone: process.env.DEV_USER_TIMEZONE ?? 'UTC',
      currencyCode: process.env.DEV_USER_CURRENCY ?? 'PKR',
    },
    auth: {
      accessSecret:
        process.env.JWT_ACCESS_SECRET ?? 'memy-dev-access-secret-min-32-chars',
      refreshPepper:
        process.env.REFRESH_TOKEN_PEPPER ?? 'memy-dev-refresh-pepper',
      googleClientId: process.env.GOOGLE_CLIENT_ID || undefined,
      appleClientId: process.env.APPLE_CLIENT_ID || undefined,
    },
    admin: {
      bootstrapEmail: process.env.ADMIN_BOOTSTRAP_EMAIL || undefined,
      bootstrapPassword: process.env.ADMIN_BOOTSTRAP_PASSWORD || undefined,
    },
  };
};
