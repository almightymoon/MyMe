import { Injectable } from '@nestjs/common';
import { GoalStatus } from '@prisma/client';
import { GoalsService } from '../goals/goals.service';
import { ForecastStatus } from '../goals/forecast/goal-forecast.service';
import { TodaySummaryDto } from './dto/today-summary.dto';

const PRIORITY_RANK: Record<string, number> = {
  critical: 0,
  high: 1,
  medium: 2,
  low: 3,
};

@Injectable()
export class TodayService {
  constructor(private readonly goalsService: GoalsService) {}

  async getSummary(userId: string): Promise<TodaySummaryDto> {
    const goals = await this.goalsService.list(userId, {
      status: GoalStatus.active,
    });

    const asOf = new Date();
    const in14Days = addUtcDays(dateOnlyUtc(asOf), 14);

    const goalsDueSoon = goals.filter((g) => {
      const deadline = new Date(g.deadline);
      return deadline >= dateOnlyUtc(asOf) && deadline <= in14Days;
    });

    const goalsAtRisk = goals.filter(
      (g) =>
        g.forecast.status === ForecastStatus.atRisk ||
        g.forecast.status === ForecastStatus.overdue,
    );

    const topActiveGoals = [...goals]
      .sort((a, b) => {
        const pr =
          (PRIORITY_RANK[a.priority] ?? 9) - (PRIORITY_RANK[b.priority] ?? 9);
        if (pr !== 0) return pr;
        return new Date(a.deadline).getTime() - new Date(b.deadline).getTime();
      })
      .slice(0, 5);

    const averageGoalProgress =
      goals.length === 0
        ? 0
        : Math.round(
            (goals.reduce((sum, g) => sum + g.progressPercent, 0) /
              goals.length) *
              100,
          ) / 100;

    return {
      activeGoalCount: goals.length,
      goalsDueSoon,
      goalsAtRisk,
      topActiveGoals,
      averageGoalProgress,
    };
  }
}

function dateOnlyUtc(value: Date): Date {
  return new Date(
    Date.UTC(value.getUTCFullYear(), value.getUTCMonth(), value.getUTCDate()),
  );
}

function addUtcDays(value: Date, days: number): Date {
  const next = new Date(value.getTime());
  next.setUTCDate(next.getUTCDate() + days);
  return next;
}
