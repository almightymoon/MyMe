class TodayTask {
  const TodayTask({
    required this.id,
    required this.title,
    required this.meta,
    this.isDone = false,
  });

  final String id;
  final String title;
  final String meta;
  final bool isDone;

  TodayTask copyWith({String? id, String? title, String? meta, bool? isDone}) {
    return TodayTask(
      id: id ?? this.id,
      title: title ?? this.title,
      meta: meta ?? this.meta,
      isDone: isDone ?? this.isDone,
    );
  }
}
