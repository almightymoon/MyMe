import 'health_metric_type.dart';

/// Per-group read-permission snapshot for the Health integration.
///
/// MeMy requests permission **per group** (not all-or-nothing) so a user can
/// share, say, activity data without heart rate or sleep. Persisted as part
/// of connection prefs — see `HealthRepository` docs for what is/isn't
/// durably stored.
class HealthPermissionState {
  const HealthPermissionState({
    this.grantedGroups = const {},
    this.deniedGroups = const {},
  });

  final Set<HealthMetricGroup> grantedGroups;
  final Set<HealthMetricGroup> deniedGroups;

  bool isGranted(HealthMetricGroup group) => grantedGroups.contains(group);

  bool get hasAnyGrant => grantedGroups.isNotEmpty;

  /// True once every group has been asked about (granted or denied) — used
  /// to distinguish "never asked" from "asked and declined everything".
  bool get isFullyResolved =>
      grantedGroups.length + deniedGroups.length ==
      HealthMetricGroup.values.length;

  HealthPermissionState copyWith({
    Set<HealthMetricGroup>? grantedGroups,
    Set<HealthMetricGroup>? deniedGroups,
  }) {
    return HealthPermissionState(
      grantedGroups: grantedGroups ?? this.grantedGroups,
      deniedGroups: deniedGroups ?? this.deniedGroups,
    );
  }

  factory HealthPermissionState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const HealthPermissionState();
    final granted = _parseGroups(json['grantedGroups']);
    final denied = _parseGroups(json['deniedGroups']);
    return HealthPermissionState(grantedGroups: granted, deniedGroups: denied);
  }

  Map<String, dynamic> toJson() => {
    'grantedGroups': grantedGroups.map((g) => g.name).toList(),
    'deniedGroups': deniedGroups.map((g) => g.name).toList(),
  };

  static Set<HealthMetricGroup> _parseGroups(Object? raw) {
    if (raw is! List) return const {};
    final result = <HealthMetricGroup>{};
    for (final item in raw) {
      for (final group in HealthMetricGroup.values) {
        if (group.name == item) {
          result.add(group);
          break;
        }
      }
    }
    return result;
  }
}
