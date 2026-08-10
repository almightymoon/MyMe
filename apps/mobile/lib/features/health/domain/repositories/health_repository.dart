import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/integrations/domain/integration_availability.dart';
import '../entities/daily_health_summary.dart';
import '../entities/health_connection_config.dart';
import '../entities/health_metric_type.dart';
import '../entities/health_permission_state.dart';

/// Read-only Health integration boundary used by the application layer.
///
/// Implementations: [FakeHealthRepository] (backs `HEALTH_DATA_SOURCE=fake`,
/// default/CI-safe) and [SystemHealthRepository] (backs
/// `HEALTH_DATA_SOURCE=system`, wraps [SystemPlatformHealthGateway] +
/// durable connection prefs).
///
/// Persistence contract: only [HealthConnectionConfig] (connection status,
/// per-group permission dispositions, last-refresh timestamp, recovery flag)
/// is durably stored. Raw samples are never persisted; [getDailySummary] may
/// keep a short-lived in-memory cache of already-aggregated summaries, which
/// [disconnect] always clears.
abstract class HealthRepository {
  Stream<HealthConnectionConfig> watchConnection();
  Future<HealthConnectionConfig> getConnection();
  Future<IntegrationAvailability> checkAvailability();

  /// Requests OS permission for [groups] and persists the resulting grant.
  /// Never called automatically — callers (Connection/Permission screens)
  /// must be the ones to trigger this from explicit user action.
  Future<HealthPermissionState> requestPermissions(
    Set<HealthMetricGroup> groups,
  );

  /// Clears connection status, permission grants, and any cached summary.
  Future<void> disconnect();

  /// Aggregated metrics for [date]. Returns a summary with every metric in
  /// [DailyHealthSummary.unavailableMetrics] when not connected/permitted —
  /// never throws for "no permission"/"no data".
  Future<DailyHealthSummary> getDailySummary(
    LocalDate date, {
    bool forceRefresh = false,
  });

  /// Forces the next [getDailySummary] call to re-fetch from the platform,
  /// re-checks verified permissions on Android, and updates
  /// [HealthConnectionConfig.lastRefreshAt].
  Future<void> refresh();

  /// Restores connection config from the last-known-good backup (user action).
  ///
  /// Never auto-called — only when the user explicitly chooses recovery.
  Future<HealthConnectionConfig> restoreBackup();

  /// Clears primary and backup connection prefs and resets to disconnected.
  Future<void> resetConnection();

  /// Whether a valid backup config is available for [restoreBackup].
  Future<bool> hasBackupAvailable();
}
