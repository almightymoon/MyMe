import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { PrismaClient } from '@prisma/client';
import { AppModule } from '../src/app.module';
import { AllExceptionsFilter } from '../src/common/filters/http-exception.filter';

const DEV_USER_ID =
  process.env.DEV_USER_ID ?? '00000000-0000-4000-8000-000000000001';
const OTHER_USER_ID = '00000000-0000-4000-8000-000000000002';

describe('Goals API (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaClient;
  const auth = { 'X-Dev-User-Id': DEV_USER_ID };

  beforeAll(async () => {
    prisma = new PrismaClient();
    await prisma.$connect();

    await prisma.user.upsert({
      where: { id: DEV_USER_ID },
      update: {},
      create: {
        id: DEV_USER_ID,
        email: 'emma@example.com',
        displayName: 'Emma Chen',
        timezone: 'Asia/Karachi',
        currencyCode: 'PKR',
      },
    });
    await prisma.user.upsert({
      where: { id: OTHER_USER_ID },
      update: {},
      create: {
        id: OTHER_USER_ID,
        email: 'other@example.com',
        displayName: 'Other User',
        timezone: 'UTC',
        currencyCode: 'USD',
      },
    });

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

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

  beforeEach(async () => {
    await prisma.goalProgressEntry.deleteMany();
    await prisma.goalMilestone.deleteMany();
    await prisma.goal.deleteMany();
  });

  afterAll(async () => {
    await app.close();
    await prisma.$disconnect();
  });

  it('GET /health', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/v1/health')
      .expect(200);
    expect(res.body.status).toMatch(/ok|degraded/);
    expect(res.body.database).toBeDefined();
  });

  it('full goal lifecycle + ownership', async () => {
    const createRes = await request(app.getHttpServer())
      .post('/api/v1/goals')
      .set(auth)
      .send({
        name: 'Emergency fund',
        category: 'financial',
        priority: 'high',
        targetAmountMinor: 1000000,
        currentAmountMinor: 100000,
        currencyCode: 'PKR',
        deadline: '2026-12-31T00:00:00.000Z',
        progressPercent: 10,
      })
      .expect(201);

    const goalId = createRes.body.id as string;
    expect(createRes.body.forecast).toBeDefined();
    expect(createRes.body.userId).toBe(DEV_USER_ID);

    const listRes = await request(app.getHttpServer())
      .get('/api/v1/goals')
      .set(auth)
      .expect(200);
    expect(listRes.body).toHaveLength(1);

    await request(app.getHttpServer())
      .get(`/api/v1/goals/${goalId}`)
      .set(auth)
      .expect(200);

    await request(app.getHttpServer())
      .patch(`/api/v1/goals/${goalId}`)
      .set(auth)
      .send({ notes: 'Updated' })
      .expect(200);

    const milestoneRes = await request(app.getHttpServer())
      .post(`/api/v1/goals/${goalId}/milestones`)
      .set(auth)
      .send({ title: 'First 100k' })
      .expect(201);
    const milestoneId = milestoneRes.body.milestones[0].id as string;

    await request(app.getHttpServer())
      .post(`/api/v1/goals/${goalId}/milestones/${milestoneId}/complete`)
      .set(auth)
      .expect(201);

    await request(app.getHttpServer())
      .post(`/api/v1/goals/${goalId}/progress`)
      .set(auth)
      .send({ currentAmountMinor: 500000, note: 'Halfway' })
      .expect(201);

    const today = await request(app.getHttpServer())
      .get('/api/v1/today')
      .set(auth)
      .expect(200);
    expect(today.body.activeGoalCount).toBe(1);

    await request(app.getHttpServer())
      .post(`/api/v1/goals/${goalId}/archive`)
      .set(auth)
      .expect(201);

    const otherGoal = await prisma.goal.create({
      data: {
        userId: OTHER_USER_ID,
        name: 'Secret',
        category: 'career',
        deadline: new Date('2027-01-01T00:00:00.000Z'),
        progressPercent: 0,
      },
    });

    await request(app.getHttpServer())
      .get(`/api/v1/goals/${otherGoal.id}`)
      .set(auth)
      .expect(403);

    await request(app.getHttpServer())
      .delete(`/api/v1/goals/${goalId}`)
      .set(auth)
      .expect(204);
  });

  it('rejects unauthenticated requests', async () => {
    await request(app.getHttpServer()).get('/api/v1/goals').expect(401);
  });
});
