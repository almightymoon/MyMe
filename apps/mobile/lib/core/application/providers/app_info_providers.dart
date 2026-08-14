import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// App version string from [PackageInfo], with a stable fallback for tests.
final appVersionProvider = FutureProvider<String>((ref) async {
  try {
    final info = await PackageInfo.fromPlatform();
    final version = info.version.trim();
    if (version.isEmpty) return '1.0.0';
    return version;
  } catch (_) {
    return '1.0.0';
  }
});
