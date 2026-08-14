import '../entities/changelog_entry.dart';
import '../entities/support_article.dart';
import '../entities/trust_document.dart';

/// Loads trust/legal/support/changelog content.
abstract class TrustContentRepository {
  Future<TrustDocument> getDocument(TrustDocumentType type);

  Future<List<SupportArticle>> listSupportArticles();

  Future<List<SupportArticle>> searchArticles(String query);

  Future<List<ChangelogEntry>> getChangelog();
}
