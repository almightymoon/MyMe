import { GoalForecastService, ForecastStatus } from './goal-forecast.service';

describe('GoalForecastService', () => {
  const service = new GoalForecastService();
  // Align with Flutter unit tests (calendar dates as UTC date-only)
  const asOf = new Date(Date.UTC(2026, 7, 8)); // 2026-08-08

  it('computes required monthly using documented months formula', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: new Date(Date.UTC(2026, 9, 7)), // +60 days
        targetAmountMinor: 1_000_000,
        currentAmountMinor: 0,
      },
      { asOf },
    );
    // ceil(60 / 30.4375) = 2
    expect(forecast.estimatedMonthsRemaining).toBe(2);
    expect(forecast.requiredMonthlyContributionMinor).toBe(500_000);
    expect(forecast.status).toBe(ForecastStatus.onTrack);
  });

  it('marks overdue when deadline passed with remaining', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: new Date(Date.UTC(2026, 7, 5)),
        targetAmountMinor: 100_000,
        currentAmountMinor: 10_000,
      },
      { asOf },
    );
    expect(forecast.status).toBe(ForecastStatus.overdue);
    expect(forecast.remainingAmountMinor).toBe(90_000);
  });

  it('marks completed when remaining is zero', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: new Date(Date.UTC(2026, 8, 8)),
        targetAmountMinor: 100_000,
        currentAmountMinor: 100_000,
      },
      { asOf },
    );
    expect(forecast.status).toBe(ForecastStatus.completed);
    expect(forecast.requiredMonthlyContributionMinor).toBe(0);
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
        targetAmountMinor: 10_000,
        currentAmountMinor: 0,
      },
      { asOf },
    );
    expect(forecast.daysRemaining).toBe(0);
    expect(forecast.estimatedMonthsRemaining).toBe(1);
    expect(forecast.requiredMonthlyContributionMinor).toBe(10_000);
    expect(forecast.status).toBe(ForecastStatus.atRisk);
  });

  it('marks atRisk when more than half remains with <=14 days', () => {
    const forecast = service.forecast(
      {
        status: 'active',
        deadline: new Date(Date.UTC(2026, 7, 18)),
        targetAmountMinor: 100_000,
        currentAmountMinor: 40_000,
      },
      { asOf },
    );
    expect(forecast.status).toBe(ForecastStatus.atRisk);
  });
});
