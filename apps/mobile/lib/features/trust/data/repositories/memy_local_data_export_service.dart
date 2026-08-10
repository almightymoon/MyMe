import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../calendar/data/repositories/fake_calendar_repository.dart';
import '../../../calendar/data/repositories/local_calendar_repository.dart';
import '../../../calendar/domain/entities/calendar_event_origin.dart';
import '../../../calendar/domain/repositories/calendar_repository.dart';
import '../../../finance/data/repositories/fake_finance_repository.dart';
import '../../../finance/data/repositories/local_finance_repository.dart';
import '../../../finance/domain/repositories/finance_repository.dart';
import '../../../goals/data/repositories/fake_goal_repository.dart';
import '../../../goals/data/repositories/local_goal_repository.dart';
import '../../../goals/domain/repositories/goal_repository.dart';
import '../../../habits/data/repositories/fake_habit_repository.dart';
import '../../../habits/data/repositories/local_habit_repository.dart';
import '../../../habits/domain/repositories/habit_repository.dart';
import '../../../health/domain/repositories/health_repository.dart';
import '../../domain/entities/data_catalog.dart';
import '../../domain/entities/export_request.dart';
import '../../domain/services/local_data_export_service.dart';

/// Exports MeMy-owned module data to a versioned JSON file.
///
/// Excludes: raw health sample values, external calendar payloads by default,
/// API tokens, passwords, and other secrets.
class MemyLocalDataExportService implements LocalDataExportService {
  MemyLocalDataExportService({
    this.goalRepository,
    this.financeRepository,
    this.habitRepository,
    this.calendarRepository,
    this.healthRepository,
    this.preferencesReader,
    this.tempDirectoryOverride,
    this.clock,
  });

  static const int exportSchemaVersion = 1;

  final GoalRepository? goalRepository;
  final FinanceRepository? financeRepository;
  final HabitRepository? habitRepository;
  final CalendarRepository? calendarRepository;
  final HealthRepository? healthRepository;

  /// Optional map of non-secret preference keys → values.
  final Future<Map<String, Object?>> Function()? preferencesReader;

  /// Tests can inject a temp directory to avoid path_provider plugins.
  final Future<Directory> Function()? tempDirectoryOverride;

  final DateTime Function()? clock;

  @override
  Future<Map<String, Object?>> buildExportMap(ExportRequest request) async {
    final generatedAt = (clock?.call() ?? DateTime.now()).toUtc();
    final modules = <String, Object?>{};
    final warnings = <String>[];

    for (final module in request.modules) {
      switch (module) {
        case DataModule.goals:
          modules['goals'] = await _exportGoals(warnings);
        case DataModule.finance:
          modules['finance'] = await _exportFinance(warnings);
        case DataModule.habits:
          modules['habits'] = await _exportHabits(warnings);
        case DataModule.calendar:
          modules['calendar'] = await _exportCalendar(request, warnings);
        case DataModule.health:
          modules['health'] = await _exportHealth(request, warnings);
        case DataModule.preferences:
          modules['preferences'] = await _exportPreferences(warnings);
        case DataModule.profile:
          modules['profile'] = {
            'note': 'Profile export is summary-only / planned in this build.',
          };
          warnings.add('Profile export is limited in this build.');
        case DataModule.diagnostics:
          modules['diagnostics'] = {
            'note': 'Use Help → Report a problem for allowlisted diagnostics.',
          };
      }
    }

    return {
      'schemaVersion': exportSchemaVersion,
      'generatedAtUtc': generatedAt.toIso8601String(),
      'modules': modules,
      'warnings': warnings,
    };
  }

  @override
  Future<ExportResult> export(ExportRequest request) async {
    final map = await buildExportMap(request);
    final generatedAt = DateTime.parse(map['generatedAtUtc']! as String);
    final warnings =
        (map['warnings'] as List?)?.map((e) => e.toString()).toList() ??
        const <String>[];

    final dir = tempDirectoryOverride != null
        ? await tempDirectoryOverride!()
        : await getTemporaryDirectory();
    final fileName =
        'memy-export-${generatedAt.toIso8601String().replaceAll(':', '')}.json';
    final file = File(p.join(dir.path, fileName));
    final encoded = const JsonEncoder.withIndent('  ').convert(map);
    await file.writeAsString(encoded, flush: true);

    return ExportResult(
      filePath: file.path,
      modules: request.modules,
      generatedAt: generatedAt,
      warnings: warnings,
      byteLength: encoded.length,
    );
  }

  Future<Object?> _exportGoals(List<String> warnings) async {
    final repo = goalRepository;
    if (repo == null) {
      warnings.add('Goals repository unavailable.');
      return null;
    }
    final goals = await repo.getGoals();
    return {
      'count': goals.length,
      'items': goals.map((g) => g.toJson()).toList(growable: false),
    };
  }

  Future<Object?> _exportFinance(List<String> warnings) async {
    final repo = financeRepository;
    if (repo == null) {
      warnings.add('Finance repository unavailable.');
      return null;
    }
    final txs = await repo.getTransactions();
    final cats = await repo.getCategories();
    return {
      'transactionCount': txs.length,
      'categories': cats.map((c) => c.toJson()).toList(growable: false),
      'transactions': txs.map((t) => t.toJson()).toList(growable: false),
    };
  }

  Future<Object?> _exportHabits(List<String> warnings) async {
    final repo = habitRepository;
    if (repo == null) {
      warnings.add('Habits repository unavailable.');
      return null;
    }
    final habits = await repo.getHabits();
    return {
      'count': habits.length,
      'items': habits.map((h) => h.toJson()).toList(growable: false),
    };
  }

  Future<Object?> _exportCalendar(
    ExportRequest request,
    List<String> warnings,
  ) async {
    final repo = calendarRepository;
    if (repo == null) {
      warnings.add('Calendar repository unavailable.');
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
      eventsPayload = {
        'count': owned.length,
        'items': owned.map((e) => e.toJson()).toList(growable: false),
      };
    } else {
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
  ) async {
    final repo = healthRepository;
    if (repo == null) {
      warnings.add('Health repository unavailable.');
      return null;
    }
    if (!request.includeHealthConnectionSummary) {
      warnings.add('Health connection summary skipped by request.');
      return {'included': false};
    }
    final connection = await repo.getConnection();
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

  Future<Object?> _exportPreferences(List<String> warnings) async {
    final reader = preferencesReader;
    if (reader == null) {
      warnings.add('Preferences reader unavailable.');
      return const <String, Object?>{};
    }
    return reader();
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
