import 'dart:async';
import 'dart:convert';

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
import 'health_connection_storage.dart';
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
  String? _backupJson;
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

  Future<void> _persistConnection(HealthConnectionConfig config) async {
    final json = config
        .copyWith(recoveryNeeded: false, backupAvailable: false)
        .toJson();
    if (!isValidHealthConnectionJson(json)) {
      throw StateError('Invalid Health connection config');
    }
    final encoded = jsonEncode(json);
    if (_connection.status != IntegrationConnectionStatus.notConnected ||
        _connection.permissionState.dispositions.isNotEmpty) {
      _backupJson = jsonEncode(_connection.toJson());
    }
    final reread = parseHealthConnectionConfig(encoded, platform: 'android');
    if (reread == null) {
      throw StateError('Health connection write validation failed');
    }
    _connection = reread;
    _emit();
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
    final dispositions = await gateway.requestPermissions(groups);
    final nextState = _connection.permissionState.merging(dispositions);
    await _persistConnection(
      _connection.copyWith(
        status: connectionStatusFor(nextState),
        permissionState: nextState,
        connectedAt: nextState.hasAnyReadable
            ? (_connection.connectedAt ?? _clock.now())
            : null,
        clearConnectedAt: !nextState.hasAnyReadable,
        schemaVersion: HealthConnectionConfig.currentSchemaVersion,
        recoveryNeeded: false,
        backupAvailable: false,
      ),
    );
    _cache.clear();
    return nextState;
  }

  @override
  Future<void> disconnect() async {
    _connection = const HealthConnectionConfig();
    _backupJson = null;
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
    final before = _connection.permissionState;
    final after = await recheckPermissions(
      gateway: gateway,
      current: before,
      shouldRecheck: shouldRecheckPermissionsOnRefresh(gateway),
    );

    clearCacheForRevokedGroups(cache: _cache, before: before, after: after);
    if (!after.hasAnyReadable) {
      _cache.clear();
    }

    _connection = _connection.copyWith(
      permissionState: after,
      status: connectionStatusFor(after),
      lastRefreshAt: _clock.now(),
      connectedAt: after.hasAnyReadable ? _connection.connectedAt : null,
      clearConnectedAt: !after.hasAnyReadable,
    );
    _emit();
  }

  @override
  Future<bool> hasBackupAvailable() async {
    if (_backupJson == null || _backupJson!.isEmpty) return false;
    return parseHealthConnectionConfig(_backupJson!, platform: 'android') !=
        null;
  }

  @override
  Future<HealthConnectionConfig> restoreBackup() async {
    if (_backupJson == null || _backupJson!.isEmpty) {
      throw StateError('No Health connection backup available');
    }
    final backup = parseHealthConnectionConfig(
      _backupJson!,
      platform: 'android',
    );
    if (backup == null) {
      throw StateError('Health connection backup is corrupt');
    }
    await _persistConnection(backup);
    _cache.clear();
    return _connection;
  }

  @override
  Future<void> resetConnection() async {
    await disconnect();
  }

  /// Test hook: corrupt the in-memory primary while keeping backup intact.
  void simulateCorruptPrimaryForTests() {
    _connection = _connection.copyWith(recoveryNeeded: true);
    if (_backupJson != null) {
      _connection = _connection.copyWith(backupAvailable: true);
    }
    _emit();
  }

  /// Test hook: inject corrupt primary JSON in prefs-style storage simulation.
  void setBackupJsonForTests(String json) => _backupJson = json;
}
