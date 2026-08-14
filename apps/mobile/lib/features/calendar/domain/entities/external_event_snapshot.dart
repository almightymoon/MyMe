import 'calendar_event_time.dart';

/// A point-in-time copy of what the external calendar held for an event,
/// captured at conflict-detection time so both sides of a
/// [CalendarSyncConflict] can be shown/compared even after further syncs.
class ExternalEventSnapshot {
  const ExternalEventSnapshot({
    required this.title,
    required this.time,
    this.notes,
    this.location,
    this.lastModifiedUtc,
  });

  final String title;
  final String? notes;
  final String? location;
  final CalendarEventTime time;
  final DateTime? lastModifiedUtc;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'notes': notes,
      'location': location,
      'time': time.toJson(),
      'lastModifiedUtc': lastModifiedUtc?.toIso8601String(),
    };
  }

  factory ExternalEventSnapshot.fromJson(Map<String, dynamic> json) {
    return ExternalEventSnapshot(
      title: json['title'] as String,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      time: calendarEventTimeFromJson(
        Map<String, dynamic>.from(json['time'] as Map),
      ),
      lastModifiedUtc: json['lastModifiedUtc'] == null
          ? null
          : DateTime.parse(json['lastModifiedUtc'] as String),
    );
  }

  @override
  String toString() => 'ExternalEventSnapshot(lastModified: $lastModifiedUtc)';
}
