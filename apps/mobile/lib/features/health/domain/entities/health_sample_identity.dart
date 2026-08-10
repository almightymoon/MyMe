import 'health_metric_type.dart';
import 'normalized_health_sample.dart';

/// Composite identity for de-duplicating platform Health samples.
///
/// The bare [NormalizedHealthSample.providerRecordId] is not unique across
/// metric types or platforms — the same UUID may appear on steps and distance,
/// or on records merged from different stores.
class HealthSampleIdentity {
  const HealthSampleIdentity({
    required this.sourcePlatform,
    required this.metricType,
    required this.providerRecordId,
  });

  final HealthSampleSource sourcePlatform;
  final HealthMetricType metricType;
  final String providerRecordId;

  /// Stable composite key for in-memory dedupe within one aggregation pass.
  String get compositeKey =>
      '${sourcePlatform.name}|${metricType.name}|$providerRecordId';

  factory HealthSampleIdentity.fromSample(NormalizedHealthSample sample) {
    return HealthSampleIdentity(
      sourcePlatform: sample.source,
      metricType: sample.metricType,
      providerRecordId: sample.providerRecordId!,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthSampleIdentity &&
          sourcePlatform == other.sourcePlatform &&
          metricType == other.metricType &&
          providerRecordId == other.providerRecordId;

  @override
  int get hashCode => Object.hash(sourcePlatform, metricType, providerRecordId);
}
