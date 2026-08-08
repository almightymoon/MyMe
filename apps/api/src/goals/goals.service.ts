import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Goal, GoalMilestone, GoalStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { ErrorCodes } from '../common/errors/error-codes';
import {
  CreateGoalDto,
  CreateMilestoneDto,
  ListGoalsQueryDto,
  RecordProgressDto,
  UpdateGoalDto,
  UpdateMilestoneDto,
} from './dto/goal.dto';
import {
  GoalResponseDto,
  GoalWithRelations,
  MilestoneCreateResponseDto,
  toGoalDto,
  toMilestoneDto,
} from './dto/goal-response.dto';
import { GoalForecastService } from './forecast/goal-forecast.service';
import {
  moneyMinorToApiString,
  parseOptionalMoneyMinorString,
  progressPercentFromAmounts,
} from './money/money-minor';
import { GoalBusinessValidator } from './validation/goal-business.validator';

@Injectable()
export class GoalsService {
  private readonly forecastService = new GoalForecastService();

  constructor(private readonly prisma: PrismaService) {}

  async list(
    userId: string,
    query: ListGoalsQueryDto,
  ): Promise<GoalResponseDto[]> {
    const where: Prisma.GoalWhereInput = { userId };
    if (query.status) {
      where.status = query.status;
    } else if (!query.includeArchived) {
      where.status = { not: GoalStatus.archived };
      where.archivedAt = null;
    }

    const goals = await this.prisma.goal.findMany({
      where,
      include: { milestones: { orderBy: { order: 'asc' } } },
      orderBy: [{ deadline: 'asc' }, { createdAt: 'desc' }],
    });

    return goals.map((g: GoalWithRelations) => this.mapGoal(g));
  }

  async getById(
    userId: string,
    id: string,
    includeProgress = true,
  ): Promise<GoalResponseDto> {
    const goal = await this.findOwnedGoal(userId, id, includeProgress);
    return this.mapGoal(goal, includeProgress);
  }

  async create(userId: string, dto: CreateGoalDto): Promise<GoalResponseDto> {
    const name = GoalBusinessValidator.assertName(dto.name, true)!;
    const status = dto.status ?? GoalStatus.active;
    const deadline = new Date(dto.deadline);
    GoalBusinessValidator.assertDeadlineNotPastForActiveCreate(
      deadline,
      status,
    );

    const { customCategoryName } = GoalBusinessValidator.assertCategory(
      dto.category,
      dto.customCategoryName,
    );

    const money = GoalBusinessValidator.parseAndAssertMoney({
      targetAmountMinor: dto.targetAmountMinor,
      currentAmountMinor: dto.currentAmountMinor,
      currencyCode: dto.currencyCode,
    });

    const milestonesInput = dto.milestones ?? [];
    const normalizedMilestones =
      this.normalizeInitialMilestones(milestonesInput);

    let progressPercent =
      GoalBusinessValidator.assertProgressPercent(dto.progressPercent) ?? 0;

    const target = money.targetAmountMinor ?? null;
    const current =
      money.currentAmountMinor !== undefined
        ? money.currentAmountMinor
        : target != null
          ? new Prisma.Decimal(0)
          : null;

    if (
      dto.progressPercent === undefined &&
      target != null &&
      current != null &&
      target.gt(0)
    ) {
      progressPercent = progressPercentFromAmounts(current, target);
    }

    const goal = await this.prisma.$transaction(async (tx) => {
      return tx.goal.create({
        data: {
          userId,
          name,
          description: dto.description?.trim() ?? '',
          category: dto.category,
          customCategoryName,
          priority: dto.priority ?? 'medium',
          status,
          targetAmountMinor: target,
          currentAmountMinor: current,
          currencyCode: money.currencyCode ?? null,
          deadline,
          progressPercent,
          notes: dto.notes?.trim() ?? '',
          milestones: {
            create: normalizedMilestones.map((m) => ({
              title: m.title,
              description: m.description ?? null,
              targetDate: m.targetDate ? new Date(m.targetDate) : null,
              order: m.order,
            })),
          },
        },
        include: { milestones: { orderBy: { order: 'asc' } } },
      });
    });

    return this.mapGoal(goal);
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateGoalDto,
  ): Promise<GoalResponseDto> {
    const existing = await this.findOwnedGoal(userId, id, false);

    if (dto.name !== undefined) {
      GoalBusinessValidator.assertName(dto.name, true);
    }

    const category = dto.category ?? existing.category;
    const customIncoming =
      dto.customCategoryName !== undefined
        ? dto.customCategoryName
        : existing.customCategoryName;
    const { customCategoryName } = GoalBusinessValidator.assertCategory(
      category,
      // When category changes away from custom, force clear even if stale value present
      dto.category !== undefined && dto.category !== 'custom'
        ? dto.customCategoryName === undefined
          ? null
          : dto.customCategoryName
        : customIncoming,
    );

    const money = GoalBusinessValidator.parseAndAssertMoney(
      {
        ...(dto.targetAmountMinor !== undefined
          ? { targetAmountMinor: dto.targetAmountMinor }
          : {}),
        ...(dto.currentAmountMinor !== undefined
          ? { currentAmountMinor: dto.currentAmountMinor }
          : {}),
        ...(dto.currencyCode !== undefined
          ? { currencyCode: dto.currencyCode }
          : {}),
      },
      {
        targetAmountMinor: existing.targetAmountMinor,
        currentAmountMinor: existing.currentAmountMinor,
        currencyCode: existing.currencyCode,
      },
    );

    const data: Prisma.GoalUpdateInput = {};
    if (dto.name !== undefined) data.name = dto.name.trim();
    if (dto.description !== undefined) {
      data.description = dto.description.trim();
    }
    if (dto.category !== undefined) {
      data.category = dto.category;
      data.customCategoryName = customCategoryName;
    } else if (dto.customCategoryName !== undefined) {
      data.customCategoryName = customCategoryName;
    }
    if (dto.priority !== undefined) data.priority = dto.priority;
    if (dto.status !== undefined) {
      data.status = dto.status;
      data.archivedAt = dto.status === GoalStatus.archived ? new Date() : null;
    }
    if (money.targetAmountMinor !== undefined) {
      data.targetAmountMinor = money.targetAmountMinor;
    }
    if (money.currentAmountMinor !== undefined) {
      data.currentAmountMinor = money.currentAmountMinor;
    }
    if (money.currencyCode !== undefined) {
      data.currencyCode = money.currencyCode;
    }
    if (dto.deadline !== undefined) data.deadline = new Date(dto.deadline);
    if (dto.notes !== undefined) data.notes = dto.notes.trim();

    // Prefer server-calculated financial progress when amounts are present.
    const nextTarget =
      money.targetAmountMinor !== undefined
        ? money.targetAmountMinor
        : existing.targetAmountMinor;
    const nextCurrent =
      money.currentAmountMinor !== undefined
        ? money.currentAmountMinor
        : existing.currentAmountMinor;

    if (nextTarget != null && nextCurrent != null && nextTarget.gt(0)) {
      data.progressPercent = progressPercentFromAmounts(
        nextCurrent,
        nextTarget,
      );
    } else if (dto.progressPercent !== undefined) {
      data.progressPercent = GoalBusinessValidator.assertProgressPercent(
        dto.progressPercent,
      );
    }

    const goal = await this.prisma.goal.update({
      where: { id },
      data,
      include: { milestones: { orderBy: { order: 'asc' } } },
    });

    return this.mapGoal(goal);
  }

  async remove(userId: string, id: string): Promise<void> {
    await this.findOwnedGoal(userId, id, false);
    await this.prisma.goal.delete({ where: { id } });
  }

  async archive(userId: string, id: string): Promise<GoalResponseDto> {
    await this.findOwnedGoal(userId, id, false);
    const goal = await this.prisma.goal.update({
      where: { id },
      data: {
        status: GoalStatus.archived,
        archivedAt: new Date(),
      },
      include: { milestones: { orderBy: { order: 'asc' } } },
    });
    return this.mapGoal(goal);
  }

  async recordProgress(
    userId: string,
    id: string,
    dto: RecordProgressDto,
  ): Promise<GoalResponseDto> {
    const existing = await this.findOwnedGoal(userId, id, false);

    if (
      dto.progressPercent === undefined &&
      dto.currentAmountMinor === undefined
    ) {
      throw new BadRequestException({
        code: ErrorCodes.VALIDATION_ERROR,
        message: 'Provide progressPercent and/or currentAmountMinor',
        details: {},
      });
    }

    let newAmount: Prisma.Decimal | null = existing.currentAmountMinor;
    if (dto.currentAmountMinor !== undefined) {
      newAmount = parseOptionalMoneyMinorString(dto.currentAmountMinor, {
        field: 'currentAmountMinor',
        code: ErrorCodes.GOAL_TARGET_AMOUNT_INVALID,
      })!;
      if (
        existing.targetAmountMinor != null &&
        newAmount.gt(existing.targetAmountMinor)
      ) {
        throw new BadRequestException({
          code: ErrorCodes.GOAL_CURRENT_AMOUNT_EXCEEDS_TARGET,
          message: 'currentAmountMinor may not exceed targetAmountMinor',
          details: {
            currentAmountMinor: moneyMinorToApiString(newAmount),
            targetAmountMinor: moneyMinorToApiString(
              existing.targetAmountMinor,
            ),
          },
        });
      }
    }

    let newPercent =
      dto.progressPercent !== undefined
        ? GoalBusinessValidator.assertProgressPercent(dto.progressPercent)!
        : existing.progressPercent;

    if (
      dto.progressPercent === undefined &&
      newAmount != null &&
      existing.targetAmountMinor != null &&
      existing.targetAmountMinor.gt(0)
    ) {
      newPercent = progressPercentFromAmounts(
        newAmount,
        existing.targetAmountMinor,
      );
    }

    await this.prisma.$transaction(async (tx: Prisma.TransactionClient) => {
      await tx.goalProgressEntry.create({
        data: {
          goalId: id,
          previousProgressPercent: existing.progressPercent,
          newProgressPercent: newPercent,
          previousAmountMinor: existing.currentAmountMinor,
          newAmountMinor: newAmount,
          note: dto.note?.trim() ?? null,
        },
      });

      await tx.goal.update({
        where: { id },
        data: {
          progressPercent: newPercent,
          currentAmountMinor: newAmount,
        },
      });
    });

    return this.getById(userId, id, true);
  }

  async addMilestone(
    userId: string,
    goalId: string,
    dto: CreateMilestoneDto,
  ): Promise<MilestoneCreateResponseDto> {
    await this.findOwnedGoal(userId, goalId, false);

    const title = dto.title?.trim();
    if (!title) {
      throw new BadRequestException({
        code: ErrorCodes.GOAL_MILESTONE_INVALID,
        message: 'Milestone title is required',
        details: {},
      });
    }

    let order = dto.order;
    if (order === undefined) {
      const agg = await this.prisma.goalMilestone.aggregate({
        where: { goalId },
        _max: { order: true },
      });
      order = (agg._max.order ?? -1) + 1;
    }

    const created = await this.prisma.goalMilestone.create({
      data: {
        goalId,
        title,
        description: dto.description?.trim() ?? null,
        targetDate: dto.targetDate ? new Date(dto.targetDate) : null,
        order,
      },
    });

    const goal = await this.getById(userId, goalId, false);
    return {
      goal,
      createdMilestone: toMilestoneDto(created),
    };
  }

  async updateMilestone(
    userId: string,
    goalId: string,
    milestoneId: string,
    dto: UpdateMilestoneDto,
  ): Promise<GoalResponseDto> {
    await this.findOwnedMilestone(userId, goalId, milestoneId);

    const data: Prisma.GoalMilestoneUpdateInput = {};
    if (dto.title !== undefined) {
      const title = dto.title.trim();
      if (!title) {
        throw new BadRequestException({
          code: ErrorCodes.GOAL_MILESTONE_INVALID,
          message: 'Milestone title is required',
          details: {},
        });
      }
      data.title = title;
    }
    if (dto.description !== undefined) {
      data.description =
        dto.description === null ? null : dto.description.trim();
    }
    if (dto.targetDate !== undefined) {
      data.targetDate =
        dto.targetDate === null ? null : new Date(dto.targetDate);
    }
    if (dto.order !== undefined) data.order = dto.order;

    await this.prisma.goalMilestone.update({
      where: { id: milestoneId },
      data,
    });

    return this.getById(userId, goalId, false);
  }

  async deleteMilestone(
    userId: string,
    goalId: string,
    milestoneId: string,
  ): Promise<GoalResponseDto> {
    await this.findOwnedMilestone(userId, goalId, milestoneId);
    await this.prisma.goalMilestone.delete({ where: { id: milestoneId } });
    return this.getById(userId, goalId, false);
  }

  async completeMilestone(
    userId: string,
    goalId: string,
    milestoneId: string,
  ): Promise<GoalResponseDto> {
    await this.findOwnedMilestone(userId, goalId, milestoneId);
    await this.prisma.goalMilestone.update({
      where: { id: milestoneId },
      data: {
        isCompleted: true,
        completedAt: new Date(),
      },
    });
    return this.getById(userId, goalId, false);
  }

  async reopenMilestone(
    userId: string,
    goalId: string,
    milestoneId: string,
  ): Promise<GoalResponseDto> {
    await this.findOwnedMilestone(userId, goalId, milestoneId);
    await this.prisma.goalMilestone.update({
      where: { id: milestoneId },
      data: {
        isCompleted: false,
        completedAt: null,
      },
    });
    return this.getById(userId, goalId, false);
  }

  /** Exposed for unit tests / today summary */
  computeForecast(
    goal: Pick<
      Goal,
      'status' | 'deadline' | 'targetAmountMinor' | 'currentAmountMinor'
    >,
  ) {
    return this.forecastService.forecast(goal);
  }

  private normalizeInitialMilestones(
    milestones: CreateGoalDto['milestones'],
  ): Array<{
    title: string;
    description?: string | null;
    targetDate?: string;
    order: number;
  }> {
    if (!milestones || milestones.length === 0) return [];

    const normalized = milestones.map((m, index) => {
      if (!m || typeof m !== 'object') {
        throw new BadRequestException({
          code: ErrorCodes.GOAL_MILESTONE_INVALID,
          message: 'Empty milestone objects are rejected',
          details: { index },
        });
      }
      const title = m.title?.trim() ?? '';
      if (!title) {
        throw new BadRequestException({
          code: ErrorCodes.GOAL_MILESTONE_INVALID,
          message: 'Milestone title is required',
          details: { index },
        });
      }
      return {
        title,
        description: m.description?.trim() ?? null,
        targetDate: m.targetDate,
        order: m.order ?? index,
      };
    });

    // Normalize duplicate orders deterministically by stable index sort then reindex.
    normalized.sort((a, b) => a.order - b.order);
    return normalized.map((m, index) => ({ ...m, order: index }));
  }

  private mapGoal(
    goal: GoalWithRelations,
    includeProgress = false,
  ): GoalResponseDto {
    const forecast = this.forecastService.forecast(goal);
    return toGoalDto(goal, forecast, includeProgress);
  }

  private async findOwnedGoal(
    userId: string,
    id: string,
    includeProgress: boolean,
  ): Promise<GoalWithRelations> {
    const goal = await this.prisma.goal.findFirst({
      where: { id, userId },
      include: {
        milestones: { orderBy: { order: 'asc' } },
        progressEntries: includeProgress
          ? { orderBy: { createdAt: 'desc' } }
          : false,
      },
    });

    if (!goal) {
      const exists = await this.prisma.goal.findUnique({ where: { id } });
      if (exists && exists.userId !== userId) {
        throw new ForbiddenException({
          code: ErrorCodes.FORBIDDEN,
          message: 'You do not have access to this goal',
          details: {},
        });
      }
      throw new NotFoundException({
        code: ErrorCodes.NOT_FOUND,
        message: 'Goal not found',
        details: { id },
      });
    }

    return goal as GoalWithRelations;
  }

  private async findOwnedMilestone(
    userId: string,
    goalId: string,
    milestoneId: string,
  ): Promise<GoalMilestone> {
    await this.findOwnedGoal(userId, goalId, false);
    const milestone = await this.prisma.goalMilestone.findFirst({
      where: { id: milestoneId, goalId },
    });
    if (!milestone) {
      throw new NotFoundException({
        code: ErrorCodes.NOT_FOUND,
        message: 'Milestone not found',
        details: { milestoneId, goalId },
      });
    }
    return milestone;
  }
}
