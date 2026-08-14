import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/config/environment_config.dart';
import '../../../auth/application/auth_session_controller.dart';
import '../../../auth/data/account_local_store.dart';
import '../../../../core/domain/value_objects/local_date.dart';
import '../../data/repositories/fake_habit_repository.dart';
import '../../data/repositories/local_habit_repository.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_check_in.dart';
import '../../domain/entities/habit_enums.dart';
import '../../domain/entities/habit_progress.dart';
import '../../domain/repositories/habit_repository.dart';
import '../../domain/services/habit_progress_service.dart';
import '../../domain/services/habit_schedule_service.dart';

export '../../../../core/application/providers/core_providers.dart'
    show appClockProvider, sharedPreferencesProvider, uuidProvider;

final habitScheduleServiceProvider = Provider<HabitScheduleService>(
  (ref) => const HabitScheduleService(),
);

final habitProgressServiceProvider = Provider<HabitProgressService>((ref) {
  return HabitProgressService(
    scheduleService: ref.watch(habitScheduleServiceProvider),
  );
});

final habitsDataSourceProvider = Provider<HabitsDataSource>((ref) {
  return EnvironmentConfig.resolveHabitsDataSource();
});

final localHabitRepositoryProvider = Provider<LocalHabitRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final store = AccountLocalStore(ref.watch(authSessionProvider)?.userId);
  final repo = LocalHabitRepository(
    prefs: prefs,
    documentKey: store.key(LocalHabitRepository.storageKey),
    initKey: store.key(LocalHabitRepository.initializedKey),
    clock: ref.watch(appClockProvider),
    progressService: ref.watch(habitProgressServiceProvider),
    idGenerator: () => ref.read(uuidProvider).v4(),
    seedHabitsBuilder: EnvironmentConfig.shouldSeedDemoContent
        ? null
        : (today, now) => const [],
    seedCheckInsBuilder: EnvironmentConfig.shouldSeedDemoContent
        ? null
        : (today, now) => const [],
  );
  ref.onDispose(repo.dispose);
  return repo;
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  switch (ref.watch(habitsDataSourceProvider)) {
    case HabitsDataSource.fake:
      final repo = FakeHabitRepository(
        clock: ref.watch(appClockProvider),
        progressService: ref.watch(habitProgressServiceProvider),
      );
      ref.onDispose(repo.dispose);
      return repo;
    case HabitsDataSource.local:
      return ref.watch(localHabitRepositoryProvider);
  }
});

final habitsSelectedDateProvider = StateProvider<LocalDate>((ref) {
  return LocalDate.fromDateTime(ref.watch(appClockProvider).now());
});

final habitsListProvider = StreamProvider.autoDispose<List<Habit>>((ref) {
  return ref.watch(habitRepositoryProvider).watchHabits();
});

final habitCheckInsProvider = StreamProvider.autoDispose<List<HabitCheckIn>>((
  ref,
) {
  return ref.watch(habitRepositoryProvider).watchCheckIns();
});

final habitByIdProvider = Provider.autoDispose
    .family<AsyncValue<Habit?>, String>((ref, id) {
      final async = ref.watch(habitsListProvider);
      return async.whenData((habits) {
        for (final h in habits) {
          if (h.id == id) return h;
        }
        return null;
      });
    });

final habitsOverviewProvider =
    Provider.autoDispose<AsyncValue<HabitsOverviewSummary>>((ref) {
      final habitsAsync = ref.watch(habitsListProvider);
      final checkInsAsync = ref.watch(habitCheckInsProvider);
      final date = ref.watch(habitsSelectedDateProvider);
      final progress = ref.watch(habitProgressServiceProvider);

      if (habitsAsync.isLoading || checkInsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (habitsAsync.hasError) {
        return AsyncValue.error(habitsAsync.error!, habitsAsync.stackTrace!);
      }
      if (checkInsAsync.hasError) {
        return AsyncValue.error(
          checkInsAsync.error!,
          checkInsAsync.stackTrace!,
        );
      }

      return AsyncValue.data(
        progress.overview(
          habits: habitsAsync.value ?? const [],
          checkIns: checkInsAsync.value ?? const [],
          date: date,
        ),
      );
    });

final todayHabitItemsProvider =
    Provider.autoDispose<AsyncValue<List<HabitTodayItem>>>((ref) {
      final overview = ref.watch(habitsOverviewProvider);
      return overview.whenData((o) => o.items);
    });

final activeHabitsProvider = Provider.autoDispose<AsyncValue<List<Habit>>>((
  ref,
) {
  return ref
      .watch(habitsListProvider)
      .whenData(
        (habits) => habits
            .where((h) => h.status == HabitStatus.active)
            .toList(growable: false),
      );
});

final pausedHabitsProvider = Provider.autoDispose<AsyncValue<List<Habit>>>((
  ref,
) {
  return ref
      .watch(habitsListProvider)
      .whenData(
        (habits) => habits
            .where((h) => h.status == HabitStatus.paused)
            .toList(growable: false),
      );
});

final archivedHabitsProvider = Provider.autoDispose<AsyncValue<List<Habit>>>((
  ref,
) {
  return ref
      .watch(habitsListProvider)
      .whenData(
        (habits) => habits
            .where((h) => h.status == HabitStatus.archived)
            .toList(growable: false),
      );
});

final habitCheckInsForHabitProvider = Provider.autoDispose
    .family<AsyncValue<List<HabitCheckIn>>, String>((ref, habitId) {
      return ref
          .watch(habitCheckInsProvider)
          .whenData(
            (all) =>
                all.where((c) => c.habitId == habitId).toList(growable: false),
          );
    });

enum HabitsListFilter { active, paused, archived }

final habitsFilterProvider = StateProvider.autoDispose<HabitsListFilter>((ref) {
  return HabitsListFilter.active;
});

final filteredHabitsProvider = Provider.autoDispose<AsyncValue<List<Habit>>>((
  ref,
) {
  final filter = ref.watch(habitsFilterProvider);
  final habitsAsync = ref.watch(habitsListProvider);
  return habitsAsync.whenData((habits) {
    return habits
        .where(
          (h) => switch (filter) {
            HabitsListFilter.active => h.status == HabitStatus.active,
            HabitsListFilter.paused => h.status == HabitStatus.paused,
            HabitsListFilter.archived => h.status == HabitStatus.archived,
          },
        )
        .toList(growable: false);
  });
});

final habitProgressByIdProvider = Provider.autoDispose
    .family<AsyncValue<HabitProgressSummary?>, String>((ref, habitId) {
      final habitAsync = ref.watch(habitByIdProvider(habitId));
      final checkInsAsync = ref.watch(habitCheckInsProvider);
      final clock = ref.watch(appClockProvider);
      final progress = ref.watch(habitProgressServiceProvider);
      final today = LocalDate.fromDateTime(clock.now());

      if (habitAsync.isLoading || checkInsAsync.isLoading) {
        return const AsyncValue.loading();
      }
      if (habitAsync.hasError) {
        return AsyncValue.error(habitAsync.error!, habitAsync.stackTrace!);
      }
      if (checkInsAsync.hasError) {
        return AsyncValue.error(
          checkInsAsync.error!,
          checkInsAsync.stackTrace!,
        );
      }
      final habit = habitAsync.value;
      if (habit == null) return const AsyncValue.data(null);
      return AsyncValue.data(
        progress.progressFor(
          habit: habit,
          checkIns: checkInsAsync.value ?? const [],
          today: today,
        ),
      );
    });
