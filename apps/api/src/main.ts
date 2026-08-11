import { Logger, ValidationPipe } from '@nestjs/common';
import helmet from 'helmet';
import { ConfigService } from '@nestjs/config';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { AppModule } from './app.module';
import { AppConfig } from './config/configuration';
import { AllExceptionsFilter } from './common/filters/http-exception.filter';
import { RequestLoggingInterceptor } from './common/interceptors/logging.interceptor';

async function bootstrap(): Promise<void> {
  const app = await NestFactory.create(AppModule, {
    bufferLogs: true,
  });
  const config = app.get(ConfigService<AppConfig, true>);
  const logger = new Logger('Bootstrap');

  const globalPrefix = config.get('globalPrefix', { infer: true });
  app.setGlobalPrefix(globalPrefix);
  app.use(helmet());

  const corsOrigins = config.get('corsOrigins', { infer: true });
  const nodeEnv = config.get('nodeEnv', { infer: true });
  const allowAnyOrigin = corsOrigins.includes('*');
  if (nodeEnv === 'production' && allowAnyOrigin) {
    throw new Error(
      'CORS_ORIGINS=* is not allowed in production. Set an explicit allowlist.',
    );
  }
  app.enableCors({
    origin: allowAnyOrigin ? true : corsOrigins,
    // Reflect-any Origin is incompatible with credentialed browsers safely.
    credentials: !allowAnyOrigin,
  });

  app.useGlobalPipes(
    new ValidationPipe({
      transform: true,
      whitelist: true,
      forbidNonWhitelisted: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );
  app.useGlobalFilters(new AllExceptionsFilter());
  app.useGlobalInterceptors(new RequestLoggingInterceptor());

  app.enableShutdownHooks();

  const swaggerConfig = new DocumentBuilder()
    .setTitle('MeMy API')
    .setDescription(
      [
        'MeMy personal life OS — Goals vertical slice.',
        '',
        '## Development authentication',
        'Outside production, send header `X-Dev-User-Id` equal to `DEV_USER_ID`,',
        'or `Authorization: Bearer dev <DEV_USER_ID>`.',
        'Production refuses development authentication.',
        '',
        '## Money',
        'Amounts use integer minor units (e.g. cents / paisa).',
        '',
        '## Errors',
        'Errors follow `{ statusCode, code, message, details, timestamp, path }`.',
      ].join('\n'),
    )
    .setVersion('0.0.1')
    .addApiKey(
      {
        type: 'apiKey',
        in: 'header',
        name: 'X-Dev-User-Id',
        description: 'Development user UUID (must match DEV_USER_ID)',
      },
      'dev-user',
    )
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'dev <uuid>',
        description: 'Authorization: Bearer dev <DEV_USER_ID>',
      },
      'dev-auth',
    )
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('docs', app, document, {
    useGlobalPrefix: false,
  });

  const port = config.get('apiPort', { infer: true });
  await app.listen(port);
  logger.log(`Listening on http://localhost:${port}/${globalPrefix}`);
  logger.log(`Swagger UI at http://localhost:${port}/docs`);
}

bootstrap().catch((error: unknown) => {
  // eslint-disable-next-line no-console
  console.error('Failed to start API', error);
  process.exit(1);
});
