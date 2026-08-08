import { GoalForecastService, ForecastStatus } from './goal-forecast.service';
import { Prisma } from '@prisma/client';

describe('GoalForecastService', () => {
  const service = new GoalForecastService();
  const asOf = new Date(Date.UTC(2026, 7, 8)); // 2026-08-08

  it('computes required monthly using documented months formula', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: new Date(Date.UTC(2026, 9, 7)), // +60 days
        targetAmountMinor: new Prisma.Decimal(1_000_000),
        currentAmountMinor: new Prisma.Decimal(0),
      },
      { asOf },
    );
    expect(forecast.estimatedMonthsRemaining).toBe(2);
    expect(forecast.requiredMonthlyContributionMinor).toBe('500000');
    expect(forecast.status).toBe(ForecastStatus.onTrack);
  });

  it('marks overdue when deadline passed with remaining', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: new Date(Date.UTC(2026, 7, 5)),
        targetAmountMinor: new Prisma.Decimal(100_000),
        currentAmountMinor: new Prisma.Decimal(10_000),
      },
      { asOf },
    );
    expect(forecast.status).toBe(ForecastStatus.overdue);
    expect(forecast.remainingAmountMinor).toBe('90000');
  });

  it('marks completed when remaining is zero', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: new Date(Date.UTC(2026, 8, 8)),
        targetAmountMinor: new Prisma.Decimal(100_000),
        currentAmountMinor: new Prisma.Decimal(100_000),
      },
      { asOf },
    );
    expect(forecast.status).toBe(ForecastStatus.completed);
    expect(forecast.requiredMonthlyContributionMinor).toBe('0');
  });

  it('returns insufficientData without target', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: new Date(Date.UTC(2026, 8, 17)),
        targetAmountMinor: null,
        currentAmountMinor: null,
      },
      { asOf },
    );
    expect(forecast.status).toBe(ForecastStatus.insufficientData);
  });

  it('treats deadline today as atRisk with full remaining due', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: asOf,
        targetAmountMinor: new Prisma.Decimal(10_000),
        currentAmountMinor: new Prisma.Decimal(0),
      },
      { asOf },
    );
    expect(forecast.daysRemaining).toBe(0);
    expect(forecast.estimatedMonthsRemaining).toBe(1);
    expect(forecast.requiredMonthlyContributionMinor).toBe('10000');
    expect(forecast.status).toBe(ForecastStatus.atRisk);
  });

  it('marks atRisk when more than half remains with <=14 days', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: new Date(Date.UTC(2026, 7, 18)),
        targetAmountMinor: new Prisma.Decimal(100_000),
        currentAmountMinor: new Prisma.Decimal(40_000),
      },
      { asOf },
    );
    expect(forecast.status).toBe(ForecastStatus.atRisk);
  });

  it('handles PKR 150,000,000 (15_000_000_000 minor) with ceiling rounding', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: new Date(Date.UTC(2027, 7, 8)), // +365 days approx
        targetAmountMinor: '15000000000',
        currentAmountMinor: '0',
      },
      { asOf },
    );
    expect(forecast.remainingAmountMinor).toBe('15000000000');
    expect(forecast.requiredMonthlyContributionMinor).toBeDefined();
    // Ceiling: monthly * months >= remaining
    const monthly = BigInt(forecast.requiredMonthlyContributionMinor!);
    const months = BigInt(forecast.estimatedMonthsRemaining!);
    expect(monthly * months >= 15000000000n).toBe(true);
  });

  it('ceils uneven contribution division upward', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: new Date(Date.UTC(2026, 9, 7)), // 2 months
        targetAmountMinor: '1000001',
        currentAmountMinor: '0',
      },
      { asOf },
    );
    expect(forecast.estimatedMonthsRemaining).toBe(2);
    // ceil(1000001 / 2) = 500001
    expect(forecast.requiredMonthlyContributionMinor).toBe('500001');
  });
});
