import 'dart:async';

import '../../../../core/data/fake_repository_config.dart';
import '../../../../core/domain/clock/app_clock.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/integrations/domain/integration_availability.dart';
import '../../../../core/integrations/domain/integration_connection_status.dart';
import '../../domain/entities/daily_health_summary.dart';
import '../../domain/entities/health_connection_config.dart';
import '../../domain/entities/health_metric_type.dart';
import '../../domain/entities/health_permission_state.dart';
import '../../domain/gateways/platform_health_gateway.dart';
import '../../domain/repositories/health_repository.dart';
import '../../domain/services/health_aggregation_service.dart';
import 'health_repository_support.dart';

/// In-memory [HealthRepository] backed by a [PlatformHealthGateway] — in
/// practice a [FakePlatformHealthGateway].
///
/// Backs `HEALTH_DATA_SOURCE=fake` (default, CI-safe) and every health
/// widget/unit test. Exposes the underlying gateway so tests can seed
/// samples/workouts and control availability/permission state directly.
class FakeHealthRepository implements HealthRepository {
  FakeHealthRepository({
    required this.gateway,
    AppClock? clock,
    HealthAggregationService? aggregation,
    FakeRepositoryConfig? config,
    HealthConnectionConfig? initialConnection,
  }) : _clock = clock ?? const SystemAppClock(),
       _aggregation = aggregation ?? const HealthAggregationService(),
       _config = config ?? FakeRepositoryConfig(delay: Duration.zero),
       _connection = initialConnection ?? const HealthConnectionConfig();

  final PlatformHealthGateway gateway;
  final AppClock _clock;
  final HealthAggregationService _aggregation;
  final FakeRepositoryConfig _config;

  HealthConnectionConfig _connection;
  final _connectionController =
      StreamController<HealthConnectionConfig>.broadcast();
  final Map<LocalDate, DailyHealthSummary> _cache = {};

  void dispose() => _connectionController.close();

  void _emit() => _connectionController.add(_connection);

  Future<void> _guard() async {
    await Future<void>.delayed(_config.delay);
    if (_config.forceFailure) {
      throw FakeRepositoryException(_config.failureMessage);
    }
  }

  @override
  Stream<HealthConnectionConfig> watchConnection() async* {
    yield _connection;
    yield* _connectionController.stream;
  }

  @override
  Future<HealthConnectionConfig> getConnection() async => _connection;

  @override
  Future<IntegrationAvailability> checkAvailability() =>
      gateway.checkAvailability();

  @override
  Future<HealthPermissionState> requestPermissions(
    Set<HealthMetricGroup> groups,
  ) async {
    await _guard();
    final granted = await gateway.requestPermissions(groups);
    final denied = groups.difference(granted);
    final nextState = _connection.permissionState.copyWith(
      grantedGroups: {..._connection.permissionState.grantedGroups, ...granted},
      deniedGroups: {..._connection.permissionState.deniedGroups, ...denied}
        ..removeAll(granted),
    );
    _connection = _connection.copyWith(
      status: nextState.hasAnyGrant
          ? IntegrationConnectionStatus.connected
          : IntegrationConnectionStatus.error,
      permissionState: nextState,
      connectedAt: nextState.hasAnyGrant
          ? (_connection.connectedAt ?? _clock.now())
          : null,
    );
    _cache.clear();
    _emit();
    return nextState;
  }

  @override
  Future<void> disconnect() async {
    _connection = const HealthConnectionConfig();
    _cache.clear();
    _emit();
  }

  @override
  Future<DailyHealthSummary> getDailySummary(
    LocalDate date, {
    bool forceRefresh = false,
  }) async {
    await _guard();
    if (!forceRefresh && _cache.containsKey(date)) {
      return _cache[date]!;
    }
    final summary = await buildDailySummary(
      gateway: gateway,
      aggregation: _aggregation,
      permissionState: _connection.permissionState,
      date: date,
      now: _clock.now(),
    );
    _cache[date] = summary;
    return summary;
  }

  @override
  Future<void> refresh() async {
    _cache.clear();
    _connection = _connection.copyWith(lastRefreshAt: _clock.now());
    _emit();
  }
}
