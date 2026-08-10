import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

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

/// [HealthRepository] backed by [SystemPlatformHealthGateway] with durable
/// connection prefs (SharedPreferences).
///
/// Persists only [HealthConnectionConfig] — connection status, granted/
/// denied permission groups, and the last-refresh instant. Aggregated
/// [DailyHealthSummary] results are cached in memory only, for the current
/// app session, and are always cleared on [disconnect].
class SystemHealthRepository implements HealthRepository {
  SystemHealthRepository({
    required this.gateway,
    required this.prefs,
    AppClock? clock,
    HealthAggregationService? aggregation,
  }) : _clock = clock ?? const SystemAppClock(),
       _aggregation = aggregation ?? const HealthAggregationService();

  static const String storageKey = 'memy_health_connection_v1';

  final PlatformHealthGateway gateway;
  final SharedPreferences prefs;
  final AppClock _clock;
  final HealthAggregationService _aggregation;

  HealthConnectionConfig? _connection;
  final _connectionController =
      StreamController<HealthConnectionConfig>.broadcast();
  final Map<LocalDate, DailyHealthSummary> _cache = {};

  void dispose() => _connectionController.close();

  HealthConnectionConfig _readConnection() {
    if (_connection != null) return _connection!;
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      _connection = const HealthConnectionConfig();
      return _connection!;
    }
    try {
      final decoded = jsonDecode(raw);
      _connection = HealthConnectionConfig.fromJson(
        decoded is Map<String, dynamic>
            ? decoded
            : decoded is Map
            ? Map<String, dynamic>.from(decoded)
            : null,
      );
    } catch (_) {
      _connection = const HealthConnectionConfig();
    }
    return _connection!;
  }

  Future<void> _writeConnection(HealthConnectionConfig config) async {
    _connection = config;
    await prefs.setString(storageKey, jsonEncode(config.toJson()));
    _connectionController.add(config);
  }

  @override
  Stream<HealthConnectionConfig> watchConnection() async* {
    yield _readConnection();
    yield* _connectionController.stream;
  }

  @override
  Future<HealthConnectionConfig> getConnection() async => _readConnection();

  @override
  Future<IntegrationAvailability> checkAvailability() =>
      gateway.checkAvailability();

  @override
  Future<HealthPermissionState> requestPermissions(
    Set<HealthMetricGroup> groups,
  ) async {
    final current = _readConnection();
    final granted = await gateway.requestPermissions(groups);
    final denied = groups.difference(granted);
    final nextState = current.permissionState.copyWith(
      grantedGroups: {...current.permissionState.grantedGroups, ...granted},
      deniedGroups: {...current.permissionState.deniedGroups, ...denied}
        ..removeAll(granted),
    );
    await _writeConnection(
      current.copyWith(
        status: nextState.hasAnyGrant
            ? IntegrationConnectionStatus.connected
            : IntegrationConnectionStatus.error,
        permissionState: nextState,
        connectedAt: nextState.hasAnyGrant
            ? (current.connectedAt ?? _clock.now())
            : null,
      ),
    );
    _cache.clear();
    return nextState;
  }

  @override
  Future<void> disconnect() async {
    _cache.clear();
    await _writeConnection(const HealthConnectionConfig());
  }

  @override
  Future<DailyHealthSummary> getDailySummary(
    LocalDate date, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache.containsKey(date)) {
      return _cache[date]!;
    }
    final connection = _readConnection();
    final summary = await buildDailySummary(
      gateway: gateway,
      aggregation: _aggregation,
      permissionState: connection.permissionState,
      date: date,
      now: _clock.now(),
    );
    _cache[date] = summary;
    return summary;
  }

  @override
  Future<void> refresh() async {
    _cache.clear();
    final current = _readConnection();
    await _writeConnection(current.copyWith(lastRefreshAt: _clock.now()));
  }
}
