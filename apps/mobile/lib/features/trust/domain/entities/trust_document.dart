/// Legal / policy document metadata and body for Trust Center screens.
enum TrustDocumentType {
  privacyPolicy,
  termsOfUse,
  healthDisclaimer,
  financialDisclaimer,
}

enum TrustDocumentStatus {
  /// Not final counsel-approved copy.
  draft,
  published,
}

class TrustDocument {
  const TrustDocument({
    required this.type,
    required this.title,
    required this.version,
    required this.effectiveDate,
    required this.status,
    required this.bodyMarkdown,
    this.sections = const [],
    this.assetPath,
  });

  final TrustDocumentType type;
  final String title;
  final String version;
  final DateTime effectiveDate;
  final TrustDocumentStatus status;
  final String bodyMarkdown;
  final List<TrustDocumentSection> sections;
  final String? assetPath;

  bool get isDraft => status == TrustDocumentStatus.draft;
}

class TrustDocumentSection {
  const TrustDocumentSection({
    required this.heading,
    required this.bodyMarkdown,
  });

  final String heading;
  final String bodyMarkdown;
}
