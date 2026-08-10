import '../entities/health_metric_type.dart';
import '../entities/health_workout.dart';
import '../entities/normalized_health_sample.dart';

/// Formats user-facing Health source attribution without leaking opaque IDs.
///
/// Never shows [NormalizedHealthSample.sourceDeviceId] /
/// [HealthWorkout.sourceDeviceId]. Only mentions "Apple Watch" (or similar)
/// when device model / source app name clearly indicates a watch.
class SourceAttributionFormatter {
  const SourceAttributionFormatter();

  /// Platform store label: "Apple Health" / "Health Connect" / "Demo data".
  String platformLabel(HealthSampleSource source) => source.label;

  /// Full attribution line for a sample.
  String forSample(NormalizedHealthSample sample) {
    return _compose(
      source: sample.source,
      applicationName: sample.sourceApplicationName,
      deviceModel: sample.sourceDeviceModel,
    );
  }

  /// Full attribution line for a workout.
  String forWorkout(HealthWorkout workout) {
    return _compose(
      source: workout.source,
      applicationName: workout.sourceApplicationName,
      deviceModel: workout.sourceDeviceModel,
    );
  }

  String _compose({
    required HealthSampleSource source,
    String? applicationName,
    String? deviceModel,
  }) {
    final parts = <String>[platformLabel(source)];

    final app = _clean(applicationName);
    if (app != null && !_isRedundantPlatformName(app, source)) {
      parts.add(app);
    }

    final device = _clean(deviceModel);
    if (device != null && _looksLikeWatch(device, app)) {
      parts.add(device);
    } else if (device != null &&
        !_looksLikeWatch(device, app) &&
        !_isGenericPhoneModel(device) &&
        app == null) {
      // Show non-watch device model only when no app name and it isn't a
      // bare phone model — still never invent "Apple Watch".
      parts.add(device);
    }

    return parts.join(' · ');
  }

  static String? _clean(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static bool _isRedundantPlatformName(String name, HealthSampleSource source) {
    final lower = name.toLowerCase();
    return switch (source) {
      HealthSampleSource.appleHealth =>
        lower == 'apple health' || lower == 'health',
      HealthSampleSource.googleHealthConnect =>
        lower == 'health connect' || lower == 'google health connect',
      HealthSampleSource.fake => lower == 'demo data' || lower == 'fake',
    };
  }

  /// Only treat as watch when model or app name clearly indicates one.
  static bool _looksLikeWatch(String? deviceModel, String? applicationName) {
    final haystack = '${deviceModel ?? ''} ${applicationName ?? ''}'
        .toLowerCase();
    return haystack.contains('watch') ||
        haystack.contains('galaxy watch') ||
        haystack.contains('wear os');
  }

  static bool _isGenericPhoneModel(String model) {
    final lower = model.toLowerCase();
    return lower.contains('iphone') ||
        lower.contains('pixel') ||
        lower.contains('galaxy s') ||
        lower == 'iPhone'.toLowerCase();
  }
}
