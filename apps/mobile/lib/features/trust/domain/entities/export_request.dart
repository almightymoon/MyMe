import 'data_catalog.dart';

class ExportRequest {
  const ExportRequest({
    required this.modules,
    this.includeMeMyOwnedCalendarEvents = false,
    this.includeHealthConnectionSummary = true,
  });

  final Set<DataModule> modules;

  /// When true and calendar is selected, include MeMy-authored local events
  /// (never raw external device calendar payloads by default).
  final bool includeMeMyOwnedCalendarEvents;

  final bool includeHealthConnectionSummary;
}

class ExportResult {
  const ExportResult({
    required this.filePath,
    required this.modules,
    required this.generatedAt,
    this.warnings = const [],
    this.byteLength,
  });

  final String filePath;
  final Set<DataModule> modules;
  final DateTime generatedAt;
  final List<String> warnings;
  final int? byteLength;
}

/// Safe export failure — UI must show [userSafeMessage], never raw `$e`.
class ExportFailure implements Exception {
  const ExportFailure({
    required this.code,
    this.userSafeMessage = 'Export failed. Please try again.',
  });

  final String code;
  final String userSafeMessage;

  @override
  String toString() => userSafeMessage;
}
