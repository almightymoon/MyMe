class ChangelogEntry {
  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.title,
    required this.bullets,
  });

  final String version;
  final DateTime date;
  final String title;
  final List<String> bullets;
}
