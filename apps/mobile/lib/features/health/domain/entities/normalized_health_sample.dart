import 'health_metric_type.dart';

/// One platform Health reading, normalized to MeMy's own units/enums.
///
/// This is an in-memory boundary type only — MeMy never persists raw sample
/// values indefinitely (see `HealthRepository` docs). It is safe to hold a
/// short-lived list of these for one aggregation pass, but do not store them
/// in SharedPreferences/DB.
class NormalizedHealthSample {
  const NormalizedHealthSample({
    required this.metricType,
    required this.value,
    required this.unit,
    required this.startAt,
    required this.endAt,
    required this.source,
    this.recordingMethod = HealthRecordingMethod.unknown,
    this.providerRecordId,
    this.sourceApplicationId,
    this.sourceApplicationName,
    this.sourceDeviceId,
    this.sourceDeviceModel,
    this.dataOriginCategory,
    this.fetchedAt,
  });

  final HealthMetricType metricType;
  final double value;
  final HealthUnit unit;

  /// UTC instants bounding this reading. Point-in-time samples (e.g. a heart
  /// rate reading) have `startAt == endAt`.
  final DateTime startAt;
  final DateTime endAt;
  final HealthSampleSource source;
  final HealthRecordingMethod recordingMethod;

  /// Stable platform record id (HealthKit/Health Connect UUID) when known.
  /// Used only for de-duplication within an aggregation pass — never shown
  /// in UI or logged in clear text.
  final String? providerRecordId;

  /// Source app bundle / package id when the platform provides one.
  final String? sourceApplicationId;

  /// Human-readable source app name when available.
  final String? sourceApplicationName;

  /// Opaque device id from the platform — never display in UI.
  final String? sourceDeviceId;

  /// Device model string when available (may indicate Watch vs phone).
  final String? sourceDeviceModel;

  /// Coarse origin category string when the platform exposes one.
  final String? dataOriginCategory;

  /// When MeMy fetched this sample from the gateway (not sample time).
  final DateTime? fetchedAt;

  /// True when [providerRecordId] is a non-empty platform id suitable for
  /// stable de-duplication across overlapping raw reads.
  bool get hasStableProviderRecordId =>
      providerRecordId != null && providerRecordId!.isNotEmpty;

  @override
  String toString() =>
      'NormalizedHealthSample(${metricType.name}, unit: ${unit.name}, '
      'source: ${source.name})';
}
