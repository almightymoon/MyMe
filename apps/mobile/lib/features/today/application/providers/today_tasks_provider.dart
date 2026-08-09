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

  void add(String title, {String meta = 'Quick Add · Today'}) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;

    final id = 'task-${DateTime.now().microsecondsSinceEpoch}';
    state = [
      ...state,
      TodayTask(id: id, title: trimmed, meta: meta),
    ];
  }

  void remove(String id) {
    state = [for (final task in state) if (task.id != id) task];
  }

  void resetDemo() {
    state = TodayTasksSeed.demoTasks();
  }
}

/// Kept alive so Quick Add can append tasks from any shell tab.
final todayTasksProvider =
    StateNotifierProvider<TodayTasksNotifier, List<TodayTask>>((ref) {
      return TodayTasksNotifier();
    });
