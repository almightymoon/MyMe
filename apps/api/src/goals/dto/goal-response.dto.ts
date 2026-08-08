import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  Goal,
  GoalCategory,
  GoalMilestone,
  GoalPriority,
  GoalProgressEntry,
  GoalStatus,
} from '@prisma/client';
import {
  ForecastStatus,
  GoalForecast,
} from '../forecast/goal-forecast.service';

export class MilestoneResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  goalId!: string;

  @ApiProperty()
  title!: string;

  @ApiPropertyOptional({ nullable: true })
  description!: string | null;

  @ApiPropertyOptional({ nullable: true })
  targetDate!: string | null;

  @ApiProperty()
  isCompleted!: boolean;

  @ApiPropertyOptional({ nullable: true })
  completedAt!: string | null;

  @ApiProperty()
  order!: number;

  @ApiProperty()
  createdAt!: string;

  @ApiProperty()
  updatedAt!: string;
}

export class ProgressEntryResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  goalId!: string;

  @ApiProperty()
  previousProgressPercent!: number;

  @ApiProperty()
  newProgressPercent!: number;

  @ApiPropertyOptional({ nullable: true })
  previousAmountMinor!: number | null;

  @ApiPropertyOptional({ nullable: true })
  newAmountMinor!: number | null;

  @ApiPropertyOptional({ nullable: true })
  note!: string | null;

  @ApiProperty()
  createdAt!: string;
}

export class ForecastResponseDto implements GoalForecast {
  @ApiProperty({ enum: ForecastStatus })
  status!: ForecastStatus;

  @ApiProperty({ example: '2026-08-08' })
  asOf!: string;

  @ApiPropertyOptional()
  remainingAmountMinor?: number;

  @ApiPropertyOptional()
  daysRemaining?: number;

  @ApiPropertyOptional()
  estimatedMonthsRemaining?: number;

  @ApiPropertyOptional()
  requiredMonthlyContributionMinor?: number;

  @ApiPropertyOptional()
  requiredWeeklyContributionMinor?: number;

  @ApiPropertyOptional()
  projectedCompletionDate?: string;

  @ApiProperty()
  message!: string;
}

export class GoalResponseDto {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  userId!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  description!: string;

  @ApiProperty({ enum: GoalCategory })
  category!: GoalCategory;

  @ApiPropertyOptional({ nullable: true })
  customCategoryName!: string | null;

  @ApiProperty({ enum: GoalPriority })
  priority!: GoalPriority;

  @ApiProperty({ enum: GoalStatus })
  status!: GoalStatus;

  @ApiPropertyOptional({ nullable: true })
  targetAmountMinor!: number | null;

  @ApiPropertyOptional({ nullable: true })
  currentAmountMinor!: number | null;

  @ApiPropertyOptional({ nullable: true })
  currencyCode!: string | null;

  @ApiProperty()
  deadline!: string;

  @ApiProperty()
  progressPercent!: number;

  @ApiProperty()
  notes!: string;

  @ApiPropertyOptional({ nullable: true })
  archivedAt!: string | null;

  @ApiProperty()
  createdAt!: string;

  @ApiProperty()
  updatedAt!: string;

  @ApiProperty({ type: [MilestoneResponseDto] })
  milestones!: MilestoneResponseDto[];

  @ApiPropertyOptional({ type: [ProgressEntryResponseDto] })
  progressEntries?: ProgressEntryResponseDto[];

  @ApiProperty({ type: ForecastResponseDto })
  forecast!: ForecastResponseDto;
}

export type GoalWithRelations = Goal & {
  milestones: GoalMilestone[];
  progressEntries?: GoalProgressEntry[];
};

export function toMilestoneDto(m: GoalMilestone): MilestoneResponseDto {
  return {
    id: m.id,
    goalId: m.goalId,
    title: m.title,
    description: m.description,
    targetDate: m.targetDate?.toISOString() ?? null,
    isCompleted: m.isCompleted,
    completedAt: m.completedAt?.toISOString() ?? null,
    order: m.order,
    createdAt: m.createdAt.toISOString(),
    updatedAt: m.updatedAt.toISOString(),
  };
}

export function toProgressDto(e: GoalProgressEntry): ProgressEntryResponseDto {
  return {
    id: e.id,
    goalId: e.goalId,
    previousProgressPercent: e.previousProgressPercent,
    newProgressPercent: e.newProgressPercent,
    previousAmountMinor: e.previousAmountMinor,
    newAmountMinor: e.newAmountMinor,
    note: e.note,
    createdAt: e.createdAt.toISOString(),
  };
}

export function toGoalDto(
  goal: GoalWithRelations,
  forecast: GoalForecast,
  includeProgress = false,
): GoalResponseDto {
  return {
    id: goal.id,
    userId: goal.userId,
    name: goal.name,
    description: goal.description,
    category: goal.category,
    customCategoryName: goal.customCategoryName,
    priority: goal.priority,
    status: goal.status,
    targetAmountMinor: goal.targetAmountMinor,
    currentAmountMinor: goal.currentAmountMinor,
    currencyCode: goal.currencyCode,
    deadline: goal.deadline.toISOString(),
    progressPercent: goal.progressPercent,
    notes: goal.notes,
    archivedAt: goal.archivedAt?.toISOString() ?? null,
    createdAt: goal.createdAt.toISOString(),
    updatedAt: goal.updatedAt.toISOString(),
    milestones: [...goal.milestones]
      .sort((a, b) => a.order - b.order)
      .map(toMilestoneDto),
    progressEntries: includeProgress
      ? (goal.progressEntries ?? []).map(toProgressDto)
      : undefined,
    forecast,
  };
}
