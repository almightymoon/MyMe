import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../domain/auth_api.dart';
import 'account_local_store.dart';

Future<AuthDeviceInfo> loadAuthDeviceInfo(SharedPreferences prefs) async {
  var clientId = prefs.getString(DeviceIdStore.key);
  if (clientId == null || clientId.length < 8) {
    clientId = const Uuid().v4();
    await prefs.setString(DeviceIdStore.key, clientId);
  }
  var appVersion = '1.0.0';
  try {
    final info = await PackageInfo.fromPlatform();
    appVersion = info.version;
  } on Object {
    appVersion = '1.0.0';
  }
  final platform = defaultTargetPlatform.name.toLowerCase();
  return AuthDeviceInfo(
    clientGeneratedDeviceId: clientId,
    platform: platform,
    appVersion: appVersion,
    deviceLabel: '$platform device',
  );
}
