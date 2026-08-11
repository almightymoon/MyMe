import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { PrismaClient } from '@prisma/client';
import { AppModule } from '../src/app.module';
import { AllExceptionsFilter } from '../src/common/filters/http-exception.filter';
import { assertSafeE2eDatabase } from '../src/common/testing/e2e-db-guard';
import {
  GOOGLE_TOKEN_VERIFIER,
  APPLE_TOKEN_VERIFIER,
  IdentityTokenVerifier,
} from '../src/auth/identity/identity-token.verifier';
import { VerifiedIdentity } from '../src/auth/identity/verified-identity';

const device = {
  clientGeneratedDeviceId: 'e2e-device-aaaaaaaa',
  platform: 'ios',
  appVersion: '1.0.0',
};

class StubVerifier implements IdentityTokenVerifier {
  constructor(private readonly identity: VerifiedIdentity) {}
  async verify(): Promise<VerifiedIdentity> {
    return this.identity;
  }
}

describe('Auth and sync (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaClient;

  const e2eDatabaseUrl = assertSafeE2eDatabase({
    nodeEnv: process.env.NODE_ENV,
    databaseUrlTest: process.env.DATABASE_URL_TEST,
    developmentDatabaseUrl: process.env.DEV_DATABASE_URL,
    allowDatabaseUrlFallback: false,
  });

  beforeAll(async () => {
    process.env.DATABASE_URL = e2eDatabaseUrl;
    prisma = new PrismaClient({
      datasources: { db: { url: e2eDatabaseUrl } },
    });
    await prisma.$connect();

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(GOOGLE_TOKEN_VERIFIER)
      .useValue(
        new StubVerifier({
          provider: 'google',
          subject: 'google-sub-e2e',
          email: 'ada@example.com',
          emailVerified: true,
          displayName: 'Ada',
        }),
      )
      .overrideProvider(APPLE_TOKEN_VERIFIER)
      .useValue(
        new StubVerifier({
          provider: 'apple',
          subject: 'apple-sub-e2e',
          email: 'ada@example.com',
          emailVerified: true,
        }),
      )
      .compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix(process.env.API_GLOBAL_PREFIX ?? 'api/v1');
    app.useGlobalPipes(
      new ValidationPipe({
        transform: true,
        whitelist: true,
        forbidNonWhitelisted: true,
      }),
    );
    app.useGlobalFilters(new AllExceptionsFilter());
    await app.init();
  });

  afterAll(async () => {
    await app.close();
    await prisma.$disconnect();
  });

  it('creates an empty Google account and isolates sync from Apple email match', async () => {
    const google = await request(app.getHttpServer())
      .post('/api/v1/auth/google')
      .send({ idToken: 'fake-google-id-token-value', device })
      .expect(200);
    expect(google.body.bootstrapEmpty).toBe(true);
    expect(google.body.user.email).toBe('ada@example.com');

    const apple = await request(app.getHttpServer())
      .post('/api/v1/auth/apple')
      .send({
        identityToken: 'fake-apple-identity-token-value',
        device: { ...device, clientGeneratedDeviceId: 'e2e-device-bbbbbbbb' },
      })
      .expect(200);
    expect(apple.body.user.id).not.toEqual(google.body.user.id);

    const goalId = '11111111-1111-4111-8111-111111111111';
    const mutationId = '22222222-2222-4222-8222-222222222222';
    await request(app.getHttpServer())
      .post('/api/v1/sync/push')
      .set('Authorization', `Bearer ${google.body.accessToken}`)
      .send({
        clientGeneratedDeviceId: device.clientGeneratedDeviceId,
        mutations: [
          {
            mutationId,
            entityType: 'goal',
            entityId: goalId,
            operation: 'create',
            clientUpdatedAt: new Date().toISOString(),
            payload: { name: 'Emergency fund' },
          },
        ],
      })
      .expect(201);

    const pulled = await request(app.getHttpServer())
      .get('/api/v1/sync/pull')
      .set('Authorization', `Bearer ${apple.body.accessToken}`)
      .query({ cursor: 0 })
      .expect(200);
    expect(pulled.body.changes).toEqual([]);

    const health = await request(app.getHttpServer())
      .post('/api/v1/sync/push')
      .set('Authorization', `Bearer ${google.body.accessToken}`)
      .send({
        clientGeneratedDeviceId: device.clientGeneratedDeviceId,
        mutations: [
          {
            mutationId: '33333333-3333-4333-8333-333333333333',
            entityType: 'health',
            entityId: '44444444-4444-4444-8444-444444444444',
            operation: 'create',
            clientUpdatedAt: new Date().toISOString(),
            payload: { heartRate: 70 },
          },
        ],
      })
      .expect(201);
    expect(health.body.failures[0].code).toBe('SYNC_ENTITY_FORBIDDEN');
  });
});
