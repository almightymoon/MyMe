import 'health_metric_type.dart';

/// Per-group read-permission outcome for the Health integration.
///
/// Apple HealthKit never discloses which READ categories the user approved
/// ([requestCompletedUnverified]). Android Health Connect can be verified
/// via `hasPermissions` ([grantedVerified] / [deniedVerified]).
enum HealthPermissionDisposition {
  /// User has not been asked for this group yet.
  notRequested,

  /// Permission sheet completed, but the OS does not disclose READ grants
  /// (HealthKit). MeMy may attempt reads; empty results are ambiguous.
  requestCompletedUnverified,

  /// Platform confirmed read access (Health Connect / fake verified mode).
  grantedVerified,

  /// Platform confirmed the user denied (or revoked) this group.
  deniedVerified,

  /// Health store / data type unavailable on this device.
  unavailable,

  /// User must change access in system Settings (revoked permanently, etc.).
  needsSystemSettings,
}

/// Per-group read-permission snapshot for the Health integration.
///
/// MeMy requests permission **per group** (not all-or-nothing) so a user can
/// share, say, activity data without heart rate or sleep. Persisted as part
/// of connection prefs — see `HealthRepository` docs for what is/isn't
/// durably stored.
class HealthPermissionState {
  const HealthPermissionState({
    this.dispositions = const {},
    this.schemaVersion = currentSchemaVersion,
  });

  /// Current on-disk / in-memory schema for [toJson].
  static const int currentSchemaVersion = 2;

  /// Disposition per group. Missing keys mean [HealthPermissionDisposition.notRequested].
  final Map<HealthMetricGroup, HealthPermissionDisposition> dispositions;

  final int schemaVersion;

  HealthPermissionDisposition dispositionOf(HealthMetricGroup group) =>
      dispositions[group] ?? HealthPermissionDisposition.notRequested;

  /// Whether MeMy should attempt reads for aggregation of [group].
  ///
  /// - iOS [HealthPermissionDisposition.requestCompletedUnverified]: may attempt
  /// - Android [HealthPermissionDisposition.grantedVerified]: readable
  /// - [HealthPermissionDisposition.deniedVerified]: not readable
  bool isReadableForAggregation(HealthMetricGroup group) {
    final d = dispositionOf(group);
    return d == HealthPermissionDisposition.requestCompletedUnverified ||
        d == HealthPermissionDisposition.grantedVerified;
  }

  /// Groups MeMy may attempt to read.
  Set<HealthMetricGroup> get readableGroups =>
      HealthMetricGroup.values.where(isReadableForAggregation).toSet();

  /// Groups verified-granted (Android-style). Empty on pure iOS uncertainty.
  Set<HealthMetricGroup> get grantedGroups => HealthMetricGroup.values
      .where(
        (g) => dispositionOf(g) == HealthPermissionDisposition.grantedVerified,
      )
      .toSet();

  /// Groups explicitly denied / blocked.
  Set<HealthMetricGroup> get deniedGroups =>
      HealthMetricGroup.values.where((g) {
        final d = dispositionOf(g);
        return d == HealthPermissionDisposition.deniedVerified ||
            d == HealthPermissionDisposition.needsSystemSettings;
      }).toSet();

  /// True when at least one group may yield data on read.
  bool get hasAnyReadable => readableGroups.isNotEmpty;

  /// Legacy alias — prefer [hasAnyReadable].
  bool get hasAnyGrant => hasAnyReadable;

  /// True once every group has a non-[notRequested] disposition.
  bool get isFullyResolved => HealthMetricGroup.values.every(
    (g) => dispositionOf(g) != HealthPermissionDisposition.notRequested,
  );

  bool get hasUnverifiedDispositions => dispositions.values.any(
    (d) => d == HealthPermissionDisposition.requestCompletedUnverified,
  );

  int get verifiedGrantedCount => grantedGroups.length;

  HealthPermissionState copyWith({
    Map<HealthMetricGroup, HealthPermissionDisposition>? dispositions,
    int? schemaVersion,
  }) {
    return HealthPermissionState(
      dispositions: dispositions ?? this.dispositions,
      schemaVersion: schemaVersion ?? this.schemaVersion,
    );
  }

  /// Merges [updates] over the current map (does not clear unspecified groups).
  HealthPermissionState merging(
    Map<HealthMetricGroup, HealthPermissionDisposition> updates,
  ) {
    return copyWith(
      dispositions: {...dispositions, ...updates},
      schemaVersion: currentSchemaVersion,
    );
  }

  factory HealthPermissionState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HealthPermissionState();
    final version = _readSchemaVersion(json);

    if (version >= 2 && json['dispositions'] is Map) {
      return HealthPermissionState(
        dispositions: _parseDispositions(json['dispositions']),
        schemaVersion: version,
      );
    }

    // Schema v1: grantedGroups / deniedGroups → verified dispositions.
    final granted = _parseGroups(json['grantedGroups']);
    final denied = _parseGroups(json['deniedGroups']);
    final migrated = <HealthMetricGroup, HealthPermissionDisposition>{};
    for (final g in granted) {
      migrated[g] = HealthPermissionDisposition.grantedVerified;
    }
    for (final g in denied) {
      migrated[g] = HealthPermissionDisposition.deniedVerified;
    }
    return HealthPermissionState(
      dispositions: migrated,
      schemaVersion: currentSchemaVersion,
    );
  }

  Map<String, dynamic> toJson() => {
    'schemaVersion': currentSchemaVersion,
    'dispositions': {
      for (final entry in dispositions.entries)
        entry.key.name: entry.value.name,
    },
    // Keep legacy keys for older builds that may still read prefs briefly.
    'grantedGroups': grantedGroups.map((g) => g.name).toList(),
    'deniedGroups': deniedGroups.map((g) => g.name).toList(),
  };

  static int _readSchemaVersion(Map<String, dynamic> json) {
    final raw = json['schemaVersion'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (json['dispositions'] is Map) return currentSchemaVersion;
    return 1;
  }

  static Map<HealthMetricGroup, HealthPermissionDisposition> _parseDispositions(
    Object? raw,
  ) {
    if (raw is! Map) return const {};
    final result = <HealthMetricGroup, HealthPermissionDisposition>{};
    raw.forEach((key, value) {
      final group = _groupNamed(key?.toString());
      final disposition = _dispositionNamed(value?.toString());
      if (group != null && disposition != null) {
        result[group] = disposition;
      }
    });
    return result;
  }

  static Set<HealthMetricGroup> _parseGroups(Object? raw) {
    if (raw is! List) return const {};
    final result = <HealthMetricGroup>{};
    for (final item in raw) {
      final group = _groupNamed(item?.toString());
      if (group != null) result.add(group);
    }
    return result;
  }

  static HealthMetricGroup? _groupNamed(String? name) {
    if (name == null) return null;
    for (final group in HealthMetricGroup.values) {
      if (group.name == name) return group;
    }
    return null;
  }

  static HealthPermissionDisposition? _dispositionNamed(String? name) {
    if (name == null) return null;
    for (final d in HealthPermissionDisposition.values) {
      if (d.name == name) return d;
    }
    return null;
  }
}
