import '../entities/export_request.dart';

/// Exports selected MeMy-owned modules to a versioned JSON file.
abstract class LocalDataExportService {
  Future<ExportResult> export(ExportRequest request);

  /// Builds the in-memory JSON map without writing a file (tests).
  Future<Map<String, Object?>> buildExportMap(ExportRequest request);
}
