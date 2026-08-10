import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/config/environment_config.dart';
import '../../../../core/integrations/application/providers/integration_providers.dart';
import '../../../../core/integrations/domain/integration_diagnostics_report.dart';
import '../../../../core/integrations/domain/integration_provider.dart';
import '../../../calendar/application/providers/calendar_providers.dart';
import '../../../calendar/domain/entities/external_presence_status.dart';
import '../../../health/application/providers/health_providers.dart' as health;
import '../../../health/domain/entities/health_metric_type.dart';

/// Builds a redacted [IntegrationDiagnosticsReport] from live repositories.
final integrationDiagnosticsProvider =
    FutureProvider.autoDispose<IntegrationDiagnosticsReport>((ref) async {
      final clock = ref.watch(appClockProvider);
      final calendarRepo = ref.watch(calendarRepositoryProvider);
      final healthRepo = ref.watch(health.healthRepositoryProvider);
      final calendarConnection = ref.watch(calendarConnectionProvider);
      final healthRegistry = ref.watch(
        integrationConnectionRegistryProvider,
      )[IntegrationProvider.health];

      final config = await calendarRepo.getConfig();
      final pending = await calendarRepo.getPendingOperations();
      final conflicts = await calendarRepo.getConflicts();
      final links = await calendarRepo.getAllLinks();
      final healthConnection = await healthRepo.getConnection();
      final healthAvailability = await healthRepo.checkAvailability();

      final suspected = links
          .where((l) => l.presence == ExternalPresenceStatus.suspectedMissing)
          .length;
      final confirmed = links
          .where((l) => l.presence == ExternalPresenceStatus.confirmedMissing)
          .length;

      final dispositions = <String, String>{
        for (final group in HealthMetricGroup.values)
          group.name: healthConnection.permissionState
              .dispositionOf(group)
              .name,
      };

      return IntegrationDiagnosticsReport(
        generatedAtUtc: clock.now().toUtc(),
        app: AppDiagnosticsSection.capture(
          locale: WidgetsBinding.instance.platformDispatcher.locale.toString(),
        ),
        calendar: CalendarDiagnosticsSection(
          gatewayMode: EnvironmentConfig.calendarDataSource.name,
          availability: calendarConnection.availability.name,
          connectionStatus: calendarConnection.status.name,
          readableCalendarCount: config.effectiveReadableCalendarIds.length,
          hasValidWritableTarget: config.hasWritableDestination,
          calendarSchemaVersion: config.calendarSchemaVersion,
          pendingOperationCount: pending.length,
          conflictCount: conflicts.length,
          suspectedMissingCount: suspected,
          confirmedMissingCount: confirmed,
          lastSuccessfulPullAt: config.lastSuccessfulPullAt,
          lastSuccessfulPushAt: config.lastSuccessfulPushAt,
          lastErrorCode: calendarConnection.lastError?.code.name,
        ),
        health: HealthDiagnosticsSection(
          gatewayMode: EnvironmentConfig.healthDataSource.name,
          availability: healthAvailability.name,
          connectionStatus: healthConnection.status.name,
          permissionDispositions: dispositions,
          configSchemaVersion: healthConnection.schemaVersion,
          recoveryNeeded: healthConnection.recoveryNeeded,
          lastSuccessfulRefreshAt: healthConnection.lastRefreshAt,
          lastErrorCode: healthRegistry?.lastError?.code.name,
        ),
      );
    });
