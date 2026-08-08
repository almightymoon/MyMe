import {
  BadRequestException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { GoalStatus } from '@prisma/client';
import { GoalsService } from './goals.service';
import { PrismaService } from '../prisma/prisma.service';
import { ForecastStatus } from './forecast/goal-forecast.service';

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

  const baseGoal = {
    id: goalId,
    userId,
    name: 'Emergency fund',
    description: '',
    category: 'financial' as const,
    customCategoryName: null,
    priority: 'high' as const,
    status: GoalStatus.active,
    targetAmountMinor: 100_000,
    currentAmountMinor: 20_000,
    currencyCode: 'PKR',
    deadline: new Date(Date.UTC(2026, 11, 31)),
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
          deadline: '2026-12-31T00:00:00.000Z',
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

  describe('progress history', () => {
    it('creates a progress entry and updates the goal', async () => {
      prisma.goal.findFirst
        .mockResolvedValueOnce({ ...baseGoal, milestones: [] })
        .mockResolvedValueOnce({
          ...baseGoal,
          progressPercent: 50,
          currentAmountMinor: 50_000,
          milestones: [],
          progressEntries: [
            {
              id: '33333333-3333-4333-8333-333333333333',
              goalId,
              previousProgressPercent: 20,
              newProgressPercent: 50,
              previousAmountMinor: 20_000,
              newAmountMinor: 50_000,
              note: 'Halfway',
              createdAt: new Date(),
            },
          ],
        });
      prisma.goalProgressEntry.create.mockResolvedValue({});
      prisma.goal.update.mockResolvedValue({});

      const result = await service.recordProgress(userId, goalId, {
        currentAmountMinor: 50_000,
        note: 'Halfway',
      });

      expect(prisma.goalProgressEntry.create).toHaveBeenCalled();
      expect(result.progressPercent).toBe(50);
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
        targetAmountMinor: 1_000_000,
        currentAmountMinor: 0,
      });
      expect(forecast.requiredMonthlyContributionMinor).toBeDefined();
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
