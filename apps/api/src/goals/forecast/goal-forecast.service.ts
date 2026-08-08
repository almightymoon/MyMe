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
  targetAmountMinor?: number | null;
  currentAmountMinor?: number | null;
};

export type GoalForecast = {
  status: ForecastStatus;
  asOf: string;
  remainingAmountMinor?: number;
  daysRemaining?: number;
  estimatedMonthsRemaining?: number;
  requiredMonthlyContributionMinor?: number;
  requiredWeeklyContributionMinor?: number;
  projectedCompletionDate?: string;
  message: string;
};

/**
 * Deterministic goal forecasting — must stay aligned with Flutter
 * `GoalForecastService` (apps/mobile) and docs/product/goals-api-contract.md.
 *
 * Formula:
 *   remaining = max(0, targetAmountMinor - max(0, currentAmountMinor))
 *   daysRemaining = deadlineDate - asOfDate (date-only)
 *   effectiveDays = daysRemaining == 0 ? 1 : daysRemaining
 *   monthsRemaining = max(1, ceil(effectiveDays / 30.4375))
 *   requiredMonthlyContribution = ceil(remaining / monthsRemaining)
 *   requiredWeeklyContribution = ceil(remaining / max(1, ceil(effectiveDays / 7)))
 */
export class GoalForecastService {
  static readonly AVERAGE_DAYS_PER_MONTH = 30.4375;

  forecast(
    goal: GoalForecastInput,
    options?: {
      asOf?: Date;
      knownMonthlyContributionMinor?: number;
    },
  ): GoalForecast {
    const now = dateOnly(options?.asOf ?? new Date());
    const deadline = dateOnly(goal.deadline);
    const asOfIso = toIsoDate(now);

    if (goal.status === 'completed') {
      return {
        status: ForecastStatus.completed,
        asOf: asOfIso,
        remainingAmountMinor: 0,
        daysRemaining: diffDays(deadline, now),
        message: 'Goal is marked completed.',
      };
    }

    const target = goal.targetAmountMinor;
    const currentRaw = goal.currentAmountMinor ?? 0;

    if (target == null || target <= 0) {
      const days = diffDays(deadline, now);
      return {
        status:
          days < 0 ? ForecastStatus.overdue : ForecastStatus.insufficientData,
        asOf: asOfIso,
        daysRemaining: days,
        message:
          target == null
            ? 'No target amount — forecast unavailable.'
            : 'Target amount must be positive.',
      };
    }

    const current = currentRaw < 0 ? 0 : currentRaw;
    const remaining = Math.max(0, Math.min(target, target - current));

    if (remaining === 0) {
      return {
        status: ForecastStatus.completed,
        asOf: asOfIso,
        remainingAmountMinor: 0,
        daysRemaining: diffDays(deadline, now),
        estimatedMonthsRemaining: 0,
        requiredMonthlyContributionMinor: 0,
        requiredWeeklyContributionMinor: 0,
        message: 'Target amount already reached.',
      };
    }

    const daysRemaining = diffDays(deadline, now);

    if (daysRemaining < 0) {
      return {
        status: ForecastStatus.overdue,
        asOf: asOfIso,
        remainingAmountMinor: remaining,
        daysRemaining,
        estimatedMonthsRemaining: 0,
        requiredMonthlyContributionMinor: remaining,
        requiredWeeklyContributionMinor: remaining,
        message: 'Deadline has passed with amount still remaining.',
      };
    }

    const effectiveDays = daysRemaining === 0 ? 1 : daysRemaining;
    const monthsRemaining = ceilDivDouble(
      effectiveDays,
      GoalForecastService.AVERAGE_DAYS_PER_MONTH,
    );
    const weeksRemaining = ceilDiv(effectiveDays, 7);
    const requiredMonthly = ceilDiv(remaining, monthsRemaining);
    const requiredWeekly = ceilDiv(remaining, weeksRemaining);

    let projected: Date | undefined;
    const known = options?.knownMonthlyContributionMinor;
    if (known != null && known > 0) {
      const monthsNeeded = ceilDiv(remaining, known);
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
    } else if (daysRemaining <= 14 && remaining > target / 2) {
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
      remainingAmountMinor: remaining,
      daysRemaining,
      estimatedMonthsRemaining: monthsRemaining,
      requiredMonthlyContributionMinor: requiredMonthly,
      requiredWeeklyContributionMinor: requiredWeekly,
      projectedCompletionDate: projected
        ? toIsoDate(dateOnly(projected))
        : undefined,
      message,
    };
  }
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

function ceilDiv(numerator: number, denominator: number): number {
  if (denominator <= 0) return numerator;
  const result = Math.floor((numerator + denominator - 1) / denominator);
  return Math.min(Math.max(result, 1), numerator);
}

function ceilDivDouble(numerator: number, denominator: number): number {
  if (denominator <= 0) return numerator;
  const ceiled = Math.ceil(numerator / denominator);
  return ceiled < 1 ? 1 : ceiled;
}
