import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { PrismaClient } from '@prisma/client';
import { AppModule } from '../src/app.module';
import { AllExceptionsFilter } from '../src/common/filters/http-exception.filter';
import { assertSafeE2eDatabase } from '../src/common/testing/e2e-db-guard';

const DEV_USER_ID =
  process.env.DEV_USER_ID ?? '00000000-0000-4000-8000-000000000001';
const OTHER_USER_ID = '00000000-0000-4000-8000-000000000002';

function futureDeadlineIso(): string {
  const d = new Date();
  d.setUTCFullYear(d.getUTCFullYear() + 1);
  return d.toISOString();
}

describe('Goals API (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaClient;
  const auth = { 'X-Dev-User-Id': DEV_USER_ID };

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
    assertSafeE2eDatabase({
      nodeEnv: process.env.NODE_ENV,
      databaseUrlTest: process.env.DATABASE_URL_TEST ?? e2eDatabaseUrl,
      developmentDatabaseUrl: process.env.DEV_DATABASE_URL,
      allowDatabaseUrlFallback: false,
    });

    const fixtureUserIds = [DEV_USER_ID, OTHER_USER_ID];
    await prisma.goalProgressEntry.deleteMany({
      where: { goal: { userId: { in: fixtureUserIds } } },
    });
    await prisma.goalMilestone.deleteMany({
      where: { goal: { userId: { in: fixtureUserIds } } },
    });
    await prisma.goal.deleteMany({
      where: { userId: { in: fixtureUserIds } },
    });
  });

  afterAll(async () => {
    if (app) {
      await app.close();
    }
    if (prisma) {
      await prisma.$disconnect();
    }
  });

  it('GET /health', async () => {
    const res = await request(app.getHttpServer())
      .get('/api/v1/health')
      .expect(200);
    expect(res.body.status).toBe('ok');
    expect(res.body.database).toBe('up');
  });

  it('creates large PKR goal with string money and nested milestones', async () => {
    const createRes = await request(app.getHttpServer())
      .post('/api/v1/goals')
      .set(auth)
      .send({
        name: 'Buy a House',
        description: 'Purchase a family home',
        category: 'financial',
        priority: 'high',
        targetAmountMinor: '15000000000',
        currentAmountMinor: '0',
        currencyCode: 'PKR',
        deadline: futureDeadlineIso(),
        milestones: [
          { title: 'Build deposit fund', order: 0 },
          { title: 'Complete financing review', order: 1 },
        ],
      })
      .expect(201);

    expect(createRes.body.targetAmountMinor).toBe('15000000000');
    expect(typeof createRes.body.targetAmountMinor).toBe('string');
    expect(createRes.body.currentAmountMinor).toBe('0');
    expect(createRes.body.milestones).toHaveLength(2);
    expect(createRes.body.forecast.remainingAmountMinor).toBe('15000000000');
    expect(
      typeof createRes.body.forecast.requiredMonthlyContributionMinor,
    ).toBe('string');

    const goalId = createRes.body.id as string;
    const count = await prisma.goalMilestone.count({ where: { goalId } });
    expect(count).toBe(2);
  });

  it('rejects invalid nested milestone without creating the goal', async () => {
    const before = await prisma.goal.count({ where: { userId: DEV_USER_ID } });
    await request(app.getHttpServer())
      .post('/api/v1/goals')
      .set(auth)
      .send({
        name: 'Bad milestones',
        category: 'financial',
        targetAmountMinor: '100',
        currencyCode: 'PKR',
        deadline: futureDeadlineIso(),
        milestones: [{ title: '' }],
      })
      .expect(400);

    const after = await prisma.goal.count({ where: { userId: DEV_USER_ID } });
    expect(after).toBe(before);
  });

  it('rejects current > target and amount without currency', async () => {
    await request(app.getHttpServer())
      .post('/api/v1/goals')
      .set(auth)
      .send({
        name: 'Overflow',
        category: 'financial',
        targetAmountMinor: '100',
        currentAmountMinor: '200',
        currencyCode: 'PKR',
        deadline: futureDeadlineIso(),
      })
      .expect(400);

    await request(app.getHttpServer())
      .post('/api/v1/goals')
      .set(auth)
      .send({
        name: 'No currency',
        category: 'financial',
        targetAmountMinor: '15000000000',
        deadline: futureDeadlineIso(),
      })
      .expect(400);
  });

  it('returns exact createdMilestone for duplicate titles', async () => {
    const createRes = await request(app.getHttpServer())
      .post('/api/v1/goals')
      .set(auth)
      .send({
        name: 'Dup titles',
        category: 'career',
        deadline: futureDeadlineIso(),
      })
      .expect(201);
    const goalId = createRes.body.id as string;

    const first = await request(app.getHttpServer())
      .post(`/api/v1/goals/${goalId}/milestones`)
      .set(auth)
      .send({ title: 'Same title' })
      .expect(201);
    expect(first.body.createdMilestone.title).toBe('Same title');
    expect(first.body.createdMilestone.id).toBeDefined();
    expect(first.body.goal.milestones).toHaveLength(1);

    const second = await request(app.getHttpServer())
      .post(`/api/v1/goals/${goalId}/milestones`)
      .set(auth)
      .send({ title: 'Same title' })
      .expect(201);
    expect(second.body.createdMilestone.title).toBe('Same title');
    expect(second.body.createdMilestone.id).not.toBe(
      first.body.createdMilestone.id,
    );
    expect(second.body.goal.milestones).toHaveLength(2);
  });

  it('full goal lifecycle + ownership', async () => {
    const createRes = await request(app.getHttpServer())
      .post('/api/v1/goals')
      .set(auth)
      .send({
        name: 'Emergency fund',
        category: 'financial',
        priority: 'high',
        targetAmountMinor: '1000000',
        currentAmountMinor: '100000',
        currencyCode: 'PKR',
        deadline: futureDeadlineIso(),
        progressPercent: 10,
      })
      .expect(201);

    const goalId = createRes.body.id as string;
    expect(createRes.body.forecast).toBeDefined();
    expect(createRes.body.userId).toBe(DEV_USER_ID);
    expect(typeof createRes.body.targetAmountMinor).toBe('string');

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
    const milestoneId = milestoneRes.body.createdMilestone.id as string;

    await request(app.getHttpServer())
      .post(`/api/v1/goals/${goalId}/milestones/${milestoneId}/complete`)
      .set(auth)
      .expect(201);

    await request(app.getHttpServer())
      .post(`/api/v1/goals/${goalId}/progress`)
      .set(auth)
      .send({ currentAmountMinor: '500000', note: 'Halfway' })
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

  it('ignores conflicting client progressPercent for financial create and progress', async () => {
    const reached = await request(app.getHttpServer())
      .post('/api/v1/goals')
      .set(auth)
      .send({
        name: 'Reached',
        category: 'financial',
        targetAmountMinor: '10000',
        currentAmountMinor: '10000',
        currencyCode: 'PKR',
        progressPercent: 5,
        deadline: futureDeadlineIso(),
      })
      .expect(201);
    expect(reached.body.progressPercent).toBe(100);

    const quarter = await request(app.getHttpServer())
      .post('/api/v1/goals')
      .set(auth)
      .send({
        name: 'Quarter',
        category: 'financial',
        targetAmountMinor: '10000',
        currentAmountMinor: '2500',
        currencyCode: 'PKR',
        progressPercent: 80,
        deadline: futureDeadlineIso(),
      })
      .expect(201);
    expect(quarter.body.progressPercent).toBe(25);

    const progress = await request(app.getHttpServer())
      .post(`/api/v1/goals/${quarter.body.id}/progress`)
      .set(auth)
      .send({ currentAmountMinor: '5000', progressPercent: 99 })
      .expect(201);
    expect(progress.body.progressPercent).toBe(50);

    const today = await request(app.getHttpServer())
      .get('/api/v1/today')
      .set(auth)
      .expect(200);
    expect(today.body.activeGoalCount).toBeGreaterThanOrEqual(1);
    expect(today.body.averageGoalProgress).toBeGreaterThan(0);
    const listed = await request(app.getHttpServer())
      .get('/api/v1/goals')
      .set(auth)
      .expect(200);
    const stored = (
      listed.body as Array<{ id: string; progressPercent: number }>
    ).find((g) => g.id === quarter.body.id);
    expect(stored?.progressPercent).toBe(50);
  });
});
