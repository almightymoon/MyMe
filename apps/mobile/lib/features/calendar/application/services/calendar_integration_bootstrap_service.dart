import '../../../../core/integrations/application/providers/integration_providers.dart';
import '../../../../core/integrations/domain/integration_availability.dart';
import '../../../../core/integrations/domain/integration_connection_status.dart';
import '../../../../core/integrations/domain/integration_error.dart';
import '../../../../core/integrations/domain/integration_provider.dart';
import '../../domain/gateways/device_calendar_gateway.dart';
import '../../domain/repositories/calendar_repository.dart';
import 'calendar_sync_service.dart';

/// Cold-start hydration for calendar integration state.
///
/// Loads durable config, checks permission/availability, verifies selected
/// calendars still exist, and hydrates [IntegrationConnectionRegistry].
class CalendarIntegrationBootstrapService {
  CalendarIntegrationBootstrapService({
    required this.gateway,
    required this.repository,
    required this.syncService,
    required this.registry,
  });

  final DeviceCalendarGateway gateway;
  final CalendarRepository repository;
  final CalendarSyncService syncService;
  final IntegrationConnectionRegistry registry;

  Future<void> bootstrap() async {
    final config = await repository.getConfig();
    final readable = config.effectiveReadableCalendarIds;

    if (!config.isConnectionConfigured) {
      await syncService.hydrateConnectionFromPersistence();
      return;
    }

    try {
      final availability = await gateway.checkAvailability();
      if (availability != IntegrationAvailability.available) {
        registry.updateConnection(
          IntegrationProvider.calendar,
          (c) => c.copyWith(
            status: IntegrationConnectionStatus.error,
            availability: availability,
            selectedCalendarIds: readable,
            lastError: IntegrationError.unavailable(
              IntegrationProvider.calendar,
            ),
          ),
        );
        return;
      }

      final permitted = await gateway.hasPermissions();
      if (!permitted) {
        registry.updateConnection(
          IntegrationProvider.calendar,
          (c) => c.copyWith(
            status: IntegrationConnectionStatus.error,
            availability: availability,
            selectedCalendarIds: readable,
            lastError: IntegrationError.permissionDenied(
              IntegrationProvider.calendar,
            ),
          ),
        );
        return;
      }

      final calendars = await gateway.listCalendars();
      final existingIds = calendars.map((c) => c.id).toSet();
      final stillReadable = readable
          .where(existingIds.contains)
          .toList(growable: false);
      final writable = config.defaultWritableCalendarId;
      final writableStillExists =
          writable == null || existingIds.contains(writable);

      if (stillReadable.isEmpty || !writableStillExists) {
        registry.updateConnection(
          IntegrationProvider.calendar,
          (c) => c.copyWith(
            status: IntegrationConnectionStatus.error,
            availability: availability,
            selectedCalendarIds: stillReadable,
            lastError: IntegrationError(
              provider: IntegrationProvider.calendar,
              code: IntegrationErrorCode.notFound,
              message:
                  'A previously selected calendar is no longer available. '
                  'Reconnect to choose calendars again.',
            ),
          ),
        );
        // Persist pruned readable set but clear connectionConfigured so UI
        // prompts reconnect when writable vanished.
        if (stillReadable.length != readable.length || !writableStillExists) {
          await repository.saveConfig(
            config.copyWith(
              readableCalendarIds: stillReadable,
              selectedCalendarIds: stillReadable,
              clearWritableCalendarId: !writableStillExists,
            ),
          );
        }
        return;
      }

      if (stillReadable.length != readable.length) {
        await repository.saveConfig(
          config.copyWith(
            readableCalendarIds: stillReadable,
            selectedCalendarIds: stillReadable,
          ),
        );
      }

      await syncService.hydrateConnectionFromPersistence();
    } catch (e) {
      registry.updateConnection(
        IntegrationProvider.calendar,
        (c) => c.copyWith(
          status: IntegrationConnectionStatus.error,
          selectedCalendarIds: readable,
          lastError: IntegrationError.unknown(
            IntegrationProvider.calendar,
            null,
            e,
          ),
        ),
      );
    }
  }
}
