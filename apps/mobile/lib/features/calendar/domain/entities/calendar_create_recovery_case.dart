import 'dart:convert';

/// Why a create outbox row needs manual recovery.
enum CalendarCreateRecoveryType { noMatchUnknownOutcome, multipleMarkerMatches }

enum CalendarCreateRecoveryStatus { unresolved, resolved, dismissed }

/// Sanitized device-event candidate — never stores raw titles.
class CalendarCreateRecoveryCandidate {
  const CalendarCreateRecoveryCandidate({
    required this.externalEventId,
    required this.externalCalendarId,
    this.titleFingerprint,
  });

  final String externalEventId;
  final String externalCalendarId;
  final String? titleFingerprint;

  Map<String, dynamic> toJson() => {
    'externalEventId': externalEventId,
    'externalCalendarId': externalCalendarId,
    if (titleFingerprint != null) 'titleFingerprint': titleFingerprint,
  };

  factory CalendarCreateRecoveryCandidate.fromJson(Map<String, dynamic> json) {
    return CalendarCreateRecoveryCandidate(
      externalEventId: json['externalEventId'] as String,
      externalCalendarId: json['externalCalendarId'] as String,
      titleFingerprint: json['titleFingerprint'] as String?,
    );
  }
}

/// Persisted recovery row for ambiguous create reconciliation.
class CalendarCreateRecoveryCase {
  const CalendarCreateRecoveryCase({
    required this.id,
    required this.syncOperationId,
    required this.memyEventId,
    required this.recoveryType,
    required this.status,
    required this.candidates,
    required this.createdAt,
    this.resolvedAt,
    this.dismissedAt,
  });

  final String id;
  final String syncOperationId;
  final String memyEventId;
  final CalendarCreateRecoveryType recoveryType;
  final CalendarCreateRecoveryStatus status;
  final List<CalendarCreateRecoveryCandidate> candidates;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final DateTime? dismissedAt;

  CalendarCreateRecoveryCase copyWith({
    CalendarCreateRecoveryType? recoveryType,
    CalendarCreateRecoveryStatus? status,
    List<CalendarCreateRecoveryCandidate>? candidates,
    DateTime? resolvedAt,
    DateTime? dismissedAt,
  }) {
    return CalendarCreateRecoveryCase(
      id: id,
      syncOperationId: syncOperationId,
      memyEventId: memyEventId,
      recoveryType: recoveryType ?? this.recoveryType,
      status: status ?? this.status,
      candidates: candidates ?? this.candidates,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      dismissedAt: dismissedAt ?? this.dismissedAt,
    );
  }

  String encodeCandidates() =>
      jsonEncode(candidates.map((c) => c.toJson()).toList());

  static List<CalendarCreateRecoveryCandidate> decodeCandidates(String json) {
    final list = jsonDecode(json) as List<dynamic>;
    return list
        .map(
          (e) => CalendarCreateRecoveryCandidate.fromJson(
            e as Map<String, dynamic>,
          ),
        )
        .toList(growable: false);
  }
}
