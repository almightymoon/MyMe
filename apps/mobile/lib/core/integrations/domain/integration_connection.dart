import 'integration_availability.dart';
import 'integration_connection_status.dart';
import 'integration_error.dart';
import 'integration_provider.dart';

/// This app's current relationship with a device/third-party integration.
///
/// Holds only sync *metadata* — never raw content (event titles, health
/// values, etc). Safe to log/inspect in full.
class IntegrationConnection {
  const IntegrationConnection({
    required this.provider,
    this.status = IntegrationConnectionStatus.notConnected,
    this.availability = IntegrationAvailability.unknown,
    this.connectedAt,
    this.lastSyncAt,
    this.lastError,
    this.selectedCalendarIds = const [],
  });

  final IntegrationProvider provider;
  final IntegrationConnectionStatus status;
  final IntegrationAvailability availability;
  final DateTime? connectedAt;
  final DateTime? lastSyncAt;
  final IntegrationError? lastError;

  /// Device calendar ids the user opted in to sync. Empty for providers
  /// without a calendar-selection step (e.g. health).
  final List<String> selectedCalendarIds;

  bool get isConnected => status.allowsLiveSync;
  bool get hasError =>
      status == IntegrationConnectionStatus.error || status.isDegraded;
  bool get isStaleCache =>
      status == IntegrationConnectionStatus.staleCacheAvailable;

  factory IntegrationConnection.initial(IntegrationProvider provider) {
    return IntegrationConnection(provider: provider);
  }

  IntegrationConnection copyWith({
    IntegrationConnectionStatus? status,
    IntegrationAvailability? availability,
    DateTime? connectedAt,
    DateTime? lastSyncAt,
    IntegrationError? lastError,
    List<String>? selectedCalendarIds,
    bool clearLastError = false,
    bool clearConnectedAt = false,
  }) {
    return IntegrationConnection(
      provider: provider,
      status: status ?? this.status,
      availability: availability ?? this.availability,
      connectedAt: clearConnectedAt ? null : (connectedAt ?? this.connectedAt),
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      selectedCalendarIds: selectedCalendarIds ?? this.selectedCalendarIds,
    );
  }

  @override
  String toString() =>
      'IntegrationConnection(${provider.name}, status: ${status.name}, '
      'availability: ${availability.name}, '
      'selectedCalendars: ${selectedCalendarIds.length})';
}
