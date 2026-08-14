import '../../../../core/integrations/domain/integration_provider.dart';
import 'calendar_event_origin.dart';
import 'calendar_event_sync_status.dart';
import 'calendar_event_time.dart';

/// MeMy's own calendar event — the only calendar event type presentation
/// and application code should depend on. Device-plugin types never reach
/// this layer; gateways translate at the boundary.
class MemyCalendarEvent {
  const MemyCalendarEvent({
    required this.id,
    required this.title,
    required this.time,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.location,
    this.origin = CalendarEventOrigin.local,
    this.syncStatus = CalendarEventSyncStatus.localOnly,
    this.provider,
    this.externalCalendarId,
    this.externalEventId,
    this.reminderMinutes = const [],
    this.deletedAt,
    this.version = 1,
  });

  final String id;
  final String title;
  final String? notes;
  final String? location;
  final CalendarEventTime time;
  final CalendarEventOrigin origin;
  final CalendarEventSyncStatus syncStatus;
  final IntegrationProvider? provider;
  final String? externalCalendarId;
  final String? externalEventId;
  final List<int> reminderMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int version;

  bool get isLinkedToExternal =>
      externalCalendarId != null && externalEventId != null;
  bool get isDeleted => deletedAt != null;
  bool get isAllDay => time.isAllDay;

  /// Whether any part of the event overlaps the half-open UTC range
  /// `[startUtc, endUtc)`.
  bool overlapsRange({required DateTime startUtc, required DateTime endUtc}) {
    return time.startUtc.isBefore(endUtc) && time.endUtc.isAfter(startUtc);
  }

  MemyCalendarEvent copyWith({
    String? title,
    String? notes,
    String? location,
    CalendarEventTime? time,
    CalendarEventOrigin? origin,
    CalendarEventSyncStatus? syncStatus,
    IntegrationProvider? provider,
    String? externalCalendarId,
    String? externalEventId,
    List<int>? reminderMinutes,
    DateTime? updatedAt,
    DateTime? deletedAt,
    int? version,
    bool clearNotes = false,
    bool clearLocation = false,
    bool clearExternalLink = false,
    bool clearDeletedAt = false,
  }) {
    return MemyCalendarEvent(
      id: id,
      title: title ?? this.title,
      notes: clearNotes ? null : (notes ?? this.notes),
      location: clearLocation ? null : (location ?? this.location),
      time: time ?? this.time,
      origin: origin ?? this.origin,
      syncStatus: syncStatus ?? this.syncStatus,
      provider: clearExternalLink ? null : (provider ?? this.provider),
      externalCalendarId: clearExternalLink
          ? null
          : (externalCalendarId ?? this.externalCalendarId),
      externalEventId: clearExternalLink
          ? null
          : (externalEventId ?? this.externalEventId),
      reminderMinutes: reminderMinutes ?? this.reminderMinutes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'notes': notes,
      'location': location,
      'time': time.toJson(),
      'origin': origin.name,
      'syncStatus': syncStatus.name,
      'provider': provider?.name,
      'externalCalendarId': externalCalendarId,
      'externalEventId': externalEventId,
      'reminderMinutes': reminderMinutes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'version': version,
    };
  }

  factory MemyCalendarEvent.fromJson(Map<String, dynamic> json) {
    return MemyCalendarEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      time: calendarEventTimeFromJson(
        Map<String, dynamic>.from(json['time'] as Map),
      ),
      origin: CalendarEventOrigin.values.byName(json['origin'] as String),
      syncStatus: CalendarEventSyncStatus.values.byName(
        json['syncStatus'] as String,
      ),
      provider: json['provider'] == null
          ? null
          : IntegrationProvider.values.byName(json['provider'] as String),
      externalCalendarId: json['externalCalendarId'] as String?,
      externalEventId: json['externalEventId'] as String?,
      reminderMinutes: (json['reminderMinutes'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(growable: false),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  @override
  String toString() => 'MemyCalendarEvent(id: $id, syncStatus: $syncStatus)';
}
