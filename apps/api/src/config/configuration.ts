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
  CORS_ORIGINS: Joi.string().allow('').default('*'),
  DATABASE_URL: Joi.string().uri().required(),
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
  };
};
