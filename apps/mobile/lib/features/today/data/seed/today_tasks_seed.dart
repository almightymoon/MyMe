import '../../domain/entities/today_task.dart';

/// Demo tasks matching the HTML home checklist (`#home-todos`).
abstract final class TodayTasksSeed {
  static List<TodayTask> demoTasks() => [
    const TodayTask(
      id: 'task-stretch',
      title: 'Morning stretch routine',
      meta: 'Health · 7:30 AM',
      isDone: true,
    ),
    const TodayTask(
      id: 'task-budget',
      title: 'Review weekly budget',
      meta: 'Finance · Done',
      isDone: true,
    ),
    const TodayTask(
      id: 'task-literature',
      title: 'Draft literature review section',
      meta: 'Goals · Due today',
    ),
    const TodayTask(
      id: 'task-water',
      title: 'Drink 2L water',
      meta: 'Health · 1.6 / 2 L',
    ),
    const TodayTask(
      id: 'task-gym-bag',
      title: 'Pack gym bag',
      meta: 'Calendar · Before 6 PM',
    ),
  ];
}
