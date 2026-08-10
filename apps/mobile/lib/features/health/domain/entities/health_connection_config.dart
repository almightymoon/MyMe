import '../../../../core/integrations/domain/integration_connection_status.dart';
import 'health_permission_state.dart';

/// Persisted Health-integration settings (mirrors Calendar's
/// `calendar_config` — durable facts live in each feature's own storage,
/// while `IntegrationConnectionRegistry` only holds process-local UI state).
///
/// Deliberately small: connection status, which permission groups were
/// requested/granted/denied, and refresh bookkeeping — never raw sample
/// values.
class HealthConnectionConfig {
  const HealthConnectionConfig({
    this.status = IntegrationConnectionStatus.notConnected,
    this.permissionState = const HealthPermissionState(),
    this.connectedAt,
    this.lastRefreshAt,
    this.schemaVersion = currentSchemaVersion,
    this.recoveryNeeded = false,
  });

  /// Current on-disk schema for [toJson].
  static const int currentSchemaVersion = 2;

  final IntegrationConnectionStatus status;
  final HealthPermissionState permissionState;
  final DateTime? connectedAt;
  final DateTime? lastRefreshAt;
  final int schemaVersion;

  /// True when prefs JSON was corrupt or unreadable. UI should not treat
  /// this as a clean "never connected" — offer reconnect / clear.
  final bool recoveryNeeded;

  bool get isConnected => status == IntegrationConnectionStatus.connected;

  HealthConnectionConfig copyWith({
    IntegrationConnectionStatus? status,
    HealthPermissionState? permissionState,
    DateTime? connectedAt,
    DateTime? lastRefreshAt,
    int? schemaVersion,
    bool? recoveryNeeded,
    bool clearConnectedAt = false,
  }) {
    return HealthConnectionConfig(
      status: status ?? this.status,
      permissionState: permissionState ?? this.permissionState,
      connectedAt: clearConnectedAt ? null : (connectedAt ?? this.connectedAt),
      lastRefreshAt: lastRefreshAt ?? this.lastRefreshAt,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      recoveryNeeded: recoveryNeeded ?? this.recoveryNeeded,
    );
  }

  factory HealthConnectionConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HealthConnectionConfig();
    final version = _readSchemaVersion(json);
    return HealthConnectionConfig(
      status: _statusFrom(json['status'] as String?),
      permissionState: HealthPermissionState.fromJson(
        json['permissionState'] as Map<String, dynamic>?,
      ),
      connectedAt: _parseDate(json['connectedAt']),
      lastRefreshAt: _parseDate(json['lastRefreshAt']),
      schemaVersion: version,
      recoveryNeeded: json['recoveryNeeded'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': currentSchemaVersion,
    'status': status.name,
    'permissionState': permissionState.toJson(),
    'connectedAt': connectedAt?.toIso8601String(),
    'lastRefreshAt': lastRefreshAt?.toIso8601String(),
    'recoveryNeeded': recoveryNeeded,
  };

  static int _readSchemaVersion(Map<String, dynamic> json) {
    final raw = json['schemaVersion'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return 1;
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String) return null;
    return DateTime.tryParse(raw);
  }

  static IntegrationConnectionStatus _statusFrom(String? raw) {
    for (final value in IntegrationConnectionStatus.values) {
      if (value.name == raw) return value;
    }
    return IntegrationConnectionStatus.notConnected;
  }
}
