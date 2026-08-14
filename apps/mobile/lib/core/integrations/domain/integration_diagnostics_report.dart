import 'dart:io';

import 'package:flutter/foundation.dart';

/// Fully redacted operational snapshot for Connected Apps diagnostics.
///
/// Never includes event titles/notes/locations, Health values, device IDs,
/// account emails, or raw exception text.
class IntegrationDiagnosticsReport {
  const IntegrationDiagnosticsReport({
    required this.generatedAtUtc,
    required this.app,
    required this.calendar,
    required this.health,
  });

  final DateTime generatedAtUtc;
  final AppDiagnosticsSection app;
  final CalendarDiagnosticsSection calendar;
  final HealthDiagnosticsSection health;

  Map<String, Object?> toJson() => {
    'generatedAtUtc': generatedAtUtc.toUtc().toIso8601String(),
    'app': app.toJson(),
    'calendar': calendar.toJson(),
    'health': health.toJson(),
  };
}

class AppDiagnosticsSection {
  const AppDiagnosticsSection({
    required this.osFamily,
    required this.osVersion,
    required this.timezone,
    required this.locale,
    required this.isDebugBuild,
  });

  final String osFamily;
  final String osVersion;
  final String timezone;
  final String locale;
  final bool isDebugBuild;

  Map<String, Object?> toJson() => {
    'osFamily': osFamily,
    'osVersion': osVersion,
    'timezone': timezone,
    'locale': locale,
    'isDebugBuild': isDebugBuild,
  };

  static AppDiagnosticsSection capture({required String locale}) {
    return AppDiagnosticsSection(
      osFamily: Platform.operatingSystem,
      osVersion: Platform.operatingSystemVersion,
      timezone: DateTime.now().timeZoneName,
      locale: locale,
      isDebugBuild: kDebugMode,
    );
  }
}

class CalendarDiagnosticsSection {
  const CalendarDiagnosticsSection({
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

class HealthDiagnosticsSection {
  const HealthDiagnosticsSection({
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
