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
import '../../domain/repositories/trust_content_repository.dart';
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
  return const PrivacyDataCatalogService();
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

final localDataExportServiceProvider = Provider<LocalDataExportService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MemyLocalDataExportService(
    goalRepository: ref.watch(goalRepositoryProvider),
    financeRepository: ref.watch(financeRepositoryProvider),
    habitRepository: ref.watch(habitRepositoryProvider),
    calendarRepository: ref.watch(calendarRepositoryProvider),
    healthRepository: ref.watch(healthRepositoryProvider),
    preferencesReader: () async => AppearancePreferences.exportMap(prefs),
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
        return report.toJson();
      } catch (_) {
        return null;
      }
    },
  );
});

/// Theme mode preference (system / light). Dark is stored but falls back to
/// system until a full dark theme ships.
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
    // Only persist system/light as first-class; dark maps to system for now.
    final effective = mode == ThemeMode.dark ? ThemeMode.system : mode;
    await AppearancePreferences.writeThemeMode(_prefs, effective);
    state = effective;
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
    'goalsDataSource': EnvironmentConfig.goalsDataSource.name,
    'financeDataSource': EnvironmentConfig.financeDataSource.name,
    'habitsDataSource': EnvironmentConfig.habitsDataSource.name,
    'calendarDataSource': EnvironmentConfig.calendarDataSource.name,
    'healthDataSource': EnvironmentConfig.healthDataSource.name,
  };
}
