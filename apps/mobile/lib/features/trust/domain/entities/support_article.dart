enum SupportTopicCategory {
  gettingStarted,
  calendar,
  health,
  privacy,
  goals,
  finance,
  habits,
  troubleshooting,
}

class SupportArticle {
  const SupportArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.bodyMarkdown,
    this.tags = const [],
    this.assetPath,
  });

  final String id;
  final String title;
  final SupportTopicCategory category;
  final String summary;
  final String bodyMarkdown;
  final List<String> tags;
  final String? assetPath;

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (title.toLowerCase().contains(q)) return true;
    if (summary.toLowerCase().contains(q)) return true;
    if (bodyMarkdown.toLowerCase().contains(q)) return true;
    return tags.any((t) => t.toLowerCase().contains(q));
  }
}
