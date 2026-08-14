import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Tracks export temp files and cleans stale ones on startup.
///
/// Filenames never include user PII — only a UTC timestamp suffix.
class ExportFileLifecycleService {
  ExportFileLifecycleService({
    this.tempDirectoryOverride,
    this.clock,
    this.maxAge = const Duration(hours: 24),
  });

  /// Tests can inject a temp directory to avoid path_provider plugins.
  final Future<Directory> Function()? tempDirectoryOverride;

  final DateTime Function()? clock;
  final Duration maxAge;

  static const String filePrefix = 'memy-data-export-';
  static const String legacyPrefix = 'memy-export-';
  static const String fileSuffix = '.json';

  final Set<String> _trackedPaths = {};

  /// Builds `memy-data-export-<utcTimestamp>.json` (no user PII).
  static String fileNameFor(DateTime utc) {
    final stamp = utc.toUtc().toIso8601String().replaceAll(':', '');
    return '$filePrefix$stamp$fileSuffix';
  }

  void track(String path) {
    _trackedPaths.add(path);
  }

  void untrack(String path) {
    _trackedPaths.remove(path);
  }

  Set<String> get trackedPaths => Set.unmodifiable(_trackedPaths);

  Future<Directory> resolveTempDirectory() async {
    if (tempDirectoryOverride != null) {
      return tempDirectoryOverride!();
    }
    return getTemporaryDirectory();
  }

  /// Deletes `memy-data-export-*.json` / `memy-export-*.json` older than
  /// [maxAge], or all matching files when [deleteAll] is true.
  Future<int> cleanupStaleExports({bool deleteAll = false}) async {
    final dir = await resolveTempDirectory();
    if (!await dir.exists()) return 0;

    final now = (clock?.call() ?? DateTime.now()).toUtc();
    var deleted = 0;

    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (!_isExportFileName(name)) continue;

      var shouldDelete = deleteAll;
      if (!shouldDelete) {
        try {
          final modified = await entity.lastModified();
          shouldDelete = now.difference(modified.toUtc()) > maxAge;
        } catch (_) {
          shouldDelete = true;
        }
      }

      if (!shouldDelete) continue;

      try {
        await entity.delete();
        _trackedPaths.remove(entity.path);
        deleted++;
      } catch (_) {
        // Best-effort cleanup; ignore individual file failures.
      }
    }

    return deleted;
  }

  static bool _isExportFileName(String name) {
    return (name.startsWith(filePrefix) || name.startsWith(legacyPrefix)) &&
        name.endsWith(fileSuffix);
  }
}
