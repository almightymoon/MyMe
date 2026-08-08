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
  toGoalDto,
} from './dto/goal-response.dto';
import { GoalForecastService } from './forecast/goal-forecast.service';

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
    this.assertCustomCategory(dto.category, dto.customCategoryName);

    const goal = await this.prisma.goal.create({
      data: {
        userId,
        name: dto.name.trim(),
        description: dto.description?.trim() ?? '',
        category: dto.category,
        customCategoryName: dto.customCategoryName?.trim() ?? null,
        priority: dto.priority ?? 'medium',
        status: dto.status ?? 'active',
        targetAmountMinor: dto.targetAmountMinor,
        currentAmountMinor: dto.currentAmountMinor ?? 0,
        currencyCode: dto.currencyCode?.toUpperCase() ?? null,
        deadline: new Date(dto.deadline),
        progressPercent: dto.progressPercent ?? 0,
        notes: dto.notes?.trim() ?? '',
      },
      include: { milestones: true },
    });

    return this.mapGoal(goal);
  }

  async update(
    userId: string,
    id: string,
    dto: UpdateGoalDto,
  ): Promise<GoalResponseDto> {
    await this.findOwnedGoal(userId, id, false);
    if (dto.category !== undefined || dto.customCategoryName !== undefined) {
      const existing = await this.prisma.goal.findFirst({
        where: { id, userId },
      });
      const category = dto.category ?? existing!.category;
      const custom =
        dto.customCategoryName !== undefined
          ? dto.customCategoryName
          : existing!.customCategoryName;
      this.assertCustomCategory(category, custom);
    }

    const data: Prisma.GoalUpdateInput = {};
    if (dto.name !== undefined) data.name = dto.name.trim();
    if (dto.description !== undefined)
      data.description = dto.description.trim();
    if (dto.category !== undefined) data.category = dto.category;
    if (dto.customCategoryName !== undefined) {
      data.customCategoryName =
        dto.customCategoryName === null ? null : dto.customCategoryName.trim();
    }
    if (dto.priority !== undefined) data.priority = dto.priority;
    if (dto.status !== undefined) {
      data.status = dto.status;
      data.archivedAt = dto.status === GoalStatus.archived ? new Date() : null;
    }
    if (dto.targetAmountMinor !== undefined) {
      data.targetAmountMinor = dto.targetAmountMinor;
    }
    if (dto.currentAmountMinor !== undefined) {
      data.currentAmountMinor = dto.currentAmountMinor;
    }
    if (dto.currencyCode !== undefined) {
      data.currencyCode = dto.currencyCode
        ? dto.currencyCode.toUpperCase()
        : null;
    }
    if (dto.deadline !== undefined) data.deadline = new Date(dto.deadline);
    if (dto.progressPercent !== undefined) {
      data.progressPercent = dto.progressPercent;
    }
    if (dto.notes !== undefined) data.notes = dto.notes.trim();

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

    const newAmount =
      dto.currentAmountMinor !== undefined
        ? dto.currentAmountMinor
        : existing.currentAmountMinor;
    let newPercent =
      dto.progressPercent !== undefined
        ? dto.progressPercent
        : existing.progressPercent;

    if (
      dto.progressPercent === undefined &&
      dto.currentAmountMinor !== undefined &&
      existing.targetAmountMinor != null &&
      existing.targetAmountMinor > 0
    ) {
      newPercent = Math.min(
        100,
        Math.max(
          0,
          (dto.currentAmountMinor / existing.targetAmountMinor) * 100,
        ),
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
  ): Promise<GoalResponseDto> {
    await this.findOwnedGoal(userId, goalId, false);

    let order = dto.order;
    if (order === undefined) {
      const agg = await this.prisma.goalMilestone.aggregate({
        where: { goalId },
        _max: { order: true },
      });
      order = (agg._max.order ?? -1) + 1;
    }

    await this.prisma.goalMilestone.create({
      data: {
        goalId,
        title: dto.title.trim(),
        description: dto.description?.trim() ?? null,
        targetDate: dto.targetDate ? new Date(dto.targetDate) : null,
        order,
      },
    });

    return this.getById(userId, goalId, false);
  }

  async updateMilestone(
    userId: string,
    goalId: string,
    milestoneId: string,
    dto: UpdateMilestoneDto,
  ): Promise<GoalResponseDto> {
    await this.findOwnedMilestone(userId, goalId, milestoneId);

    const data: Prisma.GoalMilestoneUpdateInput = {};
    if (dto.title !== undefined) data.title = dto.title.trim();
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
      // Distinguish missing vs other-user for security: always 404
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

  private assertCustomCategory(
    category: string,
    customCategoryName?: string | null,
  ): void {
    if (category === 'custom' && !customCategoryName?.trim()) {
      throw new BadRequestException({
        code: ErrorCodes.VALIDATION_ERROR,
        message: 'customCategoryName is required when category is custom',
        details: {},
      });
    }
  }
}
