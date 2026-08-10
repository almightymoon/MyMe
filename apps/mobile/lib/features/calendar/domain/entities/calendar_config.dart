/// Persisted calendar-integration settings (single row in `calendar_config`).
class CalendarConfig {
  const CalendarConfig({
    this.selectedCalendarIds = const [],
    this.lastFullSyncAt,
    this.initialSyncAnchorPast,
    this.initialSyncAnchorFuture,
  });

  /// Device calendar ids the user opted in to sync.
  final List<String> selectedCalendarIds;
  final DateTime? lastFullSyncAt;

  /// Frozen start of the initial sync window (now − 30 days at connect
  /// time), so subsequent incremental syncs know the original horizon.
  final DateTime? initialSyncAnchorPast;

  /// Frozen end of the initial sync window (now + 365 days at connect time).
  final DateTime? initialSyncAnchorFuture;

  bool get hasSelectedCalendars => selectedCalendarIds.isNotEmpty;

  CalendarConfig copyWith({
    List<String>? selectedCalendarIds,
    DateTime? lastFullSyncAt,
    DateTime? initialSyncAnchorPast,
    DateTime? initialSyncAnchorFuture,
  }) {
    return CalendarConfig(
      selectedCalendarIds: selectedCalendarIds ?? this.selectedCalendarIds,
      lastFullSyncAt: lastFullSyncAt ?? this.lastFullSyncAt,
      initialSyncAnchorPast:
          initialSyncAnchorPast ?? this.initialSyncAnchorPast,
      initialSyncAnchorFuture:
          initialSyncAnchorFuture ?? this.initialSyncAnchorFuture,
    );
  }
}
