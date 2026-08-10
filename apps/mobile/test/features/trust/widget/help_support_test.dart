import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/app/theme/app_theme.dart';
import 'package:memy/core/application/providers/core_providers.dart';
import 'package:memy/features/trust/application/providers/trust_providers.dart';
import 'package:memy/features/trust/domain/entities/changelog_entry.dart';
import 'package:memy/features/trust/domain/entities/support_article.dart';
import 'package:memy/features/trust/domain/entities/trust_document.dart';
import 'package:memy/features/trust/domain/repositories/trust_content_repository.dart';
import 'package:memy/features/trust/presentation/support/help_support_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTrustContentRepository implements TrustContentRepository {
  @override
  Future<List<ChangelogEntry>> getChangelog() async => const [];

  @override
  Future<TrustDocument> getDocument(TrustDocumentType type) async {
    throw UnimplementedError();
  }

  @override
  Future<List<SupportArticle>> listSupportArticles() async => const [
    SupportArticle(
      id: 'getting-started',
      title: 'Getting started with MeMy',
      category: SupportTopicCategory.gettingStarted,
      summary: 'Start here',
      bodyMarkdown: '# Start',
      tags: ['start'],
    ),
    SupportArticle(
      id: 'calendar-sync',
      title: 'Calendar sync basics',
      category: SupportTopicCategory.calendar,
      summary: 'Sync help',
      bodyMarkdown: '# Calendar',
      tags: ['calendar'],
    ),
  ];

  @override
  Future<List<SupportArticle>> searchArticles(String query) async {
    final all = await listSupportArticles();
    return all.where((a) => a.matchesQuery(query)).toList();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('help support search filters articles', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          trustContentRepositoryProvider.overrideWithValue(
            _FakeTrustContentRepository(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const HelpSupportScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('help_support')), findsOneWidget);
    expect(find.text('Getting started with MeMy'), findsOneWidget);
    expect(find.text('Calendar sync basics'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('help_search')), 'calendar');
    await tester.pumpAndSettle();

    expect(find.text('Calendar sync basics'), findsOneWidget);
    expect(find.text('Getting started with MeMy'), findsNothing);
  });
}
