import '../entities/goal.dart';
import '../entities/goal_enums.dart';
import '../entities/goal_forecast.dart';

/// Pure, deterministic forecasting for goals.
///
/// ## Financial formula
///
/// ```
/// remaining = max(0, targetAmountMinor - max(0, currentAmountMinor))
/// daysRemaining = calendar days from asOf (date-only) to deadline (date-only)
/// monthsRemaining = max(1, ceil(daysRemaining / 30.4375))  // when daysRemaining > 0
/// requiredMonthlyContribution = ceil(remaining / monthsRemaining)
/// requiredWeeklyContribution = ceil(remaining / max(1, ceil(daysRemaining / 7)))
/// ```
///
/// When an optional [knownMonthlyContributionMinor] is provided and remaining > 0:
///
/// ```
/// monthsNeeded = ceil(remaining / knownMonthlyContributionMinor)
/// projectedCompletionDate = asOf + (monthsNeeded * 30.4375 days)
/// ```
///
/// Status rules:
/// - completed: status completed, or remaining == 0 with a valid target
/// - overdue: deadline date is before asOf date and not completed
/// - atRisk: projectedCompletionDate is after deadline (when projection known),
///   or daysRemaining <= 14 with remaining > 50% of target
/// - onTrack: otherwise when amounts are present
/// - insufficientData: missing/invalid target or non-financial without amounts
class GoalForecastService {
  const GoalForecastService();

  static const double averageDaysPerMonth = 30.4375;

  GoalForecast forecast(
    Goal goal, {
    DateTime? asOf,
    int? knownMonthlyContributionMinor,
  }) {
    final now = _dateOnly(asOf ?? DateTime.now());
    final deadline = _dateOnly(goal.deadline);

    if (goal.status == GoalStatus.completed) {
      return GoalForecast(
        status: GoalForecastStatus.completed,
        asOf: now,
        remainingAmountMinor: 0,
        daysRemaining: deadline.difference(now).inDays,
        message: 'Goal is marked completed.',
      );
    }

    final target = goal.targetAmountMinor;
    final currentRaw = goal.currentAmountMinor ?? 0;

    if (target == null || target <= 0) {
      final days = deadline.difference(now).inDays;
      return GoalForecast(
        status: days < 0
            ? GoalForecastStatus.overdue
            : GoalForecastStatus.insufficientData,
        asOf: now,
        daysRemaining: days,
        message: target == null
            ? 'No target amount — forecast unavailable.'
            : 'Target amount must be positive.',
      );
    }

    final current = currentRaw < 0 ? 0 : currentRaw;
    final remaining = (target - current).clamp(0, target);

    if (remaining == 0) {
      return GoalForecast(
        status: GoalForecastStatus.completed,
        asOf: now,
        remainingAmountMinor: 0,
        daysRemaining: deadline.difference(now).inDays,
        estimatedMonthsRemaining: 0,
        requiredMonthlyContributionMinor: 0,
        requiredWeeklyContributionMinor: 0,
        message: 'Target amount already reached.',
      );
    }

    final daysRemaining = deadline.difference(now).inDays;

    if (daysRemaining < 0) {
      return GoalForecast(
        status: GoalForecastStatus.overdue,
        asOf: now,
        remainingAmountMinor: remaining,
        daysRemaining: daysRemaining,
        estimatedMonthsRemaining: 0,
        requiredMonthlyContributionMinor: remaining,
        requiredWeeklyContributionMinor: remaining,
        message: 'Deadline has passed with amount still remaining.',
      );
    }

    // Deadline today counts as 1 day of contribution runway.
    final effectiveDays = daysRemaining == 0 ? 1 : daysRemaining;
    final monthsRemaining = _ceilDivDouble(effectiveDays, averageDaysPerMonth);
    final weeksRemaining = _ceilDiv(effectiveDays, 7);
    final requiredMonthly = _ceilDiv(remaining, monthsRemaining);
    final requiredWeekly = _ceilDiv(remaining, weeksRemaining);

    DateTime? projected;
    if (knownMonthlyContributionMinor != null &&
        knownMonthlyContributionMinor > 0) {
      final monthsNeeded = _ceilDiv(remaining, knownMonthlyContributionMinor);
      final projectedDays = (monthsNeeded * averageDaysPerMonth).ceil();
      projected = now.add(Duration(days: projectedDays));
    }

    var status = GoalForecastStatus.onTrack;
    var message = 'On track if contribution pace is maintained.';

    if (projected != null && _dateOnly(projected).isAfter(deadline)) {
      status = GoalForecastStatus.atRisk;
      message = 'Current contribution rate finishes after the deadline.';
    } else if (daysRemaining <= 14 && remaining > (target / 2)) {
      status = GoalForecastStatus.atRisk;
      message = 'Less than two weeks left with more than half remaining.';
    }

    if (daysRemaining == 0) {
      message = 'Deadline is today — full remaining amount is due now.';
      status = GoalForecastStatus.atRisk;
    }

    return GoalForecast(
      status: status,
      asOf: now,
      remainingAmountMinor: remaining,
      daysRemaining: daysRemaining,
      estimatedMonthsRemaining: monthsRemaining,
      requiredMonthlyContributionMinor: requiredMonthly,
      requiredWeeklyContributionMinor: requiredWeekly,
      projectedCompletionDate: projected,
      message: message,
    );
  }

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static int _ceilDiv(int numerator, int denominator) {
    if (denominator <= 0) return numerator;
    return ((numerator + denominator - 1) ~/ denominator).clamp(1, numerator);
  }

  static int _ceilDivDouble(int numerator, double denominator) {
    if (denominator <= 0) return numerator;
    final raw = numerator / denominator;
    final ceiled = raw.ceil();
    return ceiled < 1 ? 1 : ceiled;
  }
}
