import '../entities/goal.dart';
import '../entities/goal_enums.dart';
import '../entities/goal_forecast.dart';
import '../value_objects/money_minor.dart';

/// Pure, deterministic forecasting for goals.
///
/// ## Financial formula
///
/// ```
/// remaining = max(0, targetAmountMinor - currentAmountMinor)
/// daysRemaining = calendar days from asOf (date-only) to deadline (date-only)
/// monthsRemaining = max(1, ceil(daysRemaining / 30.4375))  // when daysRemaining > 0
/// requiredMonthlyContribution = ceil(remaining / monthsRemaining)
/// requiredWeeklyContribution = ceil(remaining / max(1, ceil(daysRemaining / 7)))
/// ```
///
/// All monetary math above is performed on [BigInt] minor-unit values
/// (never `double`) to stay precision-safe for arbitrarily large amounts.
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
    MoneyMinor? knownMonthlyContributionMinor,
  }) {
    final now = _dateOnly(asOf ?? DateTime.now());
    final deadline = _dateOnly(goal.deadline);

    if (goal.status == GoalStatus.completed) {
      return GoalForecast(
        status: GoalForecastStatus.completed,
        asOf: now,
        remainingAmountMinor: MoneyMinor.zero,
        daysRemaining: deadline.difference(now).inDays,
        message: 'Goal is marked completed.',
      );
    }

    final target = goal.targetAmountMinor;
    final current = goal.currentAmountMinor ?? MoneyMinor.zero;

    if (target == null || !target.isPositive) {
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

    // MoneyMinor is always non-negative, so remaining is simply
    // max(0, target - current) computed directly on BigInt values.
    final remainingValue = current.value >= target.value
        ? BigInt.zero
        : target.value - current.value;
    final remaining = MoneyMinor.fromBigInt(remainingValue);

    if (remaining.isZero) {
      return GoalForecast(
        status: GoalForecastStatus.completed,
        asOf: now,
        remainingAmountMinor: MoneyMinor.zero,
        daysRemaining: deadline.difference(now).inDays,
        estimatedMonthsRemaining: 0,
        requiredMonthlyContributionMinor: MoneyMinor.zero,
        requiredWeeklyContributionMinor: MoneyMinor.zero,
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
    final requiredMonthly = MoneyMinor.fromBigInt(
      _ceilDivBig(remaining.value, BigInt.from(monthsRemaining)),
    );
    final requiredWeekly = MoneyMinor.fromBigInt(
      _ceilDivBig(remaining.value, BigInt.from(weeksRemaining)),
    );

    DateTime? projected;
    if (knownMonthlyContributionMinor != null &&
        knownMonthlyContributionMinor.isPositive) {
      final monthsNeeded = _ceilDivBig(
        remaining.value,
        knownMonthlyContributionMinor.value,
      );
      final projectedDays = (monthsNeeded.toInt() * averageDaysPerMonth).ceil();
      projected = now.add(Duration(days: projectedDays));
    }

    var status = GoalForecastStatus.onTrack;
    var message = 'On track if contribution pace is maintained.';

    if (projected != null && _dateOnly(projected).isAfter(deadline)) {
      status = GoalForecastStatus.atRisk;
      message = 'Current contribution rate finishes after the deadline.';
    } else if (daysRemaining <= 14 &&
        remaining.value * BigInt.two > target.value) {
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

  /// Ceiling division on [BigInt] minor-unit amounts, clamped to
  /// `[1, numerator]` (mirrors [_ceilDiv]'s semantics: a required
  /// contribution is always at least 1 minor unit and never exceeds the
  /// remaining amount itself).
  static BigInt _ceilDivBig(BigInt numerator, BigInt denominator) {
    if (denominator <= BigInt.zero) return numerator;
    var result = (numerator + denominator - BigInt.one) ~/ denominator;
    if (result < BigInt.one) result = BigInt.one;
    if (result > numerator) result = numerator;
    return result;
  }
}
