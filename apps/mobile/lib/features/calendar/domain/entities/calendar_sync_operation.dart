/// Durable outbox row for a single Calendar push operation.
enum CalendarSyncOperationType { create, update, delete }

enum CalendarSyncOperationState {
  prepared,
  inFlight,
  completed,
  retryableFailure,
  unknownOutcome,
  permanentlyFailed,
}

class CalendarSyncOperation {
  const CalendarSyncOperation({
    required this.id,
    required this.memyEventId,
    required this.operationType,
    required this.targetCalendarId,
    required this.payloadFingerprint,
    required this.state,
    required this.attemptCount,
    required this.createdAt,
    this.providerExternalEventId,
    this.startedAt,
    this.completedAt,
    this.nextRetryAt,
    this.lastErrorCode,
    this.memyMarker,
  });

  final String id;
  final String memyEventId;
  final CalendarSyncOperationType operationType;
  final String targetCalendarId;
  final String payloadFingerprint;
  final CalendarSyncOperationState state;
  final int attemptCount;
  final String? providerExternalEventId;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? nextRetryAt;
  final String? lastErrorCode;

  /// Stable MeMy marker attached to the device event for reconciliation
  /// (`memy://calendar-event/<local-event-id>`).
  final String? memyMarker;

  static String markerFor(String memyEventId) =>
      'memy://calendar-event/$memyEventId';

  CalendarSyncOperation copyWith({
    CalendarSyncOperationState? state,
    int? attemptCount,
    String? providerExternalEventId,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? nextRetryAt,
    String? lastErrorCode,
    String? memyMarker,
    bool clearProviderExternalEventId = false,
    bool clearNextRetryAt = false,
    bool clearLastErrorCode = false,
  }) {
    return CalendarSyncOperation(
      id: id,
      memyEventId: memyEventId,
      operationType: operationType,
      targetCalendarId: targetCalendarId,
      payloadFingerprint: payloadFingerprint,
      state: state ?? this.state,
      attemptCount: attemptCount ?? this.attemptCount,
      providerExternalEventId: clearProviderExternalEventId
          ? null
          : (providerExternalEventId ?? this.providerExternalEventId),
      createdAt: createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      nextRetryAt: clearNextRetryAt ? null : (nextRetryAt ?? this.nextRetryAt),
      lastErrorCode: clearLastErrorCode
          ? null
          : (lastErrorCode ?? this.lastErrorCode),
      memyMarker: memyMarker ?? this.memyMarker,
    );
  }
}
