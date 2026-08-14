import 'data_module_id.dart';

/// Declares what a module can do for export / deletion / transfer.
class DataModuleDescriptor {
  const DataModuleDescriptor({
    required this.id,
    required this.title,
    required this.summary,
    this.rawExport = false,
    this.summaryExport = false,
    this.localRecordDeletion = false,
    this.localCacheClear = false,
    this.backendDeletion = false,
    this.platformDeletion = false,
    this.deviceEventDeletion = false,
    this.aiTransfer = false,
    this.backendTransfer = false,
    this.notes = const [],
  });

  final DataModuleId id;
  final String title;
  final String summary;
  final bool rawExport;
  final bool summaryExport;
  final bool localRecordDeletion;
  final bool localCacheClear;
  final bool backendDeletion;
  final bool platformDeletion;
  final bool deviceEventDeletion;
  final bool aiTransfer;
  final bool backendTransfer;
  final List<String> notes;

  bool supports(DataActionType action) => switch (action) {
    DataActionType.rawExport => rawExport,
    DataActionType.summaryExport => summaryExport,
    DataActionType.localRecordDeletion => localRecordDeletion,
    DataActionType.localCacheClear => localCacheClear,
    DataActionType.backendDeletion => backendDeletion,
    DataActionType.platformDeletion => platformDeletion,
    DataActionType.deviceEventDeletion => deviceEventDeletion,
    DataActionType.aiTransfer => aiTransfer,
    DataActionType.backendTransfer => backendTransfer,
  };
}
