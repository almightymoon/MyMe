import { Prisma } from '@prisma/client';
import {
  ceilDivBigInt,
  moneyMinorToApiString,
  moneyMinorToBigInt,
} from '../money/money-minor';

export enum ForecastStatus {
  completed = 'completed',
  overdue = 'overdue',
  atRisk = 'atRisk',
  onTrack = 'onTrack',
  insufficientData = 'insufficientData',
}

export type GoalForecastInput = {
  status: string;
  deadline: Date;
  targetAmountMinor?: Prisma.Decimal | string | null;
  currentAmountMinor?: Prisma.Decimal | string | null;
};

export type GoalForecast = {
  status: ForecastStatus;
  asOf: string;
  /** Whole-number decimal strings — never IEEE Number. */
  remainingAmountMinor?: string;
  daysRemaining?: number;
  estimatedMonthsRemaining?: number;
  requiredMonthlyContributionMinor?: string;
  requiredWeeklyContributionMinor?: string;
  projectedCompletionDate?: string;
  message: string;
};

/**
 * Deterministic goal forecasting — aligned with Flutter `GoalForecastService`.
 *
 * Rounding: required monthly/weekly contributions use **ceiling** division
 * so the user is never told to save less than the mathematically required
 * whole minor units.
 *
 * Formula:
 *   remaining = max(0, target - max(0, current))
 *   daysRemaining = deadlineDate - asOfDate (UTC date-only)
 *   effectiveDays = daysRemaining == 0 ? 1 : daysRemaining
 *   monthsRemaining = max(1, ceil(effectiveDays / 30.4375))
 *   requiredMonthly = ceil(remaining / monthsRemaining)
 *   requiredWeekly = ceil(remaining / max(1, ceil(effectiveDays / 7)))
 */
export class GoalForecastService {
  static readonly AVERAGE_DAYS_PER_MONTH = 30.4375;

  forecast(
    goal: GoalForecastInput,
    options?: {
      asOf?: Date;
      knownMonthlyContributionMinor?: string | bigint;
    },
  ): GoalForecast {
    const now = dateOnly(options?.asOf ?? new Date());
    const deadline = dateOnly(goal.deadline);
    const asOfIso = toIsoDate(now);

    if (goal.status === 'completed') {
      return {
        status: ForecastStatus.completed,
        asOf: asOfIso,
        remainingAmountMinor: '0',
        daysRemaining: diffDays(deadline, now),
        message: 'Goal is marked completed.',
      };
    }

    const targetBi = moneyMinorToBigInt(
      goal.targetAmountMinor as Prisma.Decimal | string | null | undefined,
    );
    const currentRaw = moneyMinorToBigInt(
      goal.currentAmountMinor as Prisma.Decimal | string | null | undefined,
    );

    if (targetBi == null || targetBi <= 0n) {
      const days = diffDays(deadline, now);
      return {
        status:
          days < 0 ? ForecastStatus.overdue : ForecastStatus.insufficientData,
        asOf: asOfIso,
        daysRemaining: days,
        message:
          targetBi == null
            ? 'No target amount — forecast unavailable.'
            : 'Target amount must be positive.',
      };
    }

    const current = currentRaw == null || currentRaw < 0n ? 0n : currentRaw;
    let remaining = targetBi - current;
    if (remaining < 0n) remaining = 0n;
    if (remaining > targetBi) remaining = targetBi;

    if (remaining === 0n) {
      return {
        status: ForecastStatus.completed,
        asOf: asOfIso,
        remainingAmountMinor: '0',
        daysRemaining: diffDays(deadline, now),
        estimatedMonthsRemaining: 0,
        requiredMonthlyContributionMinor: '0',
        requiredWeeklyContributionMinor: '0',
        message: 'Target amount already reached.',
      };
    }

    const daysRemaining = diffDays(deadline, now);

    if (daysRemaining < 0) {
      return {
        status: ForecastStatus.overdue,
        asOf: asOfIso,
        remainingAmountMinor: remaining.toString(),
        daysRemaining,
        estimatedMonthsRemaining: 0,
        requiredMonthlyContributionMinor: remaining.toString(),
        requiredWeeklyContributionMinor: remaining.toString(),
        message: 'Deadline has passed with amount still remaining.',
      };
    }

    const effectiveDays = daysRemaining === 0 ? 1 : daysRemaining;
    const monthsRemaining = ceilDaysPerMonth(effectiveDays);
    const weeksRemaining = Number(ceilDivBigInt(BigInt(effectiveDays), 7n));
    const requiredMonthly = ceilDivBigInt(remaining, BigInt(monthsRemaining));
    const requiredWeekly = ceilDivBigInt(
      remaining,
      BigInt(weeksRemaining < 1 ? 1 : weeksRemaining),
    );

    let projected: Date | undefined;
    const knownRaw = options?.knownMonthlyContributionMinor;
    let known: bigint | null = null;
    if (typeof knownRaw === 'bigint') {
      known = knownRaw;
    } else if (typeof knownRaw === 'string') {
      known = moneyMinorToBigInt(knownRaw);
    }
    if (known != null && known > 0n) {
      const monthsNeeded = Number(ceilDivBigInt(remaining, known));
      const projectedDays = Math.ceil(
        monthsNeeded * GoalForecastService.AVERAGE_DAYS_PER_MONTH,
      );
      projected = addDays(now, projectedDays);
    }

    let status = ForecastStatus.onTrack;
    let message = 'On track if contribution pace is maintained.';

    if (projected != null && dateOnly(projected) > deadline) {
      status = ForecastStatus.atRisk;
      message = 'Current contribution rate finishes after the deadline.';
    } else if (daysRemaining <= 14 && remaining > targetBi / 2n) {
      status = ForecastStatus.atRisk;
      message = 'Less than two weeks left with more than half remaining.';
    }

    if (daysRemaining === 0) {
      message = 'Deadline is today — full remaining amount is due now.';
      status = ForecastStatus.atRisk;
    }

    return {
      status,
      asOf: asOfIso,
      remainingAmountMinor: remaining.toString(),
      daysRemaining,
      estimatedMonthsRemaining: monthsRemaining,
      requiredMonthlyContributionMinor: requiredMonthly.toString(),
      requiredWeeklyContributionMinor: requiredWeekly.toString(),
      projectedCompletionDate: projected
        ? toIsoDate(dateOnly(projected))
        : undefined,
      message,
    };
  }
}

function ceilDaysPerMonth(effectiveDays: number): number {
  // Month count uses AVERAGE_DAYS_PER_MONTH; result is a small integer so Number is safe.
  const ceiled = Math.ceil(
    effectiveDays / GoalForecastService.AVERAGE_DAYS_PER_MONTH,
  );
  return ceiled < 1 ? 1 : ceiled;
}

function dateOnly(value: Date): Date {
  return new Date(
    Date.UTC(value.getUTCFullYear(), value.getUTCMonth(), value.getUTCDate()),
  );
}

function toIsoDate(value: Date): string {
  return value.toISOString().slice(0, 10);
}

function diffDays(a: Date, b: Date): number {
  const ms = a.getTime() - b.getTime();
  return Math.round(ms / 86_400_000);
}

function addDays(value: Date, days: number): Date {
  const next = new Date(value.getTime());
  next.setUTCDate(next.getUTCDate() + days);
  return next;
}

/** Re-export for tests that assert string serialization helpers. */
export { moneyMinorToApiString };
