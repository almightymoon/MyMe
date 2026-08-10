import '../../../../core/integrations/domain/integration_provider.dart';

/// Sync bookkeeping between one [MemyCalendarEvent] and its external
/// calendar counterpart. Kept separate from the event row so event content
/// can be queried/rendered without joining sync metadata.
class CalendarEventLink {
  const CalendarEventLink({
    required this.id,
    required this.memyEventId,
    required this.provider,
    required this.externalCalendarId,
    required this.externalEventId,
    required this.lastSyncedAt,
    this.lastKnownExternalUpdatedAt,
  });

  final String id;
  final String memyEventId;
  final IntegrationProvider provider;
  final String externalCalendarId;
  final String externalEventId;
  final DateTime lastSyncedAt;
  final DateTime? lastKnownExternalUpdatedAt;

  CalendarEventLink copyWith({
    DateTime? lastSyncedAt,
    DateTime? lastKnownExternalUpdatedAt,
  }) {
    return CalendarEventLink(
      id: id,
      memyEventId: memyEventId,
      provider: provider,
      externalCalendarId: externalCalendarId,
      externalEventId: externalEventId,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      lastKnownExternalUpdatedAt:
          lastKnownExternalUpdatedAt ?? this.lastKnownExternalUpdatedAt,
    );
  }

  @override
  String toString() =>
      'CalendarEventLink(memyEventId: $memyEventId, '
      'externalCalendarId: $externalCalendarId, '
      'externalEventId: $externalEventId)';
}
