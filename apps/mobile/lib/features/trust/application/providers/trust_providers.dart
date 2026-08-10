import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/environment_config.dart';
import '../../../calendar/application/providers/calendar_providers.dart';
import '../../../finance/application/providers/finance_providers.dart';
import '../../../goals/application/providers/goal_providers.dart';
import '../../../habits/application/providers/habit_providers.dart';
import '../../../health/application/providers/health_providers.dart';
import '../../../settings/application/providers/diagnostics_providers.dart';
import '../../data/repositories/asset_trust_content_repository.dart';
import '../../data/repositories/memy_local_data_deletion_coordinator.dart';
import '../../data/repositories/memy_local_data_export_service.dart';
import '../../domain/entities/changelog_entry.dart';
import '../../domain/entities/data_catalog.dart';
import '../../domain/entities/support_article.dart';
import '../../domain/entities/trust_document.dart';
import '../../domain/entities/support_diagnostics_report.dart';
import '../../domain/repositories/trust_content_repository.dart';
import '../../domain/services/data_module_registry.dart';
import '../../domain/services/export_file_lifecycle_service.dart';
import '../../domain/services/local_data_deletion_coordinator.dart';
import '../../domain/services/local_data_export_service.dart';
import '../../domain/services/privacy_data_catalog_service.dart';
import '../../domain/services/support_report_builder.dart';
import '../../presentation/appearance/appearance_preferences.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) {
  return PackageInfo.fromPlatform();
});

final appVersionLabelProvider = Provider<AsyncValue<String>>((ref) {
  return ref.watch(packageInfoProvider).whenData((info) {
    return 'v${info.version} (${info.buildNumber})';
  });
});

final privacyDataCatalogServiceProvider = Provider<PrivacyDataCatalogService>((
  ref,
) {
  return PrivacyDataCatalogService(DataModuleRegistry.builtIn());
});

final dataCatalogEntriesProvider = Provider<List<DataCatalogEntry>>((ref) {
  return ref.watch(privacyDataCatalogServiceProvider).entries();
});

final trustContentRepositoryProvider = Provider<TrustContentRepository>((ref) {
  return AssetTrustContentRepository();
});

final trustDocumentProvider =
    FutureProvider.family<TrustDocument, TrustDocumentType>((ref, type) {
      return ref.watch(trustContentRepositoryProvider).getDocument(type);
    });

final supportArticlesProvider = FutureProvider<List<SupportArticle>>((ref) {
  return ref.watch(trustContentRepositoryProvider).listSupportArticles();
});

final supportArticleSearchProvider =
    FutureProvider.family<List<SupportArticle>, String>((ref, query) {
      return ref.watch(trustContentRepositoryProvider).searchArticles(query);
    });

final changelogProvider = FutureProvider<List<ChangelogEntry>>((ref) {
  return ref.watch(trustContentRepositoryProvider).getChangelog();
});

final exportFileLifecycleServiceProvider = Provider<ExportFileLifecycleService>(
  (ref) {
    return ExportFileLifecycleService();
  },
);

/// Runs once after providers exist — deletes stale export temp files.
final exportTempCleanupProvider = FutureProvider<int>((ref) async {
  return ref.watch(exportFileLifecycleServiceProvider).cleanupStaleExports();
});

final localDataExportServiceProvider = Provider<LocalDataExportService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final lifecycle = ref.watch(exportFileLifecycleServiceProvider);
  final packageInfo = ref.watch(packageInfoProvider);
  return MemyLocalDataExportService(
    goalRepository: ref.watch(goalRepositoryProvider),
    financeRepository: ref.watch(financeRepositoryProvider),
    habitRepository: ref.watch(habitRepositoryProvider),
    calendarRepository: ref.watch(calendarRepositoryProvider),
    healthRepository: ref.watch(healthRepositoryProvider),
    preferencesReader: () async => AppearancePreferences.exportMap(prefs),
    appVersionProvider: () => packageInfo.asData?.value.version ?? 'unknown',
    buildNumberProvider: () =>
        packageInfo.asData?.value.buildNumber ?? 'unknown',
    dataSourceModesProvider: environmentDataSourceLabels,
    fileLifecycle: lifecycle,
  );
});

final localDataDeletionCoordinatorProvider =
    Provider<LocalDataDeletionCoordinator>((ref) {
      return MemyLocalDataDeletionCoordinator(
        goalRepository: ref.watch(goalRepositoryProvider),
        financeRepository: ref.watch(financeRepositoryProvider),
        habitRepository: ref.watch(habitRepositoryProvider),
        calendarRepository: ref.watch(calendarRepositoryProvider),
        healthRepository: ref.watch(healthRepositoryProvider),
        prefs: ref.watch(sharedPreferencesProvider),
      );
    });

final supportReportBuilderProvider = Provider<SupportReportBuilder>((ref) {
  return SupportReportBuilder(
    diagnosticsProvider: () async {
      try {
        final report = await ref.read(integrationDiagnosticsProvider.future);
        return SupportDiagnosticsReport.fromIntegration(report: report);
      } catch (_) {
        return null;
      }
    },
  );
});

/// Theme mode preference (system / light / dark).
final themeModePreferenceProvider =
    StateNotifierProvider<ThemeModePreferenceController, ThemeMode>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ThemeModePreferenceController(prefs);
    });

class ThemeModePreferenceController extends StateNotifier<ThemeMode> {
  ThemeModePreferenceController(this._prefs)
    : super(AppearancePreferences.readThemeMode(_prefs));

  final SharedPreferences _prefs;

  Future<void> setMode(ThemeMode mode) async {
    await AppearancePreferences.writeThemeMode(_prefs, mode);
    state = mode;
  }
}

final reduceMotionPreferenceProvider =
    StateNotifierProvider<ReduceMotionPreferenceController, bool>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ReduceMotionPreferenceController(prefs);
    });

class ReduceMotionPreferenceController extends StateNotifier<bool> {
  ReduceMotionPreferenceController(this._prefs)
    : super(AppearancePreferences.readReduceMotion(_prefs));

  final SharedPreferences _prefs;

  Future<void> setEnabled(bool value) async {
    await AppearancePreferences.writeReduceMotion(_prefs, value);
    state = value;
  }
}

Map<String, String> environmentDataSourceLabels() {
  return {
    'goals': EnvironmentConfig.goalsDataSource.name,
    'finance': EnvironmentConfig.financeDataSource.name,
    'habits': EnvironmentConfig.habitsDataSource.name,
    'calendar': EnvironmentConfig.calendarDataSource.name,
    'health': EnvironmentConfig.healthDataSource.name,
  };
}
