import '../entities/health_metric_type.dart';
import '../entities/health_permission_state.dart';

/// Platform-aware migration of legacy v1 permission JSON (grantedGroups /
/// deniedGroups) into v2 [HealthPermissionDisposition] values.
///
/// iOS legacy grants are never mapped to [HealthPermissionDisposition.grantedVerified]
/// because HealthKit does not disclose READ grants. Android grants require
/// verification via [verifyGroup] when possible.
class HealthPermissionMigrationService {
  const HealthPermissionMigrationService();

  /// Migrates schema-v1 [json] using [platform] (`ios`, `android`, or other).
  ///
  /// When [verifyGroup] is provided (typically on Android refresh), granted
  /// groups are upgraded to [HealthPermissionDisposition.grantedVerified] or
  /// downgraded to [HealthPermissionDisposition.deniedVerified] /
  /// [HealthPermissionDisposition.needsSystemSettings].
  HealthPermissionState migrateLegacy({
    required Map<String, dynamic> json,
    required String platform,
    Future<bool?> Function(HealthMetricGroup group)? verifyGroup,
  }) {
    final granted = _parseGroups(json['grantedGroups']);
    final denied = _parseGroups(json['deniedGroups']);
    final migrated = <HealthMetricGroup, HealthPermissionDisposition>{};

    for (final g in denied) {
      migrated[g] = HealthPermissionDisposition.deniedVerified;
    }

    final normalizedPlatform = platform.toLowerCase();
    for (final g in granted) {
      migrated[g] = _legacyGrantedDisposition(normalizedPlatform);
    }

    return HealthPermissionState(
      dispositions: migrated,
      schemaVersion: HealthPermissionState.currentSchemaVersion,
    );
  }

  /// Async variant that verifies Android legacy grants when [verifyGroup] is
  /// available.
  Future<HealthPermissionState> migrateLegacyAsync({
    required Map<String, dynamic> json,
    required String platform,
    Future<bool?> Function(HealthMetricGroup group)? verifyGroup,
  }) async {
    final granted = _parseGroups(json['grantedGroups']);
    final denied = _parseGroups(json['deniedGroups']);
    final migrated = <HealthMetricGroup, HealthPermissionDisposition>{};

    for (final g in denied) {
      migrated[g] = HealthPermissionDisposition.deniedVerified;
    }

    final normalizedPlatform = platform.toLowerCase();
    if (normalizedPlatform == 'android' && verifyGroup != null) {
      for (final g in granted) {
        final verified = await verifyGroup(g);
        migrated[g] = _androidVerifiedDisposition(verified);
      }
    } else {
      for (final g in granted) {
        migrated[g] = _legacyGrantedDisposition(normalizedPlatform);
      }
    }

    return HealthPermissionState(
      dispositions: migrated,
      schemaVersion: HealthPermissionState.currentSchemaVersion,
    );
  }

  HealthPermissionDisposition _legacyGrantedDisposition(String platform) {
    return switch (platform) {
      'ios' => HealthPermissionDisposition.requestCompletedUnverified,
      'android' =>
        // Cannot verify synchronously — refresh will upgrade via hasPermissions.
        HealthPermissionDisposition.requestCompletedUnverified,
      _ => HealthPermissionDisposition.requestCompletedUnverified,
    };
  }

  HealthPermissionDisposition _androidVerifiedDisposition(bool? verified) {
    if (verified == true) {
      return HealthPermissionDisposition.grantedVerified;
    }
    if (verified == false) {
      return HealthPermissionDisposition.deniedVerified;
    }
    return HealthPermissionDisposition.needsSystemSettings;
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
}
