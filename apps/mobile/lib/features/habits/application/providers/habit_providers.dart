import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/fake_repository_config.dart';
import '../../data/repositories/fake_habit_repository.dart';
import '../../domain/entities/habit_summary.dart';
import '../../domain/repositories/habit_repository.dart';

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return FakeHabitRepository(config: ref.watch(fakeRepositoryConfigProvider));
});

final habitsProvider = FutureProvider.autoDispose<List<HabitSummary>>((
  ref,
) async {
  return ref.watch(habitRepositoryProvider).fetchHabits();
});
