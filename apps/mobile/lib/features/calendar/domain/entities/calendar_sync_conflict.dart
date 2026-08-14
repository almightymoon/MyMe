import 'conflict_resolution.dart';
import 'external_event_snapshot.dart';
import 'memy_calendar_event.dart';

/// A detected divergence between a local event and its linked external
/// event, awaiting user resolution.
class CalendarSyncConflict {
  const CalendarSyncConflict({
    required this.id,
    required this.memyEventId,
    required this.localSnapshot,
    required this.externalSnapshot,
    required this.detectedAt,
    this.linkId,
    this.resolvedAt,
    this.resolution,
  });

  final String id;
  final String memyEventId;
  final String? linkId;

  /// The local event as it stood the moment the conflict was detected.
  final MemyCalendarEvent localSnapshot;
  final ExternalEventSnapshot externalSnapshot;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  final ConflictResolution? resolution;

  bool get isResolved => resolvedAt != null;

  CalendarSyncConflict copyWith({
    DateTime? resolvedAt,
    ConflictResolution? resolution,
  }) {
    return CalendarSyncConflict(
      id: id,
      memyEventId: memyEventId,
      linkId: linkId,
      localSnapshot: localSnapshot,
      externalSnapshot: externalSnapshot,
      detectedAt: detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
    );
  }

  @override
  String toString() =>
      'CalendarSyncConflict(id: $id, memyEventId: $memyEventId, '
      'resolved: $isResolved)';
}
