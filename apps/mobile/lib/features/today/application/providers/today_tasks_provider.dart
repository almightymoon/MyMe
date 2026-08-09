import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/seed/today_tasks_seed.dart';
import '../../domain/entities/today_task.dart';

class TodayTasksNotifier extends StateNotifier<List<TodayTask>> {
  TodayTasksNotifier({List<TodayTask>? initial})
    : super(initial ?? TodayTasksSeed.demoTasks());

  void toggle(String id) {
    state = [
      for (final task in state)
        if (task.id == id) task.copyWith(isDone: !task.isDone) else task,
    ];
  }

  void resetDemo() {
    state = TodayTasksSeed.demoTasks();
  }
}

final todayTasksProvider =
    StateNotifierProvider.autoDispose<TodayTasksNotifier, List<TodayTask>>((
      ref,
    ) {
      return TodayTasksNotifier();
    });
