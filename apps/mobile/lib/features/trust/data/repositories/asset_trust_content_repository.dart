import 'package:flutter/services.dart';

import '../../domain/entities/changelog_entry.dart';
import '../../domain/entities/support_article.dart';
import '../../domain/entities/trust_document.dart';
import '../../domain/repositories/trust_content_repository.dart';

/// Metadata constants + markdown bodies loaded from `assets/trust/`.
class AssetTrustContentRepository implements TrustContentRepository {
  AssetTrustContentRepository({AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const _effective = '2026-08-10';
  static const _version = '0.1.0';

  static final Map<TrustDocumentType, _DocMeta> _documents = {
    TrustDocumentType.privacyPolicy: const _DocMeta(
      title: 'Privacy Policy',
      assetPath: 'assets/trust/legal/privacy-policy.md',
    ),
    TrustDocumentType.termsOfUse: const _DocMeta(
      title: 'Terms of Use',
      assetPath: 'assets/trust/legal/terms-of-use.md',
    ),
    TrustDocumentType.healthDisclaimer: const _DocMeta(
      title: 'Health Disclaimer',
      assetPath: 'assets/trust/legal/health-disclaimer.md',
    ),
    TrustDocumentType.financialDisclaimer: const _DocMeta(
      title: 'Financial Disclaimer',
      assetPath: 'assets/trust/legal/financial-disclaimer.md',
    ),
  };

  static const List<_ArticleMeta> _articles = [
    _ArticleMeta(
      id: 'getting-started',
      title: 'Getting started with MeMy',
      category: SupportTopicCategory.gettingStarted,
      summary: 'Sign in, open Today, and find Privacy & Help.',
      assetPath: 'assets/trust/support/getting-started.md',
      tags: ['start', 'tour', 'today'],
    ),
    _ArticleMeta(
      id: 'calendar-sync',
      title: 'Calendar sync basics',
      category: SupportTopicCategory.calendar,
      summary: 'Local cache vs device calendars, disconnect, and wipe.',
      assetPath: 'assets/trust/support/calendar-sync.md',
      tags: ['calendar', 'sync', 'disconnect'],
    ),
    _ArticleMeta(
      id: 'health-connect',
      title: 'Connecting Health',
      category: SupportTopicCategory.health,
      summary: 'Read-only HealthKit / Health Connect connection.',
      assetPath: 'assets/trust/support/health-connect.md',
      tags: ['health', 'permissions'],
    ),
    _ArticleMeta(
      id: 'privacy-overview',
      title: 'Privacy & your data',
      category: SupportTopicCategory.privacy,
      summary: 'What stays on device and how export / delete work.',
      assetPath: 'assets/trust/support/privacy-overview.md',
      tags: ['privacy', 'export', 'delete'],
    ),
    _ArticleMeta(
      id: 'goals-basics',
      title: 'Working with Goals',
      category: SupportTopicCategory.goals,
      summary: 'Local goals and optional API mode.',
      assetPath: 'assets/trust/support/goals-basics.md',
      tags: ['goals', 'milestones'],
    ),
    _ArticleMeta(
      id: 'finance-basics',
      title: 'Tracking Finance',
      category: SupportTopicCategory.finance,
      summary: 'On-device ledger with no bank links in this build.',
      assetPath: 'assets/trust/support/finance-basics.md',
      tags: ['finance', 'budget'],
    ),
    _ArticleMeta(
      id: 'habits-basics',
      title: 'Building Habits',
      category: SupportTopicCategory.habits,
      summary: 'Schedules, check-ins, and local storage.',
      assetPath: 'assets/trust/support/habits-basics.md',
      tags: ['habits', 'streaks'],
    ),
    _ArticleMeta(
      id: 'troubleshooting',
      title: 'Troubleshooting',
      category: SupportTopicCategory.troubleshooting,
      summary: 'Empty data after wipe, sync, and Health permissions.',
      assetPath: 'assets/trust/support/troubleshooting.md',
      tags: ['help', 'error', 'fix'],
    ),
  ];

  @override
  Future<TrustDocument> getDocument(TrustDocumentType type) async {
    final meta = _documents[type]!;
    final body = await _bundle.loadString(meta.assetPath);
    return TrustDocument(
      type: type,
      title: meta.title,
      version: _version,
      effectiveDate: DateTime.parse(_effective),
      status: TrustDocumentStatus.draft,
      bodyMarkdown: body,
      assetPath: meta.assetPath,
    );
  }

  @override
  Future<List<SupportArticle>> listSupportArticles() async {
    final articles = <SupportArticle>[];
    for (final meta in _articles) {
      final body = await _bundle.loadString(meta.assetPath);
      articles.add(
        SupportArticle(
          id: meta.id,
          title: meta.title,
          category: meta.category,
          summary: meta.summary,
          bodyMarkdown: body,
          tags: meta.tags,
          assetPath: meta.assetPath,
        ),
      );
    }
    return List.unmodifiable(articles);
  }

  @override
  Future<List<SupportArticle>> searchArticles(String query) async {
    final all = await listSupportArticles();
    return all.where((a) => a.matchesQuery(query)).toList(growable: false);
  }

  @override
  Future<List<ChangelogEntry>> getChangelog() async {
    final raw = await _bundle.loadString('assets/trust/changelog/whats-new.md');
    return _parseChangelog(raw);
  }

  static List<ChangelogEntry> _parseChangelog(String markdown) {
    final entries = <ChangelogEntry>[];
    final sections = markdown.split(RegExp(r'\n##\s+'));
    for (final section in sections) {
      final trimmed = section.trim();
      if (trimmed.isEmpty || trimmed.startsWith('# ')) continue;
      final lines = trimmed.split('\n');
      final header = lines.first.trim();
      // e.g. "1.0.0 — 2026-08-10"
      final match = RegExp(
        r'^(.+?)\s+[—-]\s+(\d{4}-\d{2}-\d{2})\s*$',
      ).firstMatch(header);
      if (match == null) continue;
      final version = match.group(1)!.trim();
      final date = DateTime.parse(match.group(2)!);
      final bullets = <String>[];
      for (final line in lines.skip(1)) {
        final t = line.trim();
        if (t.startsWith('- ')) {
          bullets.add(t.substring(2).trim());
        }
      }
      entries.add(
        ChangelogEntry(
          version: version,
          date: date,
          title: 'Version $version',
          bullets: bullets,
        ),
      );
    }
    return List.unmodifiable(entries);
  }
}

class _DocMeta {
  const _DocMeta({required this.title, required this.assetPath});
  final String title;
  final String assetPath;
}

class _ArticleMeta {
  const _ArticleMeta({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.assetPath,
    this.tags = const [],
  });

  final String id;
  final String title;
  final SupportTopicCategory category;
  final String summary;
  final String assetPath;
  final List<String> tags;
}
