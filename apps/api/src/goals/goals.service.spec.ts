import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { GoalStatus, Prisma } from '@prisma/client';
import { GoalsService } from './goals.service';
import { PrismaService } from '../prisma/prisma.service';
import { ForecastStatus } from './forecast/goal-forecast.service';
import { ErrorCodes } from '../common/errors/error-codes';

describe('GoalsService', () => {
  const userId = '00000000-0000-4000-8000-000000000001';
  const otherUserId = '00000000-0000-4000-8000-000000000002';
  const goalId = '11111111-1111-4111-8111-111111111111';
  const milestoneId = '22222222-2222-4222-8222-222222222222';

  let prisma: {
    goal: {
      findMany: jest.Mock;
      findFirst: jest.Mock;
      findUnique: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
      delete: jest.Mock;
    };
    goalMilestone: {
      findFirst: jest.Mock;
      create: jest.Mock;
      update: jest.Mock;
      delete: jest.Mock;
      aggregate: jest.Mock;
    };
    goalProgressEntry: { create: jest.Mock };
    $transaction: jest.Mock;
  };
  let service: GoalsService;

  const futureDeadline = (() => {
    const d = new Date();
    d.setUTCFullYear(d.getUTCFullYear() + 1);
    return d;
  })();

  const baseGoal = {
    id: goalId,
    userId,
    name: 'Emergency fund',
    description: '',
    category: 'financial' as const,
    customCategoryName: null,
    priority: 'high' as const,
    status: GoalStatus.active,
    targetAmountMinor: new Prisma.Decimal(100_000),
    currentAmountMinor: new Prisma.Decimal(20_000),
    currencyCode: 'PKR',
    deadline: futureDeadline,
    progressPercent: 20,
    notes: '',
    archivedAt: null,
    createdAt: new Date(),
    updatedAt: new Date(),
    milestones: [] as unknown[],
    progressEntries: [] as unknown[],
  };

  beforeEach(() => {
    prisma = {
      goal: {
        findMany: jest.fn(),
        findFirst: jest.fn(),
        findUnique: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
      },
      goalMilestone: {
        findFirst: jest.fn(),
        create: jest.fn(),
        update: jest.fn(),
        delete: jest.fn(),
        aggregate: jest.fn(),
      },
      goalProgressEntry: { create: jest.fn() },
      $transaction: jest.fn(async (fn: (tx: typeof prisma) => unknown) =>
        fn(prisma),
      ),
    };
    service = new GoalsService(prisma as unknown as PrismaService);
  });

  describe('ownership', () => {
    it('throws Forbidden when goal belongs to another user', async () => {
      prisma.goal.findFirst.mockResolvedValue(null);
      prisma.goal.findUnique.mockResolvedValue({
        ...baseGoal,
        userId: otherUserId,
      });

      await expect(service.getById(userId, goalId)).rejects.toBeInstanceOf(
        ForbiddenException,
      );
    });

    it('throws NotFound when goal does not exist', async () => {
      prisma.goal.findFirst.mockResolvedValue(null);
      prisma.goal.findUnique.mockResolvedValue(null);

      await expect(service.getById(userId, goalId)).rejects.toBeInstanceOf(
        NotFoundException,
      );
    });
  });

  describe('validation', () => {
    it('requires customCategoryName for custom category', async () => {
      await expect(
        service.create(userId, {
          name: 'X',
          category: 'custom',
          deadline: futureDeadline.toISOString(),
        }),
      ).rejects.toMatchObject({
        response: expect.objectContaining({
          code: ErrorCodes.GOAL_CUSTOM_CATEGORY_REQUIRED,
        }),
      });
    });

    it('rejects non-custom category with stale customCategoryName', async () => {
      await expect(
        service.create(userId, {
          name: 'X',
          category: 'financial',
          customCategoryName: 'Nope',
          deadline: futureDeadline.toISOString(),
          currencyCode: 'PKR',
          targetAmountMinor: '100',
        }),
      ).rejects.toBeInstanceOf(BadRequestException);
    });

    it('rejects past deadline for active create', async () => {
      await expect(
        service.create(userId, {
          name: 'Late',
          category: 'career',
          deadline: '2020-01-01T00:00:00.000Z',
        }),
      ).rejects.toMatchObject({
        response: expect.objectContaining({
          code: ErrorCodes.GOAL_DEADLINE_IN_PAST,
        }),
      });
    });

    it('rejects current greater than target', async () => {
      await expect(
        service.create(userId, {
          name: 'House',
          category: 'financial',
          deadline: futureDeadline.toISOString(),
          targetAmountMinor: '100',
          currentAmountMinor: '200',
          currencyCode: 'PKR',
        }),
      ).rejects.toMatchObject({
        response: expect.objectContaining({
          code: ErrorCodes.GOAL_CURRENT_AMOUNT_EXCEEDS_TARGET,
        }),
      });
    });

    it('rejects amount without currency', async () => {
      await expect(
        service.create(userId, {
          name: 'House',
          category: 'financial',
          deadline: futureDeadline.toISOString(),
          targetAmountMinor: '15000000000',
        }),
      ).rejects.toMatchObject({
        response: expect.objectContaining({
          code: ErrorCodes.GOAL_CURRENCY_REQUIRED,
        }),
      });
    });

    it('rejects lowercase currency', async () => {
      await expect(
        service.create(userId, {
          name: 'House',
          category: 'financial',
          deadline: futureDeadline.toISOString(),
          targetAmountMinor: '100',
          currencyCode: 'pkr',
        }),
      ).rejects.toBeInstanceOf(BadRequestException);
    });

    it('rejects target zero', async () => {
      await expect(
        service.create(userId, {
          name: 'House',
          category: 'financial',
          deadline: futureDeadline.toISOString(),
          targetAmountMinor: '0',
          currencyCode: 'PKR',
        }),
      ).rejects.toBeInstanceOf(BadRequestException);
    });

    it('rejects invalid money string with decimal point', async () => {
      await expect(
        service.create(userId, {
          name: 'House',
          category: 'financial',
          deadline: futureDeadline.toISOString(),
          targetAmountMinor: '100.5' as unknown as string,
          currencyCode: 'PKR',
        }),
      ).rejects.toBeInstanceOf(BadRequestException);
    });

    it('requires progress fields when recording progress', async () => {
      prisma.goal.findFirst.mockResolvedValue({ ...baseGoal, milestones: [] });

      await expect(
        service.recordProgress(userId, goalId, {}),
      ).rejects.toBeInstanceOf(BadRequestException);
    });
  });

  describe('atomic create', () => {
    it('creates goal and milestones in one transaction', async () => {
      prisma.goal.create.mockResolvedValue({
        ...baseGoal,
        targetAmountMinor: new Prisma.Decimal('15000000000'),
        currentAmountMinor: new Prisma.Decimal(0),
        milestones: [
          {
            id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa1',
            goalId,
            title: 'Build deposit fund',
            description: null,
            targetDate: null,
            isCompleted: false,
            completedAt: null,
            order: 0,
            createdAt: new Date(),
            updatedAt: new Date(),
          },
          {
            id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaa2',
            goalId,
            title: 'Complete financing review',
            description: null,
            targetDate: null,
            isCompleted: false,
            completedAt: null,
            order: 1,
            createdAt: new Date(),
            updatedAt: new Date(),
          },
        ],
      });

      const result = await service.create(userId, {
        name: 'Buy a House',
        category: 'financial',
        deadline: futureDeadline.toISOString(),
        targetAmountMinor: '15000000000',
        currentAmountMinor: '0',
        currencyCode: 'PKR',
        milestones: [
          { title: 'Build deposit fund', order: 0 },
          { title: 'Complete financing review', order: 1 },
        ],
      });

      expect(prisma.$transaction).toHaveBeenCalled();
      expect(prisma.goal.create).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            targetAmountMinor: expect.any(Prisma.Decimal),
            milestones: expect.objectContaining({
              create: expect.arrayContaining([
                expect.objectContaining({ title: 'Build deposit fund' }),
                expect.objectContaining({
                  title: 'Complete financing review',
                }),
              ]),
            }),
          }),
        }),
      );
      expect(result.targetAmountMinor).toBe('15000000000');
      expect(result.milestones).toHaveLength(2);
    });

    it('rejects empty milestone title without creating goal', async () => {
      await expect(
        service.create(userId, {
          name: 'Buy a House',
          category: 'financial',
          deadline: futureDeadline.toISOString(),
          targetAmountMinor: '100',
          currencyCode: 'PKR',
          milestones: [{ title: '   ' }],
        }),
      ).rejects.toMatchObject({
        response: expect.objectContaining({
          code: ErrorCodes.GOAL_MILESTONE_INVALID,
        }),
      });
      expect(prisma.goal.create).not.toHaveBeenCalled();
    });
  });

  describe('addMilestone response', () => {
    it('returns exact createdMilestone even with duplicate titles', async () => {
      prisma.goal.findFirst.mockResolvedValue({ ...baseGoal, milestones: [] });
      prisma.goalMilestone.aggregate.mockResolvedValue({
        _max: { order: 0 },
      });
      const created = {
        id: milestoneId,
        goalId,
        title: 'Same',
        description: null,
        targetDate: null,
        isCompleted: false,
        completedAt: null,
        order: 1,
        createdAt: new Date(),
        updatedAt: new Date(),
      };
      prisma.goalMilestone.create.mockResolvedValue(created);
      prisma.goal.findFirst.mockResolvedValue({
        ...baseGoal,
        milestones: [{ ...created, id: 'other', order: 0 }, created],
      });

      // findOwnedGoal then getById both use findFirst
      prisma.goal.findFirst
        .mockResolvedValueOnce({ ...baseGoal, milestones: [] })
        .mockResolvedValueOnce({
          ...baseGoal,
          milestones: [created],
        });

      const result = await service.addMilestone(userId, goalId, {
        title: 'Same',
      });

      expect(result.createdMilestone.id).toBe(milestoneId);
      expect(result.goal).toBeDefined();
    });
  });

  describe('progress history', () => {
    it('creates a progress entry and updates the goal with large values', async () => {
      prisma.goal.findFirst
        .mockResolvedValueOnce({
          ...baseGoal,
          targetAmountMinor: new Prisma.Decimal('15000000000'),
          currentAmountMinor: new Prisma.Decimal(0),
          milestones: [],
        })
        .mockResolvedValueOnce({
          ...baseGoal,
          targetAmountMinor: new Prisma.Decimal('15000000000'),
          progressPercent: 50,
          currentAmountMinor: new Prisma.Decimal('7500000000'),
          milestones: [],
          progressEntries: [
            {
              id: '33333333-3333-4333-8333-333333333333',
              goalId,
              previousProgressPercent: 0,
              newProgressPercent: 50,
              previousAmountMinor: new Prisma.Decimal(0),
              newAmountMinor: new Prisma.Decimal('7500000000'),
              note: 'Halfway',
              createdAt: new Date(),
            },
          ],
        });
      prisma.goalProgressEntry.create.mockResolvedValue({});
      prisma.goal.update.mockResolvedValue({});

      const result = await service.recordProgress(userId, goalId, {
        currentAmountMinor: '7500000000',
        note: 'Halfway',
      });

      expect(prisma.goalProgressEntry.create).toHaveBeenCalled();
      expect(result.progressPercent).toBe(50);
      expect(result.currentAmountMinor).toBe('7500000000');
      expect(result.progressEntries).toHaveLength(1);
    });
  });

  describe('milestone completion', () => {
    it('marks milestone complete', async () => {
      prisma.goal.findFirst.mockResolvedValue({
        ...baseGoal,
        milestones: [
          {
            id: milestoneId,
            goalId,
            title: 'First',
            description: null,
            targetDate: null,
            isCompleted: false,
            completedAt: null,
            order: 0,
            createdAt: new Date(),
            updatedAt: new Date(),
          },
        ],
      });
      prisma.goalMilestone.findFirst.mockResolvedValue({
        id: milestoneId,
        goalId,
      });
      prisma.goalMilestone.update.mockResolvedValue({});

      await service.completeMilestone(userId, goalId, milestoneId);

      expect(prisma.goalMilestone.update).toHaveBeenCalledWith({
        where: { id: milestoneId },
        data: {
          isCompleted: true,
          completedAt: expect.any(Date),
        },
      });
    });
  });

  describe('forecast', () => {
    it('exposes deterministic forecast via computeForecast', () => {
      const deadline = new Date();
      deadline.setUTCDate(deadline.getUTCDate() + 60);
      const forecast = service.computeForecast({
        status: 'active',
        deadline,
        targetAmountMinor: new Prisma.Decimal(1_000_000),
        currentAmountMinor: new Prisma.Decimal(0),
      });
      expect(forecast.requiredMonthlyContributionMinor).toBeDefined();
      expect(typeof forecast.requiredMonthlyContributionMinor).toBe('string');
      expect([ForecastStatus.onTrack, ForecastStatus.atRisk]).toContain(
        forecast.status,
      );
    });
  });

  describe('archive', () => {
    it('sets archived status and timestamp', async () => {
      prisma.goal.findFirst.mockResolvedValue({ ...baseGoal, milestones: [] });
      prisma.goal.update.mockResolvedValue({
        ...baseGoal,
        status: GoalStatus.archived,
        archivedAt: new Date(),
        milestones: [],
      });

      const result = await service.archive(userId, goalId);
      expect(result.status).toBe(GoalStatus.archived);
      expect(prisma.goal.update).toHaveBeenCalledWith(
        expect.objectContaining({
          data: expect.objectContaining({
            status: GoalStatus.archived,
          }),
        }),
      );
    });
  });
});
