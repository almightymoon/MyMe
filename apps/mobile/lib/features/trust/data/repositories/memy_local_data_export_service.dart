import 'dart:convert';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher;

import 'package:path/path.dart' as p;

import '../../../../core/config/environment_config.dart';
import '../../../calendar/data/repositories/fake_calendar_repository.dart';
import '../../../calendar/data/repositories/local_calendar_repository.dart';
import '../../../calendar/domain/entities/calendar_event_origin.dart';
import '../../../calendar/domain/repositories/calendar_repository.dart';
import '../../../finance/data/repositories/fake_finance_repository.dart';
import '../../../finance/data/repositories/local_finance_repository.dart';
import '../../../finance/domain/repositories/finance_repository.dart';
import '../../../goals/data/repositories/api_goal_repository.dart';
import '../../../goals/data/repositories/fake_goal_repository.dart';
import '../../../goals/data/repositories/local_goal_repository.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../habits/data/repositories/fake_habit_repository.dart';
import '../../../habits/data/repositories/local_habit_repository.dart';
import '../../../habits/domain/repositories/habit_repository.dart';
import '../../../wardrobe/domain/repositories/wardrobe_repository.dart';
import '../../../health/domain/repositories/health_repository.dart';
import '../../domain/entities/data_catalog.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/services/export_file_lifecycle_service.dart';
import '../../domain/services/local_data_export_service.dart';

/// Exports MeMy-owned module data to a versioned JSON file (exportVersion 2).
///
/// Excludes: raw health sample values, external calendar payloads by default,
/// API tokens, passwords, and other secrets.
class MemyLocalDataExportService implements LocalDataExportService {
  MemyLocalDataExportService({
    this.goalRepository,
    this.financeRepository,
    this.habitRepository,
    this.wardrobeRepository,
    this.calendarRepository,
    this.healthRepository,
    this.preferencesReader,
    this.profileReader,
    this.tempDirectoryOverride,
    this.clock,
    this.appVersionProvider,
    this.buildNumberProvider,
    this.environment = 'demo',
    this.localeProvider,
    this.timezoneProvider,
    this.dataSourceModesProvider,
    this.fileLifecycle,
  });

  static const int exportSchemaVersion = 2;

  final GoalRepository? goalRepository;
  final FinanceRepository? financeRepository;
  final HabitRepository? habitRepository;
  final WardrobeRepository? wardrobeRepository;
  final CalendarRepository? calendarRepository;
  final HealthRepository? healthRepository;

  /// Optional map of non-secret preference keys → values.
  final Future<Map<String, Object?>> Function()? preferencesReader;

  /// Display name and avatar id only — never a photo.
  final Future<Map<String, Object?>> Function()? profileReader;

  /// Tests can inject a temp directory to avoid path_provider plugins.
  final Future<Directory> Function()? tempDirectoryOverride;

  final DateTime Function()? clock;
  final String Function()? appVersionProvider;
  final String Function()? buildNumberProvider;
  final String environment;
  final String Function()? localeProvider;
  final String Function()? timezoneProvider;
  final Map<String, String> Function()? dataSourceModesProvider;
  final ExportFileLifecycleService? fileLifecycle;

  @override
  Future<Map<String, Object?>> buildExportMap(ExportRequest request) async {
    try {
      final generatedAt = (clock?.call() ?? DateTime.now()).toUtc();
      final modules = <String, Object?>{};
      final recordCounts = <String, int>{};
      final warnings = <String>[];
      final selectedModules = request.modules.map((m) => m.name).toList()
        ..sort();

      for (final module in request.modules) {
        switch (module) {
          case DataModule.goals:
            modules['goals'] = await _exportGoals(warnings, recordCounts);
          case DataModule.finance:
            modules['finance'] = await _exportFinance(warnings, recordCounts);
          case DataModule.habits:
            modules['habits'] = await _exportHabits(warnings, recordCounts);
          case DataModule.wardrobe:
            modules['wardrobe'] = await _exportWardrobe(warnings, recordCounts);
          case DataModule.calendar:
            modules['calendar'] = await _exportCalendar(
              request,
              warnings,
              recordCounts,
            );
          case DataModule.health:
            modules['health'] = await _exportHealth(
              request,
              warnings,
              recordCounts,
            );
          case DataModule.preferences:
            modules['preferences'] = await _exportPreferences(
              warnings,
              recordCounts,
            );
          case DataModule.profile:
            modules['profile'] = await _exportProfile(recordCounts);
          case DataModule.diagnostics:
            modules['diagnostics'] = {
              'note':
                  'Use Help → Report a problem for allowlisted diagnostics.',
            };
            recordCounts['diagnostics'] = 0;
        }
      }

      final dataSourceModes =
          dataSourceModesProvider?.call() ??
          <String, String>{
            'goals': EnvironmentConfig.goalsDataSource.name,
            'finance': EnvironmentConfig.financeDataSource.name,
            'habits': EnvironmentConfig.habitsDataSource.name,
            'calendar': EnvironmentConfig.calendarDataSource.name,
            'health': EnvironmentConfig.healthDataSource.name,
          };

      return {
        'exportVersion': exportSchemaVersion,
        'app': {
          'name': 'MeMy',
          'version': appVersionProvider?.call() ?? 'unknown',
          'buildNumber': buildNumberProvider?.call() ?? 'unknown',
          'environment': environment,
        },
        'createdAtUtc': generatedAt.toIso8601String(),
        'locale':
            localeProvider?.call() ??
            PlatformDispatcher.instance.locale.toString(),
        'timezone': timezoneProvider?.call() ?? DateTime.now().timeZoneName,
        'dataSourceModes': dataSourceModes,
        'selectedModules': selectedModules,
        'recordCounts': recordCounts,
        'modules': modules,
        'warnings': warnings,
      };
    } on ExportFailure {
      rethrow;
    } catch (_) {
      throw const ExportFailure(code: 'export_build_failed');
    }
  }

  @override
  Future<ExportResult> export(ExportRequest request) async {
    try {
      final map = await buildExportMap(request);
      final generatedAt = DateTime.parse(map['createdAtUtc']! as String);
      final warnings =
          (map['warnings'] as List?)?.map((e) => e.toString()).toList() ??
          const <String>[];

      final lifecycle = fileLifecycle;
      final dir = tempDirectoryOverride != null
          ? await tempDirectoryOverride!()
          : lifecycle != null
          ? await lifecycle.resolveTempDirectory()
          : await ExportFileLifecycleService().resolveTempDirectory();

      final fileName = ExportFileLifecycleService.fileNameFor(generatedAt);
      final file = File(p.join(dir.path, fileName));
      final encoded = const JsonEncoder.withIndent('  ').convert(map);
      await file.writeAsString(encoded, flush: true);
      lifecycle?.track(file.path);

      return ExportResult(
        filePath: file.path,
        modules: request.modules,
        generatedAt: generatedAt,
        warnings: warnings,
        byteLength: encoded.length,
      );
    } on ExportFailure {
      rethrow;
    } catch (_) {
      throw const ExportFailure(code: 'export_write_failed');
    }
  }

  Future<Object?> _exportGoals(
    List<String> warnings,
    Map<String, int> recordCounts,
  ) async {
    final repo = goalRepository;
    if (repo == null) {
      warnings.add('Goals repository unavailable.');
      recordCounts['goals'] = 0;
      return null;
    }

    if (repo is ApiGoalRepository) {
      final goals = await repo.cache.getGoals();
      warnings.add('Cached snapshot, not a complete backend export');
      recordCounts['goals'] = goals.length;
      return {
        'count': goals.length,
        'source': 'localCache',
        'items': goals.map((g) => g.toJson()).toList(growable: false),
      };
    }

    final goals = await repo.getGoals();
    recordCounts['goals'] = goals.length;
    return {
      'count': goals.length,
      'items': goals.map((g) => g.toJson()).toList(growable: false),
    };
  }

  Future<Object?> _exportFinance(
    List<String> warnings,
    Map<String, int> recordCounts,
  ) async {
    final repo = financeRepository;
    if (repo == null) {
      warnings.add('Finance repository unavailable.');
      recordCounts['finance'] = 0;
      return null;
    }
    final txs = await repo.getTransactions();
    final cats = await repo.getCategories();
    final budgets = await repo.getBudgets();
    final positions = await repo.getMoneyPositions();
    recordCounts['finance'] =
        txs.length + cats.length + budgets.length + positions.length;
    return {
      'transactionCount': txs.length,
      'budgetCount': budgets.length,
      'moneyPositionCount': positions.length,
      'categories': cats.map((c) => c.toJson()).toList(growable: false),
      'transactions': txs.map((t) => t.toJson()).toList(growable: false),
      'budgets': budgets.map((b) => b.toJson()).toList(growable: false),
      'moneyPositions': positions
          .map((p) => p.toJson())
          .toList(growable: false),
    };
  }

  Future<Object?> _exportWardrobe(
    List<String> warnings,
    Map<String, int> recordCounts,
  ) async {
    final repo = wardrobeRepository;
    if (repo == null) {
      warnings.add('Wardrobe repository unavailable.');
      recordCounts['wardrobe'] = 0;
      return null;
    }
    final payload = await repo.exportLocalRecords();
    recordCounts['wardrobe'] = await repo.countExportableRecords();
    warnings.add('Wardrobe image files are not included in this export.');
    return payload;
  }

  Future<Object?> _exportHabits(
    List<String> warnings,
    Map<String, int> recordCounts,
  ) async {
    final repo = habitRepository;
    if (repo == null) {
      warnings.add('Habits repository unavailable.');
      recordCounts['habits'] = 0;
      return null;
    }
    final habits = await repo.getHabits();
    recordCounts['habits'] = habits.length;
    return {
      'count': habits.length,
      'items': habits.map((h) => h.toJson()).toList(growable: false),
    };
  }

  Future<Object?> _exportCalendar(
    ExportRequest request,
    List<String> warnings,
    Map<String, int> recordCounts,
  ) async {
    final repo = calendarRepository;
    if (repo == null) {
      warnings.add('Calendar repository unavailable.');
      recordCounts['calendar'] = 0;
      return null;
    }
    final config = await repo.getConfig();
    final configSummary = <String, Object?>{
      'readableCalendarCount': config.effectiveReadableCalendarIds.length,
      'hasWritableDestination': config.hasWritableDestination,
      'calendarSchemaVersion': config.calendarSchemaVersion,
      'syncPastWindowDays': config.syncPastWindowDays,
      'syncFutureWindowDays': config.syncFutureWindowDays,
      'connectionConfigured': config.isConnectionConfigured,
      // Never export raw calendar IDs as they can identify accounts.
    };

    Map<String, Object?>? eventsPayload;
    if (request.includeMeMyOwnedCalendarEvents) {
      final start = DateTime.utc(2000);
      final end = DateTime.utc(2100);
      final events = await repo.getEventsInRange(
        startUtc: start,
        endUtc: end,
        includeHidden: true,
      );
      final owned = events
          .where((e) => e.origin == CalendarEventOrigin.local)
          .toList(growable: false);
      recordCounts['calendar'] = owned.length;
      eventsPayload = {
        'count': owned.length,
        'items': owned.map((e) => e.toJson()).toList(growable: false),
      };
    } else {
      recordCounts['calendar'] = 0;
      warnings.add(
        'External calendar content excluded; enable MeMy-owned events '
        'to include local MeMy events.',
      );
    }

    return {'configSummary': configSummary, 'memyOwnedEvents': ?eventsPayload};
  }

  Future<Object?> _exportHealth(
    ExportRequest request,
    List<String> warnings,
    Map<String, int> recordCounts,
  ) async {
    final repo = healthRepository;
    if (repo == null) {
      warnings.add('Health repository unavailable.');
      recordCounts['health'] = 0;
      return null;
    }
    if (!request.includeHealthConnectionSummary) {
      warnings.add('Health connection summary skipped by request.');
      recordCounts['health'] = 0;
      return {'included': false};
    }
    final connection = await repo.getConnection();
    recordCounts['health'] = 1;
    // Connection summary only — never sample values.
    return {
      'connectionSummary': {
        'status': connection.status.name,
        'schemaVersion': connection.schemaVersion,
        'recoveryNeeded': connection.recoveryNeeded,
        'backupAvailable': connection.backupAvailable,
        'connectedAt': connection.connectedAt?.toUtc().toIso8601String(),
        'lastRefreshAt': connection.lastRefreshAt?.toUtc().toIso8601String(),
        'permissionDispositions': {
          for (final entry in connection.permissionState.dispositions.entries)
            entry.key.name: entry.value.name,
        },
      },
    };
  }

  Future<Object?> _exportProfile(Map<String, int> recordCounts) async {
    final reader = profileReader;
    if (reader == null) {
      recordCounts['profile'] = 0;
      return {'displayName': null, 'avatarId': null};
    }
    final profile = await reader();
    recordCounts['profile'] = profile.values.where((v) => v != null).length;
    return profile;
  }

  Future<Object?> _exportPreferences(
    List<String> warnings,
    Map<String, int> recordCounts,
  ) async {
    final reader = preferencesReader;
    if (reader == null) {
      warnings.add('Preferences reader unavailable.');
      recordCounts['preferences'] = 0;
      return const <String, Object?>{};
    }
    final prefs = await reader();
    recordCounts['preferences'] = prefs.length;
    return prefs;
  }
}

/// Helpers used by deletion/export provider wiring.
bool isClearableGoalRepository(Object? repo) =>
    repo is LocalGoalRepository || repo is FakeGoalRepository;

bool isClearableFinanceRepository(Object? repo) =>
    repo is LocalFinanceRepository || repo is FakeFinanceRepository;

bool isClearableHabitRepository(Object? repo) =>
    repo is LocalHabitRepository || repo is FakeHabitRepository;

bool isClearableCalendarRepository(Object? repo) =>
    repo is LocalCalendarRepository || repo is FakeCalendarRepository;
