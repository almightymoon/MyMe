import 'health_metric_type.dart';

/// How a daily metric total was produced from the platform Health store.
enum HealthAggregateStrategy {
  /// Platform-provided aggregate (e.g. HealthKit / Health Connect daily total).
  platformTotal,

  /// Summed from raw samples after composite-id de-duplication.
  rawDeduplicatedFallback,

  /// Platform does not expose a suitable aggregate for this metric.
  unavailable,
}

/// Result of aggregating one metric over a time window.
class HealthAggregateResult {
  const HealthAggregateResult({
    required this.metricType,
    required this.strategy,
    this.numericValue,
  });

  final HealthMetricType metricType;
  final HealthAggregateStrategy strategy;

  /// Aggregated value when [strategy] is not [HealthAggregateStrategy.unavailable].
  final double? numericValue;

  bool get hasValue =>
      numericValue != null && strategy != HealthAggregateStrategy.unavailable;

  int? get intValue => numericValue?.round();
}
