import '../../../../core/integrations/domain/integration_provider.dart';
import 'calendar_event_lookup_result.dart';
import 'external_presence_status.dart';

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
    this.presence = ExternalPresenceStatus.present,
    this.lastSeenExternallyAt,
    this.firstMissingObservationAt,
    this.lastMissingObservationAt,
    this.missingObservationCount = 0,
    this.lastCompleteQueryStart,
    this.lastCompleteQueryEnd,
    this.hiddenLocally = false,
    this.memyMarker,
    this.lastVerifiedLookupAt,
    this.lastLookupDisposition,
  });

  final String id;
  final String memyEventId;
  final IntegrationProvider provider;
  final String externalCalendarId;
  final String externalEventId;
  final DateTime lastSyncedAt;
  final DateTime? lastKnownExternalUpdatedAt;

  final ExternalPresenceStatus presence;
  final DateTime? lastSeenExternallyAt;
  final DateTime? firstMissingObservationAt;
  final DateTime? lastMissingObservationAt;
  final int missingObservationCount;
  final DateTime? lastCompleteQueryStart;
  final DateTime? lastCompleteQueryEnd;

  /// Soft-hide imported external events after confirmed device deletion.
  final bool hiddenLocally;

  /// Stable MeMy marker written into the device event URL/metadata.
  final String? memyMarker;

  final DateTime? lastVerifiedLookupAt;
  final CalendarEventLookupDisposition? lastLookupDisposition;

  CalendarEventLink copyWith({
    DateTime? lastSyncedAt,
    DateTime? lastKnownExternalUpdatedAt,
    ExternalPresenceStatus? presence,
    DateTime? lastSeenExternallyAt,
    DateTime? firstMissingObservationAt,
    DateTime? lastMissingObservationAt,
    int? missingObservationCount,
    DateTime? lastCompleteQueryStart,
    DateTime? lastCompleteQueryEnd,
    bool? hiddenLocally,
    String? memyMarker,
    DateTime? lastVerifiedLookupAt,
    CalendarEventLookupDisposition? lastLookupDisposition,
    bool clearFirstMissing = false,
    bool clearLastMissing = false,
    bool clearLastLookup = false,
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
      presence: presence ?? this.presence,
      lastSeenExternallyAt: lastSeenExternallyAt ?? this.lastSeenExternallyAt,
      firstMissingObservationAt: clearFirstMissing
          ? null
          : (firstMissingObservationAt ?? this.firstMissingObservationAt),
      lastMissingObservationAt: clearLastMissing
          ? null
          : (lastMissingObservationAt ?? this.lastMissingObservationAt),
      missingObservationCount:
          missingObservationCount ?? this.missingObservationCount,
      lastCompleteQueryStart:
          lastCompleteQueryStart ?? this.lastCompleteQueryStart,
      lastCompleteQueryEnd: lastCompleteQueryEnd ?? this.lastCompleteQueryEnd,
      hiddenLocally: hiddenLocally ?? this.hiddenLocally,
      memyMarker: memyMarker ?? this.memyMarker,
      lastVerifiedLookupAt: clearLastLookup
          ? null
          : (lastVerifiedLookupAt ?? this.lastVerifiedLookupAt),
      lastLookupDisposition: clearLastLookup
          ? null
          : (lastLookupDisposition ?? this.lastLookupDisposition),
    );
  }

  @override
  String toString() =>
      'CalendarEventLink(memyEventId: $memyEventId, '
      'presence: ${presence.name}, hidden: $hiddenLocally)';
}
