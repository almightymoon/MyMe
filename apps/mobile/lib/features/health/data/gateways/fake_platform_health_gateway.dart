import '../../../../core/integrations/domain/integration_availability.dart';
import '../../../../core/integrations/domain/integration_error.dart';
import '../../../../core/integrations/domain/integration_provider.dart';
import '../../domain/entities/health_metric_type.dart';
import '../../domain/entities/health_workout.dart';
import '../../domain/entities/normalized_health_sample.dart';
import '../../domain/gateways/platform_health_gateway.dart';

/// Fully in-memory, controllable [PlatformHealthGateway].
///
/// Backs `HEALTH_DATA_SOURCE=fake` (default, CI-safe) and is the gateway
/// used by every health test — no real device/plugin involved. Tests seed
/// samples/workouts directly and control availability/permission state to
/// exercise disconnected, partial-permission, and error states.
class FakePlatformHealthGateway implements PlatformHealthGateway {
  FakePlatformHealthGateway({
    this._availability = IntegrationAvailability.available,
    Set<HealthMetricGroup> grantedGroups = const {},
  }) : _grantedGroups = {...grantedGroups};

  IntegrationAvailability _availability;
  final Set<HealthMetricGroup> _grantedGroups;

  /// Groups the next [requestPermissions] call should grant. Defaults to
  /// "grant everything requested" — set to a subset to simulate a partial
  /// grant, or to `{}` to simulate the user declining everything.
  Set<HealthMetricGroup>? nextRequestGrantsOverride;

  final List<NormalizedHealthSample> _samples = [];
  final List<HealthWorkout> _workouts = [];

  void seedSample(NormalizedHealthSample sample) {
    _samples.add(sample);
  }

  void seedWorkout(HealthWorkout workout) {
    _workouts.add(workout);
  }

  void clearSeeded() {
    _samples.clear();
    _workouts.clear();
  }

  void setAvailability(IntegrationAvailability availability) {
    _availability = availability;
  }

  void grantGroups(Set<HealthMetricGroup> groups) {
    _grantedGroups.addAll(groups);
  }

  void revokeGroups(Set<HealthMetricGroup> groups) {
    _grantedGroups.removeAll(groups);
  }

  Set<HealthMetricGroup> get grantedGroups => Set.unmodifiable(_grantedGroups);

  @override
  Future<IntegrationAvailability> checkAvailability() async => _availability;

  @override
  Future<bool?> hasPermissions(Set<HealthMetricGroup> groups) async {
    return groups.every(_grantedGroups.contains);
  }

  @override
  Future<Set<HealthMetricGroup>> requestPermissions(
    Set<HealthMetricGroup> groups,
  ) async {
    if (_availability != IntegrationAvailability.available) {
      throw IntegrationError.unavailable(IntegrationProvider.health);
    }
    final granted = nextRequestGrantsOverride ?? groups;
    final actuallyGranted = groups.intersection(granted);
    _grantedGroups.addAll(actuallyGranted);
    return actuallyGranted;
  }

  bool _hasPermissionFor(HealthMetricType type) =>
      _grantedGroups.contains(type.group);

  @override
  Future<List<NormalizedHealthSample>> readSamples({
    required Set<HealthMetricType> metricTypes,
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    return _samples
        .where(
          (s) =>
              metricTypes.contains(s.metricType) &&
              _hasPermissionFor(s.metricType) &&
              s.startAt.isBefore(endUtc) &&
              s.endAt.isAfter(startUtc),
        )
        .toList(growable: false);
  }

  @override
  Future<List<HealthWorkout>> readWorkouts({
    required DateTime startUtc,
    required DateTime endUtc,
  }) async {
    if (!_grantedGroups.contains(HealthMetricGroup.workouts)) return const [];
    return _workouts
        .where((w) => w.startAt.isBefore(endUtc) && w.endAt.isAfter(startUtc))
        .toList(growable: false);
  }
}
