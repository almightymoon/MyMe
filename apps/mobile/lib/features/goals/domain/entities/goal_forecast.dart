/// Forecast status for financial goals.
enum GoalForecastStatus {
  onTrack,
  atRisk,
  overdue,
  completed,
  insufficientData,
}

/// Immutable forecast snapshot produced by [GoalForecastService].
class GoalForecast {
  const GoalForecast({
    required this.status,
    required this.asOf,
    this.remainingAmountMinor,
    this.daysRemaining,
    this.estimatedMonthsRemaining,
    this.requiredMonthlyContributionMinor,
    this.requiredWeeklyContributionMinor,
    this.projectedCompletionDate,
    this.message = '',
  });

  final GoalForecastStatus status;
  final DateTime asOf;
  final int? remainingAmountMinor;
  final int? daysRemaining;
  final int? estimatedMonthsRemaining;
  final int? requiredMonthlyContributionMinor;
  final int? requiredWeeklyContributionMinor;
  final DateTime? projectedCompletionDate;
  final String message;
}
