import '../../../../core/integrations/domain/integration_connection_status.dart';
import 'health_permission_state.dart';

/// Persisted Health-integration settings (mirrors Calendar's
/// `calendar_config` — durable facts live in each feature's own storage,
/// while `IntegrationConnectionRegistry` only holds process-local UI state).
///
/// Deliberately small: connection status, which permission groups were
/// granted/denied, and refresh bookkeeping — never raw sample values.
class HealthConnectionConfig {
  const HealthConnectionConfig({
    this.status = IntegrationConnectionStatus.notConnected,
    this.permissionState = const HealthPermissionState(),
    this.connectedAt,
    this.lastRefreshAt,
  });

  final IntegrationConnectionStatus status;
  final HealthPermissionState permissionState;
  final DateTime? connectedAt;
  final DateTime? lastRefreshAt;

  bool get isConnected => status == IntegrationConnectionStatus.connected;

  HealthConnectionConfig copyWith({
    IntegrationConnectionStatus? status,
    HealthPermissionState? permissionState,
    DateTime? connectedAt,
    DateTime? lastRefreshAt,
    bool clearConnectedAt = false,
  }) {
    return HealthConnectionConfig(
      status: status ?? this.status,
      permissionState: permissionState ?? this.permissionState,
      connectedAt: clearConnectedAt ? null : (connectedAt ?? this.connectedAt),
      lastRefreshAt: lastRefreshAt ?? this.lastRefreshAt,
    );
  }

  factory HealthConnectionConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HealthConnectionConfig();
    return HealthConnectionConfig(
      status: _statusFrom(json['status'] as String?),
      permissionState: HealthPermissionState.fromJson(
        json['permissionState'] as Map<String, dynamic>?,
      ),
      connectedAt: _parseDate(json['connectedAt']),
      lastRefreshAt: _parseDate(json['lastRefreshAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'permissionState': permissionState.toJson(),
    'connectedAt': connectedAt?.toIso8601String(),
    'lastRefreshAt': lastRefreshAt?.toIso8601String(),
  };

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
