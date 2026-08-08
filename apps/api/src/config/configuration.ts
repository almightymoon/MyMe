import * as Joi from 'joi';

export const envValidationSchema = Joi.object({
  NODE_ENV: Joi.string()
    .valid('development', 'test', 'production')
    .default('development'),
  API_PORT: Joi.number().port().default(3000),
  API_GLOBAL_PREFIX: Joi.string().default('api/v1'),
  CORS_ORIGINS: Joi.string().allow('').default('*'),
  DATABASE_URL: Joi.string().uri().required(),
  POSTGRES_HOST: Joi.string().default('localhost'),
  POSTGRES_PORT: Joi.number().port().default(5432),
  POSTGRES_DB: Joi.string().default('memy'),
  POSTGRES_USER: Joi.string().default('memy'),
  POSTGRES_PASSWORD: Joi.string().required(),
  DEV_USER_ID: Joi.string().uuid().required(),
  DEV_USER_EMAIL: Joi.string().email().optional(),
  DEV_USER_DISPLAY_NAME: Joi.string().default('Dev User'),
  DEV_USER_TIMEZONE: Joi.string().default('UTC'),
  DEV_USER_CURRENCY: Joi.string().length(3).default('PKR'),
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
  };
};
