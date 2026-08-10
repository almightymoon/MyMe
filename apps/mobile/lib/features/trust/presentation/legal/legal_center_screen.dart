import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../application/providers/trust_providers.dart';
import '../../domain/entities/trust_document.dart';
import '../widgets/trust_screen_scaffold.dart';

class LegalCenterScreen extends StatelessWidget {
  const LegalCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TrustScreenScaffold(
      key: const Key('legal_center'),
      title: 'Legal',
      subtitle: 'Draft documents for this build',
      fallbackPath: RoutePaths.settings,
      child: Column(
        children: [
          _DocLink(
            keyName: 'legal_privacy_policy',
            title: 'Privacy Policy',
            type: TrustDocumentType.privacyPolicy,
          ),
          _DocLink(
            keyName: 'legal_terms',
            title: 'Terms of Use',
            type: TrustDocumentType.termsOfUse,
          ),
          _DocLink(
            keyName: 'legal_health',
            title: 'Health Disclaimer',
            type: TrustDocumentType.healthDisclaimer,
          ),
          _DocLink(
            keyName: 'legal_finance',
            title: 'Financial Disclaimer',
            type: TrustDocumentType.financialDisclaimer,
          ),
        ],
      ),
    );
  }
}

class _DocLink extends StatelessWidget {
  const _DocLink({
    required this.keyName,
    required this.title,
    required this.type,
  });

  final String keyName;
  final String title;
  final TrustDocumentType type;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MemyCard(
        key: Key(keyName),
        onTap: () => context.push(RoutePaths.legalDocumentPath(type.name)),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Expanded(child: Text(title, style: AppTextStyles.titleSmall())),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.navInactive,
            ),
          ],
        ),
      ),
    );
  }
}

class LegalDocumentScreen extends ConsumerWidget {
  const LegalDocumentScreen({super.key, required this.type});

  final TrustDocumentType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docAsync = ref.watch(trustDocumentProvider(type));
    return docAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => TrustScreenScaffold(
        title: 'Legal',
        fallbackPath: RoutePaths.legal,
        child: Text('Could not load document: $e'),
      ),
      data: (doc) {
        return TrustScreenScaffold(
          key: Key('legal_document_${type.name}'),
          title: doc.title,
          subtitle:
              'Draft v${doc.version} · effective ${_fmt(doc.effectiveDate)}',
          fallbackPath: RoutePaths.legal,
          scrollable: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (doc.isDraft)
                MemyCard(
                  color: AppColors.orangeSoft,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    'Draft — not legal counsel–approved. Not a compliance '
                    'certification.',
                    style: AppTextStyles.bodySmall(),
                  ),
                ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Markdown(
                  data: doc.bodyMarkdown,
                  selectable: true,
                  styleSheet: MarkdownStyleSheet(
                    p: AppTextStyles.bodyMedium(),
                    h1: AppTextStyles.titleLarge(),
                    h2: AppTextStyles.titleMedium(),
                    h3: AppTextStyles.titleSmall(),
                    listBullet: AppTextStyles.bodyMedium(),
                    strong: AppTextStyles.bodyMedium().copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
