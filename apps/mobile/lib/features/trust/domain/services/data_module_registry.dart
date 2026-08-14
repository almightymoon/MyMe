import '../../../../core/config/environment_config.dart';
import '../entities/data_module_capability.dart';
import '../entities/data_module_id.dart';

/// Built-in capability declarations that match real repository behavior.
class DataModuleRegistry {
  const DataModuleRegistry(this.descriptors);

  final List<DataModuleDescriptor> descriptors;

  DataModuleDescriptor? descriptorFor(DataModuleId id) {
    for (final d in descriptors) {
      if (d.id == id) return d;
    }
    return null;
  }

  /// Capabilities for the current [EnvironmentConfig] data-source modes.
  factory DataModuleRegistry.builtIn([EnvironmentConfig? _]) {
    final goalsUsesApi =
        EnvironmentConfig.goalsDataSource == GoalsDataSource.api;

    return DataModuleRegistry([
      DataModuleDescriptor(
        id: DataModuleId.goals,
        title: 'Goals',
        summary: goalsUsesApi
            ? 'Goals sync with the MeMy API when GOALS_DATA_SOURCE=api; '
                  'a local cache is kept on this device. Local wipe clears '
                  'the cache only — backend Goals remain.'
            : 'Goals are stored on this device only (SharedPreferences).',
        rawExport: true,
        summaryExport: true,
        localRecordDeletion: !goalsUsesApi,
        localCacheClear: goalsUsesApi,
        backendDeletion: false,
        backendTransfer: goalsUsesApi,
        aiTransfer: false,
        notes: [
          if (goalsUsesApi)
            'Local data wipe clears the on-device Goals cache only. '
                'Backend Goals are not deleted.',
          'AI Coach does not receive goal payloads in this build.',
        ],
      ),
      const DataModuleDescriptor(
        id: DataModuleId.finance,
        title: 'Finance',
        summary:
            'Manual transactions, categories, monthly budgets, and money '
            'owed stay on this device. No MeMy backend sync and no AI transfer.',
        notes: [
          'Export includes transactions, categories, budgets, and money-owed '
              'entries as minor-unit strings. No formatted money labels.',
          'Local deletion clears transactions, budgets, and money owed and '
              'restores built-in categories. Demo transactions are not reseeded.',
        ],
        rawExport: true,
        summaryExport: true,
        localRecordDeletion: true,
        localCacheClear: false,
        backendDeletion: false,
        backendTransfer: false,
        aiTransfer: false,
      ),
      const DataModuleDescriptor(
        id: DataModuleId.wardrobe,
        title: 'Wardrobe',
        summary:
            'Items, outfits, plans, wear history, and app-private photos '
            'stay on this device. No backend or AI transfer.',
        rawExport: true,
        summaryExport: true,
        localRecordDeletion: true,
        localCacheClear: false,
        backendDeletion: false,
        backendTransfer: false,
        aiTransfer: false,
        notes: [
          'Export includes metadata only. Wardrobe image files are not '
              'included in this export.',
          'Local deletion removes metadata and image files on this device.',
        ],
      ),
      const DataModuleDescriptor(
        id: DataModuleId.habits,
        title: 'Habits',
        summary:
            'Habits and check-ins are stored on this device only. '
            'No MeMy backend sync and no AI transfer.',
        rawExport: true,
        summaryExport: true,
        localRecordDeletion: true,
        localCacheClear: false,
        backendDeletion: false,
        backendTransfer: false,
        aiTransfer: false,
      ),
      const DataModuleDescriptor(
        id: DataModuleId.calendar,
        title: 'Calendar',
        summary:
            'MeMy keeps a local Drift cache of events and sync metadata. '
            'Device calendars remain the external source; MeMy does not '
            'upload calendar content to a MeMy backend or AI provider.',
        rawExport: false,
        summaryExport: true,
        localRecordDeletion: true,
        localCacheClear: true,
        backendDeletion: false,
        platformDeletion: false,
        deviceEventDeletion: false,
        backendTransfer: false,
        aiTransfer: false,
        notes: [
          'Export defaults to MeMy-owned events / config summary only.',
          'Wipe clears MeMy local cache; it does not delete external '
              'device calendar events.',
          'Device event deletion is a separate Calendar path and is never '
              'part of the global local wipe.',
        ],
      ),
      const DataModuleDescriptor(
        id: DataModuleId.health,
        title: 'Health',
        summary:
            'Platform Health (HealthKit / Health Connect) is the source of '
            'truth. MeMy stores connection/permission configuration locally '
            'and keeps daily summaries in memory only. Health values are '
            'never sent to MeMy API or AI.',
        rawExport: false,
        summaryExport: true,
        localRecordDeletion: false,
        localCacheClear: true,
        backendDeletion: false,
        platformDeletion: false,
        deviceEventDeletion: false,
        backendTransfer: false,
        aiTransfer: false,
        notes: [
          'Export includes connection configuration summary only — never '
              'raw sample values.',
          'Disconnect / wipe clears MeMy prefs and in-memory summaries; '
              'platform Health data is untouched.',
        ],
      ),
      const DataModuleDescriptor(
        id: DataModuleId.profile,
        title: 'Profile',
        summary:
            'Display name and chosen avatar stay on this device. No photo '
            'upload and no MeMy account.',
        notes: [
          'Export includes display name and avatar id only.',
          'Avatar is picked from a local catalog — never a camera or gallery photo.',
        ],
        rawExport: false,
        summaryExport: true,
        localRecordDeletion: false,
        localCacheClear: false,
        backendDeletion: false,
        backendTransfer: false,
        aiTransfer: false,
      ),
      const DataModuleDescriptor(
        id: DataModuleId.preferences,
        title: 'Preferences',
        summary:
            'Appearance and reduce-motion preferences when stored locally.',
        rawExport: true,
        summaryExport: true,
        localRecordDeletion: true,
        localCacheClear: false,
        backendDeletion: false,
        backendTransfer: false,
        aiTransfer: false,
      ),
      const DataModuleDescriptor(
        id: DataModuleId.diagnostics,
        title: 'Diagnostics',
        summary:
            'Operational integration counts and status codes only — never '
            'event titles, health values, or account secrets.',
        rawExport: false,
        summaryExport: true,
        localRecordDeletion: false,
        localCacheClear: false,
        backendDeletion: false,
        backendTransfer: false,
        aiTransfer: false,
      ),
    ]);
  }
}
