import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/domain/clock/app_clock.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/integrations/domain/integration_availability.dart';
import '../../domain/entities/daily_health_summary.dart';
import '../../domain/entities/health_connection_config.dart';
import '../../domain/entities/health_metric_type.dart';
import '../../domain/entities/health_permission_state.dart';
import '../../domain/gateways/platform_health_gateway.dart';
import '../../domain/repositories/health_repository.dart';
import '../../domain/services/health_aggregation_service.dart';
import 'health_connection_storage.dart';
import 'health_repository_support.dart';

/// [HealthRepository] backed by [SystemPlatformHealthGateway] with durable
/// connection prefs (SharedPreferences).
///
/// Persists only [HealthConnectionConfig] — connection status, permission
/// dispositions, and the last-refresh instant. Aggregated
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

  @Deprecated('Use HealthConnectionStorageKeys.primary')
  static const String storageKey = HealthConnectionStorageKeys.legacy;

  final PlatformHealthGateway gateway;
  final SharedPreferences prefs;
  final AppClock _clock;
  final HealthAggregationService _aggregation;

  HealthConnectionConfig? _connection;
  final _connectionController =
      StreamController<HealthConnectionConfig>.broadcast();
  final Map<LocalDate, DailyHealthSummary> _cache = {};

  String get _platform {
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'unknown';
  }

  void dispose() => _connectionController.close();

  Future<void> _writeConnection(HealthConnectionConfig config) async {
    final payload = config.copyWith(
      recoveryNeeded: false,
      backupAvailable: false,
      schemaVersion: HealthConnectionConfig.currentSchemaVersion,
    );
    final json = payload.toJson();
    if (!isValidHealthConnectionJson(json)) {
      throw StateError('Invalid Health connection config');
    }

    final encoded = jsonEncode(json);

    // Migrate legacy key on first successful write.
    if (prefs.containsKey(HealthConnectionStorageKeys.legacy)) {
      await prefs.remove(HealthConnectionStorageKeys.legacy);
    }

    final existingPrimary = prefs.getString(
      HealthConnectionStorageKeys.primary,
    );
    if (existingPrimary != null && existingPrimary.isNotEmpty) {
      final existing = parseHealthConnectionConfig(
        existingPrimary,
        platform: _platform,
      );
      if (existing != null) {
        await prefs.setString(
          HealthConnectionStorageKeys.backup,
          existingPrimary,
        );
      }
    }

    await prefs.setString(HealthConnectionStorageKeys.primary, encoded);

    final reread = parseHealthConnectionConfig(encoded, platform: _platform);
    if (reread == null) {
      throw StateError('Health connection write validation failed');
    }

    _connection = reread;
    _connectionController.add(_connection!);
  }

  HealthConnectionConfig _loadFromPrefs() {
    var primaryRaw = prefs.getString(HealthConnectionStorageKeys.primary);
    if (primaryRaw == null || primaryRaw.isEmpty) {
      primaryRaw = prefs.getString(HealthConnectionStorageKeys.legacy);
    }

    if (primaryRaw != null && primaryRaw.isNotEmpty) {
      final parsed = parseHealthConnectionConfig(
        primaryRaw,
        platform: _platform,
      );
      if (parsed != null) return parsed;
    }

    final backupRaw = prefs.getString(HealthConnectionStorageKeys.backup);
    if (backupRaw != null && backupRaw.isNotEmpty) {
      final backup = parseHealthConnectionConfig(
        backupRaw,
        platform: _platform,
      );
      if (backup != null) {
        return backup.copyWith(recoveryNeeded: true, backupAvailable: true);
      }
    }

    return const HealthConnectionConfig();
  }

  HealthConnectionConfig _readConnection() {
    _connection ??= _loadFromPrefs();
    return _connection!;
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
    final dispositions = await gateway.requestPermissions(groups);
    final nextState = current.permissionState.merging(dispositions);
    await _writeConnection(
      current.copyWith(
        status: connectionStatusFor(nextState),
        permissionState: nextState,
        connectedAt: nextState.hasAnyReadable
            ? (current.connectedAt ?? _clock.now())
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
    _cache.clear();
    await prefs.remove(HealthConnectionStorageKeys.primary);
    await prefs.remove(HealthConnectionStorageKeys.backup);
    _connection = const HealthConnectionConfig();
    _connectionController.add(_connection!);
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
    final current = _readConnection();
    final before = current.permissionState;

    final after = await recheckPermissions(
      gateway: gateway,
      current: before,
      shouldRecheck: shouldRecheckPermissionsOnRefresh(gateway),
    );

    clearCacheForRevokedGroups(cache: _cache, before: before, after: after);
    if (!after.hasAnyReadable) {
      _cache.clear();
    }

    await _writeConnection(
      current.copyWith(
        permissionState: after,
        status: connectionStatusFor(after),
        lastRefreshAt: _clock.now(),
        connectedAt: after.hasAnyReadable ? current.connectedAt : null,
        clearConnectedAt: !after.hasAnyReadable,
      ),
    );
  }

  @override
  Future<bool> hasBackupAvailable() async {
    final backupRaw = prefs.getString(HealthConnectionStorageKeys.backup);
    if (backupRaw == null || backupRaw.isEmpty) return false;
    return parseHealthConnectionConfig(backupRaw, platform: _platform) != null;
  }

  @override
  Future<HealthConnectionConfig> restoreBackup() async {
    final backupRaw = prefs.getString(HealthConnectionStorageKeys.backup);
    if (backupRaw == null || backupRaw.isEmpty) {
      throw StateError('No Health connection backup available');
    }
    final backup = parseHealthConnectionConfig(backupRaw, platform: _platform);
    if (backup == null) {
      throw StateError('Health connection backup is corrupt');
    }

    await _writeConnection(backup);
    _cache.clear();
    return _readConnection();
  }

  @override
  Future<void> resetConnection() async {
    await disconnect();
  }
}
