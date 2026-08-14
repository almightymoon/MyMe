import '../../../../core/config/environment_config.dart';
import '../../../../core/integrations/domain/integration_diagnostics_report.dart';

/// Typed, allowlist-only diagnostics payload for support reports.
///
/// Built via explicit field mapping — never by walking arbitrary maps.
class SupportDiagnosticsReport {
  const SupportDiagnosticsReport({
    required this.generatedAtUtc,
    required this.osFamily,
    required this.osVersion,
    required this.timezone,
    required this.locale,
    required this.isDebugBuild,
    required this.goalsDataSource,
    required this.financeDataSource,
    required this.habitsDataSource,
    required this.calendarDataSource,
    required this.healthDataSource,
    required this.calendar,
    required this.health,
    required this.wardrobe,
  });

  final DateTime generatedAtUtc;
  final String osFamily;
  final String osVersion;
  final String timezone;
  final String locale;
  final bool isDebugBuild;
  final String goalsDataSource;
  final String financeDataSource;
  final String habitsDataSource;
  final String calendarDataSource;
  final String healthDataSource;
  final SupportCalendarDiagnostics calendar;
  final SupportHealthDiagnostics health;
  final SupportWardrobeDiagnostics wardrobe;

  factory SupportDiagnosticsReport.fromIntegration({
    required IntegrationDiagnosticsReport report,
    SupportWardrobeDiagnostics wardrobe = const SupportWardrobeDiagnostics(),
  }) {
    return SupportDiagnosticsReport(
      generatedAtUtc: report.generatedAtUtc,
      osFamily: report.app.osFamily,
      osVersion: report.app.osVersion,
      timezone: report.app.timezone,
      locale: report.app.locale,
      isDebugBuild: report.app.isDebugBuild,
      goalsDataSource: EnvironmentConfig.goalsDataSource.name,
      financeDataSource: EnvironmentConfig.financeDataSource.name,
      habitsDataSource: EnvironmentConfig.habitsDataSource.name,
      calendarDataSource: EnvironmentConfig.calendarDataSource.name,
      healthDataSource: EnvironmentConfig.healthDataSource.name,
      calendar: SupportCalendarDiagnostics.fromSection(report.calendar),
      health: SupportHealthDiagnostics.fromSection(report.health),
      wardrobe: wardrobe,
    );
  }

  /// Only known fields — never copies unexpected nested keys.
  Map<String, Object?> toJson() => {
    'generatedAtUtc': generatedAtUtc.toUtc().toIso8601String(),
    'osFamily': osFamily,
    'osVersion': osVersion,
    'timezone': timezone,
    'locale': locale,
    'isDebugBuild': isDebugBuild,
    'goalsDataSource': goalsDataSource,
    'financeDataSource': financeDataSource,
    'habitsDataSource': habitsDataSource,
    'calendarDataSource': calendarDataSource,
    'healthDataSource': healthDataSource,
    'calendar': calendar.toJson(),
    'health': health.toJson(),
    'wardrobe': wardrobe.toJson(),
  };
}

class SupportWardrobeDiagnostics {
  const SupportWardrobeDiagnostics({
    this.dataSource = 'local',
    this.schemaVersion = 1,
    this.itemCount = 0,
    this.outfitCount = 0,
    this.planCount = 0,
    this.imageStorageBytes = 0,
    this.lastErrorCode,
  });

  final String dataSource;
  final int schemaVersion;
  final int itemCount;
  final int outfitCount;
  final int planCount;
  final int imageStorageBytes;
  final String? lastErrorCode;

  Map<String, Object?> toJson() => {
    'dataSource': dataSource,
    'schemaVersion': schemaVersion,
    'itemCount': itemCount,
    'outfitCount': outfitCount,
    'planCount': planCount,
    'imageStorageBytes': imageStorageBytes,
    'lastErrorCode': lastErrorCode,
  };
}

class SupportCalendarDiagnostics {
  const SupportCalendarDiagnostics({
    required this.gatewayMode,
    required this.availability,
    required this.connectionStatus,
    required this.readableCalendarCount,
    required this.hasValidWritableTarget,
    required this.calendarSchemaVersion,
    required this.pendingOperationCount,
    required this.conflictCount,
    required this.suspectedMissingCount,
    required this.confirmedMissingCount,
    required this.unresolvedRecoveryCount,
    required this.unknownOutcomeCount,
    required this.requiresUserActionCount,
    this.lastSuccessfulPullAt,
    this.lastSuccessfulPushAt,
    this.lastErrorCode,
  });

  final String gatewayMode;
  final String availability;
  final String connectionStatus;
  final int readableCalendarCount;
  final bool hasValidWritableTarget;
  final int calendarSchemaVersion;
  final int pendingOperationCount;
  final int conflictCount;
  final int suspectedMissingCount;
  final int confirmedMissingCount;
  final int unresolvedRecoveryCount;
  final int unknownOutcomeCount;
  final int requiresUserActionCount;
  final DateTime? lastSuccessfulPullAt;
  final DateTime? lastSuccessfulPushAt;
  final String? lastErrorCode;

  factory SupportCalendarDiagnostics.fromSection(
    CalendarDiagnosticsSection section,
  ) {
    return SupportCalendarDiagnostics(
      gatewayMode: section.gatewayMode,
      availability: section.availability,
      connectionStatus: section.connectionStatus,
      readableCalendarCount: section.readableCalendarCount,
      hasValidWritableTarget: section.hasValidWritableTarget,
      calendarSchemaVersion: section.calendarSchemaVersion,
      pendingOperationCount: section.pendingOperationCount,
      conflictCount: section.conflictCount,
      suspectedMissingCount: section.suspectedMissingCount,
      confirmedMissingCount: section.confirmedMissingCount,
      unresolvedRecoveryCount: section.unresolvedRecoveryCount,
      unknownOutcomeCount: section.unknownOutcomeCount,
      requiresUserActionCount: section.requiresUserActionCount,
      lastSuccessfulPullAt: section.lastSuccessfulPullAt,
      lastSuccessfulPushAt: section.lastSuccessfulPushAt,
      lastErrorCode: section.lastErrorCode,
    );
  }

  Map<String, Object?> toJson() => {
    'gatewayMode': gatewayMode,
    'availability': availability,
    'connectionStatus': connectionStatus,
    'readableCalendarCount': readableCalendarCount,
    'hasValidWritableTarget': hasValidWritableTarget,
    'calendarSchemaVersion': calendarSchemaVersion,
    'pendingOperationCount': pendingOperationCount,
    'conflictCount': conflictCount,
    'suspectedMissingCount': suspectedMissingCount,
    'confirmedMissingCount': confirmedMissingCount,
    'unresolvedRecoveryCount': unresolvedRecoveryCount,
    'unknownOutcomeCount': unknownOutcomeCount,
    'requiresUserActionCount': requiresUserActionCount,
    'lastSuccessfulPullAt': lastSuccessfulPullAt?.toUtc().toIso8601String(),
    'lastSuccessfulPushAt': lastSuccessfulPushAt?.toUtc().toIso8601String(),
    'lastErrorCode': lastErrorCode,
  };
}

class SupportHealthDiagnostics {
  const SupportHealthDiagnostics({
    required this.gatewayMode,
    required this.availability,
    required this.connectionStatus,
    required this.permissionDispositions,
    required this.configSchemaVersion,
    required this.recoveryNeeded,
    required this.backupAvailable,
    this.lastSuccessfulRefreshAt,
    this.lastErrorCode,
  });

  final String gatewayMode;
  final String availability;
  final String connectionStatus;
  final Map<String, String> permissionDispositions;
  final int configSchemaVersion;
  final bool recoveryNeeded;
  final bool backupAvailable;
  final DateTime? lastSuccessfulRefreshAt;
  final String? lastErrorCode;

  factory SupportHealthDiagnostics.fromSection(
    HealthDiagnosticsSection section,
  ) {
    return SupportHealthDiagnostics(
      gatewayMode: section.gatewayMode,
      availability: section.availability,
      connectionStatus: section.connectionStatus,
      permissionDispositions: Map<String, String>.unmodifiable(
        section.permissionDispositions,
      ),
      configSchemaVersion: section.configSchemaVersion,
      recoveryNeeded: section.recoveryNeeded,
      backupAvailable: section.backupAvailable,
      lastSuccessfulRefreshAt: section.lastSuccessfulRefreshAt,
      lastErrorCode: section.lastErrorCode,
    );
  }

  Map<String, Object?> toJson() => {
    'gatewayMode': gatewayMode,
    'availability': availability,
    'connectionStatus': connectionStatus,
    'permissionDispositions': permissionDispositions,
    'configSchemaVersion': configSchemaVersion,
    'recoveryNeeded': recoveryNeeded,
    'backupAvailable': backupAvailable,
    'lastSuccessfulRefreshAt': lastSuccessfulRefreshAt
        ?.toUtc()
        .toIso8601String(),
    'lastErrorCode': lastErrorCode,
  };
}
