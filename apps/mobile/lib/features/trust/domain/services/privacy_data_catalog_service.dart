import '../../../../core/config/environment_config.dart';
import '../entities/data_catalog.dart';

/// Hardcoded privacy catalog reflecting actual MeMy mobile behavior.
class PrivacyDataCatalogService {
  const PrivacyDataCatalogService();

  List<DataCatalogEntry> entries() {
    final goalsUsesApi =
        EnvironmentConfig.goalsDataSource == GoalsDataSource.api;

    return [
      DataCatalogEntry(
        module: DataModule.goals,
        title: 'Goals',
        summary: goalsUsesApi
            ? 'Goals sync with the MeMy API when GOALS_DATA_SOURCE=api; '
                  'a local cache is kept on this device.'
            : 'Goals are stored on this device only (SharedPreferences).',
        storageLocations: [
          DataStorageLocation.localDevice,
          if (goalsUsesApi) DataStorageLocation.memyBackend,
        ],
        sensitivity: DataSensitivity.personal,
        backendTransfer: goalsUsesApi,
        aiTransfer: false,
        exportCapability: DataExportCapability.supported,
        deletionCapability: DataDeletionCapability.supported,
        notes: const ['AI Coach does not receive goal payloads in this build.'],
      ),
      const DataCatalogEntry(
        module: DataModule.finance,
        title: 'Finance',
        summary:
            'Manual transactions and categories stay on this device. '
            'No MeMy backend sync and no AI transfer.',
        storageLocations: [DataStorageLocation.localDevice],
        sensitivity: DataSensitivity.financial,
        backendTransfer: false,
        aiTransfer: false,
        exportCapability: DataExportCapability.supported,
        deletionCapability: DataDeletionCapability.supported,
      ),
      const DataCatalogEntry(
        module: DataModule.habits,
        title: 'Habits',
        summary:
            'Habits and check-ins are stored on this device only. '
            'No MeMy backend sync and no AI transfer.',
        storageLocations: [DataStorageLocation.localDevice],
        sensitivity: DataSensitivity.personal,
        backendTransfer: false,
        aiTransfer: false,
        exportCapability: DataExportCapability.supported,
        deletionCapability: DataDeletionCapability.supported,
      ),
      const DataCatalogEntry(
        module: DataModule.calendar,
        title: 'Calendar',
        summary:
            'MeMy keeps a local Drift cache of events and sync metadata. '
            'Device calendars remain the external source; MeMy does not '
            'upload calendar content to a MeMy backend or AI provider.',
        storageLocations: [
          DataStorageLocation.localDevice,
          DataStorageLocation.deviceCalendar,
        ],
        sensitivity: DataSensitivity.schedule,
        backendTransfer: false,
        aiTransfer: false,
        exportCapability: DataExportCapability.supported,
        deletionCapability: DataDeletionCapability.supported,
        notes: [
          'Export defaults to MeMy-owned events / config summary only.',
          'Wipe clears MeMy local cache; it does not delete external '
              'device calendar events.',
        ],
      ),
      const DataCatalogEntry(
        module: DataModule.health,
        title: 'Health',
        summary:
            'Platform Health (HealthKit / Health Connect) is the source of '
            'truth. MeMy stores connection/permission configuration locally '
            'and keeps daily summaries in memory only. Health values are '
            'never sent to MeMy API or AI.',
        storageLocations: [
          DataStorageLocation.healthPlatform,
          DataStorageLocation.localDevice,
          DataStorageLocation.memoryOnly,
        ],
        sensitivity: DataSensitivity.wellness,
        backendTransfer: false,
        aiTransfer: false,
        exportCapability: DataExportCapability.summaryOnly,
        deletionCapability: DataDeletionCapability.disconnectOnly,
        notes: [
          'Export includes connection configuration summary only — never '
              'raw sample values.',
          'Disconnect / wipe clears MeMy prefs and in-memory summaries; '
              'platform Health data is untouched.',
        ],
      ),
      const DataCatalogEntry(
        module: DataModule.profile,
        title: 'Profile',
        summary:
            'Demo profile fields used in this build are local / seed data.',
        storageLocations: [DataStorageLocation.localDevice],
        sensitivity: DataSensitivity.personal,
        backendTransfer: false,
        aiTransfer: false,
        exportCapability: DataExportCapability.summaryOnly,
        deletionCapability: DataDeletionCapability.planned,
      ),
      const DataCatalogEntry(
        module: DataModule.preferences,
        title: 'Preferences',
        summary:
            'Appearance and reduce-motion preferences when stored locally.',
        storageLocations: [DataStorageLocation.localDevice],
        sensitivity: DataSensitivity.operational,
        backendTransfer: false,
        aiTransfer: false,
        exportCapability: DataExportCapability.supported,
        deletionCapability: DataDeletionCapability.supported,
      ),
      const DataCatalogEntry(
        module: DataModule.diagnostics,
        title: 'Diagnostics',
        summary:
            'Operational integration counts and status codes only — never '
            'event titles, health values, or account secrets.',
        storageLocations: [DataStorageLocation.localDevice],
        sensitivity: DataSensitivity.operational,
        backendTransfer: false,
        aiTransfer: false,
        exportCapability: DataExportCapability.summaryOnly,
        deletionCapability: DataDeletionCapability.notSupported,
      ),
    ];
  }

  DataCatalogEntry? entryFor(DataModule module) {
    for (final entry in entries()) {
      if (entry.module == module) return entry;
    }
    return null;
  }
}
