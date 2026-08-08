import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  Goal,
  GoalCategory,
  GoalMilestone,
  GoalPriority,
  GoalProgressEntry,
  GoalStatus,
  Prisma,
} from '@prisma/client';
import {
  ForecastStatus,
  GoalForecast,
} from '../forecast/goal-forecast.service';
import { moneyMinorToApiString } from '../money/money-minor';

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

  @ApiPropertyOptional({ nullable: true, type: String, example: '0' })
  previousAmountMinor!: string | null;

  @ApiPropertyOptional({ nullable: true, type: String, example: '250000000' })
  newAmountMinor!: string | null;

  @ApiPropertyOptional({ nullable: true })
  note!: string | null;

  @ApiProperty()
  createdAt!: string;
}

export class ForecastResponseDto {
  @ApiProperty({ enum: ForecastStatus })
  status!: ForecastStatus;

  @ApiProperty({ example: '2026-08-08' })
  asOf!: string;

  @ApiPropertyOptional({ type: String, example: '15000000000' })
  remainingAmountMinor?: string;

  @ApiPropertyOptional()
  daysRemaining?: number;

  @ApiPropertyOptional()
  estimatedMonthsRemaining?: number;

  @ApiPropertyOptional({ type: String, example: '123456790' })
  requiredMonthlyContributionMinor?: string;

  @ApiPropertyOptional({ type: String, example: '28767124' })
  requiredWeeklyContributionMinor?: string;

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

  @ApiPropertyOptional({
    nullable: true,
    type: String,
    example: '15000000000',
    description: 'Minor units as whole-number decimal string',
  })
  targetAmountMinor!: string | null;

  @ApiPropertyOptional({
    nullable: true,
    type: String,
    example: '250000000',
  })
  currentAmountMinor!: string | null;

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

/** Response for POST /goals/:goalId/milestones */
export class MilestoneCreateResponseDto {
  @ApiProperty({ type: GoalResponseDto })
  goal!: GoalResponseDto;

  @ApiProperty({ type: MilestoneResponseDto })
  createdMilestone!: MilestoneResponseDto;
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
    previousAmountMinor: moneyMinorToApiString(e.previousAmountMinor),
    newAmountMinor: moneyMinorToApiString(e.newAmountMinor),
    note: e.note,
    createdAt: e.createdAt.toISOString(),
  };
}

export function toForecastDto(forecast: GoalForecast): ForecastResponseDto {
  return {
    status: forecast.status,
    asOf: forecast.asOf,
    remainingAmountMinor: forecast.remainingAmountMinor,
    daysRemaining: forecast.daysRemaining,
    estimatedMonthsRemaining: forecast.estimatedMonthsRemaining,
    requiredMonthlyContributionMinor: forecast.requiredMonthlyContributionMinor,
    requiredWeeklyContributionMinor: forecast.requiredWeeklyContributionMinor,
    projectedCompletionDate: forecast.projectedCompletionDate,
    message: forecast.message,
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
    targetAmountMinor: moneyMinorToApiString(
      goal.targetAmountMinor as Prisma.Decimal | null,
    ),
    currentAmountMinor: moneyMinorToApiString(
      goal.currentAmountMinor as Prisma.Decimal | null,
    ),
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
    forecast: toForecastDto(forecast),
  };
}
