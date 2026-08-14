import 'dart:convert';
import 'dart:io';

import '../../data/gateways/fake_platform_health_gateway.dart';
import '../../domain/entities/health_connection_config.dart';
import '../../domain/gateways/platform_health_gateway.dart';
import 'health_repository_support.dart';

/// Shared primary/backup storage keys for Health connection prefs.
abstract final class HealthConnectionStorageKeys {
  static const String primary = 'memy_health_connection_primary';
  static const String backup = 'memy_health_connection_backup';
  static const String legacy = 'memy_health_connection_v1';
}

/// Validates that [json] is a safe connection config (no sample values).
bool isValidHealthConnectionJson(Map<String, dynamic> json) {
  if (json.containsKey('samples') ||
      json.containsKey('workouts') ||
      json.containsKey('rawData')) {
    return false;
  }
  final permission = json['permissionState'];
  if (permission is Map &&
      (permission.containsKey('samples') || permission.containsKey('values'))) {
    return false;
  }
  return true;
}

HealthConnectionConfig? parseHealthConnectionConfig(
  String raw, {
  String? platform,
}) {
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    final map = Map<String, dynamic>.from(decoded);
    if (!isValidHealthConnectionJson(map)) return null;
    return HealthConnectionConfig.fromJson(map, platform: platform);
  } catch (_) {
    return null;
  }
}

String currentHealthPlatform({required bool isAndroid, required bool isIOS}) {
  if (isIOS) return 'ios';
  if (isAndroid) return 'android';
  return 'unknown';
}

bool shouldRecheckPermissionsOnRefresh(PlatformHealthGateway gateway) {
  if (!gatewaySupportsPermissionRecheck(gateway)) return false;
  if (gateway is FakePlatformHealthGateway) return true;
  return Platform.isAndroid;
}
