/// Persisted calendar-integration settings (single row in `calendar_config`).
///
/// Schema version 2 separates readable calendars from the writable MeMy
/// destination and uses rolling sync windows instead of frozen connect-time
/// anchors.
class CalendarConfig {
  const CalendarConfig({
    this.readableCalendarIds = const [],
    this.defaultWritableCalendarId,
    this.dedicatedMeMyCalendarId,
    this.syncPastWindowDays = defaultPastWindowDays,
    this.syncFutureWindowDays = defaultFutureWindowDays,
    this.lastSuccessfulPullAt,
    this.lastSuccessfulPushAt,
    this.lastFullSyncAt,
    this.lastPermissionCheckAt,
    this.lastCalendarDiscoveryAt,
    this.connectionConfiguredAt,
    this.calendarSchemaVersion = currentSchemaVersion,
    @Deprecated('Use readableCalendarIds') this.selectedCalendarIds = const [],
    @Deprecated('Use rolling windows') this.initialSyncAnchorPast,
    @Deprecated('Use rolling windows') this.initialSyncAnchorFuture,
  });

  static const int currentSchemaVersion = 2;
  static const int defaultPastWindowDays = 30;
  static const int defaultFutureWindowDays = 365;

  /// Device calendars MeMy imports for display (may include read-only).
  final List<String> readableCalendarIds;

  /// Single writable destination for MeMy-owned events. Never inferred from
  /// [readableCalendarIds] order.
  final String? defaultWritableCalendarId;

  /// Optional dedicated MeMy calendar created on-device when supported.
  final String? dedicatedMeMyCalendarId;

  final int syncPastWindowDays;
  final int syncFutureWindowDays;

  final DateTime? lastSuccessfulPullAt;
  final DateTime? lastSuccessfulPushAt;

  /// Convenience timestamp for "last sync" banners (max of pull/push).
  final DateTime? lastFullSyncAt;

  final DateTime? lastPermissionCheckAt;
  final DateTime? lastCalendarDiscoveryAt;
  final DateTime? connectionConfiguredAt;
  final int calendarSchemaVersion;

  /// Legacy v1 field retained for migration fixtures / transitional reads.
  @Deprecated('Use readableCalendarIds')
  final List<String> selectedCalendarIds;

  @Deprecated('Use rolling windows via syncPastWindowDays')
  final DateTime? initialSyncAnchorPast;

  @Deprecated('Use rolling windows via syncFutureWindowDays')
  final DateTime? initialSyncAnchorFuture;

  /// Readable calendars for sync — prefers v2, falls back to legacy selected.
  List<String> get effectiveReadableCalendarIds {
    if (readableCalendarIds.isNotEmpty) return readableCalendarIds;
    // ignore: deprecated_member_use_from_same_package
    return selectedCalendarIds;
  }

  bool get hasReadableCalendars => effectiveReadableCalendarIds.isNotEmpty;

  bool get hasWritableDestination =>
      defaultWritableCalendarId != null &&
      defaultWritableCalendarId!.isNotEmpty;

  bool get isConnectionConfigured =>
      connectionConfiguredAt != null && hasReadableCalendars;

  Duration get pastWindow => Duration(days: syncPastWindowDays);
  Duration get futureWindow => Duration(days: syncFutureWindowDays);

  /// Rolling pull window relative to [nowUtc].
  ({DateTime start, DateTime end}) rollingWindow(DateTime nowUtc) {
    return (start: nowUtc.subtract(pastWindow), end: nowUtc.add(futureWindow));
  }

  CalendarConfig copyWith({
    List<String>? readableCalendarIds,
    String? defaultWritableCalendarId,
    String? dedicatedMeMyCalendarId,
    int? syncPastWindowDays,
    int? syncFutureWindowDays,
    DateTime? lastSuccessfulPullAt,
    DateTime? lastSuccessfulPushAt,
    DateTime? lastFullSyncAt,
    DateTime? lastPermissionCheckAt,
    DateTime? lastCalendarDiscoveryAt,
    DateTime? connectionConfiguredAt,
    int? calendarSchemaVersion,
    List<String>? selectedCalendarIds,
    DateTime? initialSyncAnchorPast,
    DateTime? initialSyncAnchorFuture,
    bool clearWritableCalendarId = false,
    bool clearDedicatedMeMyCalendarId = false,
  }) {
    return CalendarConfig(
      readableCalendarIds: readableCalendarIds ?? this.readableCalendarIds,
      defaultWritableCalendarId: clearWritableCalendarId
          ? null
          : (defaultWritableCalendarId ?? this.defaultWritableCalendarId),
      dedicatedMeMyCalendarId: clearDedicatedMeMyCalendarId
          ? null
          : (dedicatedMeMyCalendarId ?? this.dedicatedMeMyCalendarId),
      syncPastWindowDays: syncPastWindowDays ?? this.syncPastWindowDays,
      syncFutureWindowDays: syncFutureWindowDays ?? this.syncFutureWindowDays,
      lastSuccessfulPullAt: lastSuccessfulPullAt ?? this.lastSuccessfulPullAt,
      lastSuccessfulPushAt: lastSuccessfulPushAt ?? this.lastSuccessfulPushAt,
      lastFullSyncAt: lastFullSyncAt ?? this.lastFullSyncAt,
      lastPermissionCheckAt:
          lastPermissionCheckAt ?? this.lastPermissionCheckAt,
      lastCalendarDiscoveryAt:
          lastCalendarDiscoveryAt ?? this.lastCalendarDiscoveryAt,
      connectionConfiguredAt:
          connectionConfiguredAt ?? this.connectionConfiguredAt,
      calendarSchemaVersion:
          calendarSchemaVersion ?? this.calendarSchemaVersion,
      selectedCalendarIds: selectedCalendarIds ?? this.selectedCalendarIds,
      initialSyncAnchorPast:
          initialSyncAnchorPast ?? this.initialSyncAnchorPast,
      initialSyncAnchorFuture:
          initialSyncAnchorFuture ?? this.initialSyncAnchorFuture,
    );
  }

  Map<String, dynamic> toJson() => {
    'calendarSchemaVersion': calendarSchemaVersion,
    'readableCalendarIds': readableCalendarIds,
    'defaultWritableCalendarId': defaultWritableCalendarId,
    'dedicatedMeMyCalendarId': dedicatedMeMyCalendarId,
    'syncPastWindowDays': syncPastWindowDays,
    'syncFutureWindowDays': syncFutureWindowDays,
    'lastSuccessfulPullAt': lastSuccessfulPullAt?.toIso8601String(),
    'lastSuccessfulPushAt': lastSuccessfulPushAt?.toIso8601String(),
    'lastFullSyncAt': lastFullSyncAt?.toIso8601String(),
    'lastPermissionCheckAt': lastPermissionCheckAt?.toIso8601String(),
    'lastCalendarDiscoveryAt': lastCalendarDiscoveryAt?.toIso8601String(),
    'connectionConfiguredAt': connectionConfiguredAt?.toIso8601String(),
  };

  factory CalendarConfig.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CalendarConfig();
    final version = (json['calendarSchemaVersion'] as num?)?.toInt() ?? 1;
    final readable =
        _stringList(json['readableCalendarIds']) ??
        _stringList(json['selectedCalendarIds']) ??
        const <String>[];
    return CalendarConfig(
      calendarSchemaVersion: version < 2 ? 2 : version,
      readableCalendarIds: readable,
      selectedCalendarIds: readable,
      defaultWritableCalendarId: json['defaultWritableCalendarId'] as String?,
      dedicatedMeMyCalendarId: json['dedicatedMeMyCalendarId'] as String?,
      syncPastWindowDays:
          (json['syncPastWindowDays'] as num?)?.toInt() ??
          defaultPastWindowDays,
      syncFutureWindowDays:
          (json['syncFutureWindowDays'] as num?)?.toInt() ??
          defaultFutureWindowDays,
      lastSuccessfulPullAt: _parseDate(json['lastSuccessfulPullAt']),
      lastSuccessfulPushAt: _parseDate(json['lastSuccessfulPushAt']),
      lastFullSyncAt: _parseDate(json['lastFullSyncAt']),
      lastPermissionCheckAt: _parseDate(json['lastPermissionCheckAt']),
      lastCalendarDiscoveryAt: _parseDate(json['lastCalendarDiscoveryAt']),
      connectionConfiguredAt: _parseDate(json['connectionConfiguredAt']),
      initialSyncAnchorPast: _parseDate(json['initialSyncAnchorPast']),
      initialSyncAnchorFuture: _parseDate(json['initialSyncAnchorFuture']),
    );
  }

  static List<String>? _stringList(Object? raw) {
    if (raw is! List) return null;
    return raw.map((e) => e.toString()).toList(growable: false);
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw is! String) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }
}
