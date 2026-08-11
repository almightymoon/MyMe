import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/config/environment_config.dart';
import '../../../../core/widgets/memy_busy_indicator.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/providers/trust_providers.dart';
import '../../domain/entities/support_article.dart';
import '../widgets/trust_screen_scaffold.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final _query = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final articlesAsync = _search.trim().isEmpty
        ? ref.watch(supportArticlesProvider)
        : ref.watch(supportArticleSearchProvider(_search));

    return TrustScreenScaffold(
      key: const Key('help_support'),
      title: 'Help & Support',
      subtitle: 'Guides and contact',
      fallbackPath: RoutePaths.settings,
      scrollable: false,
      child: Column(
        children: [
          TextField(
            key: const Key('help_search'),
            controller: _query,
            decoration: const InputDecoration(
              hintText: 'Search articles',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (v) => setState(() => _search = v),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: articlesAsync.when(
              loading: () => const Center(child: MemyBusyIndicator()),
              error: (e, _) =>
                  const Text('Could not load articles. Please try again.'),
              data: (articles) {
                return ListView(
                  children: [
                    ...articles.map((a) => _ArticleTile(article: a)),
                    const SizedBox(height: AppSpacing.md),
                    Text('Contact', style: AppTextStyles.titleMedium()),
                    const SizedBox(height: AppSpacing.sm),
                    _LinkCard(
                      keyName: 'help_contact',
                      title: 'Contact support',
                      subtitle: EnvironmentConfig.hasSupportEmail
                          ? EnvironmentConfig.supportEmail
                          : 'Support email not configured for this build',
                      onTap: () => context.push(RoutePaths.helpContact),
                    ),
                    _LinkCard(
                      keyName: 'help_report',
                      title: 'Report a problem',
                      subtitle: 'Share an allowlisted diagnostics report',
                      onTap: () => context.push(RoutePaths.helpReportProblem),
                    ),
                    _LinkCard(
                      keyName: 'help_feature',
                      title: 'Feature request',
                      subtitle: 'Tell us what would help next',
                      onTap: () => context.push(RoutePaths.helpFeatureRequest),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article});
  final SupportArticle article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MemyCard(
        key: Key('help_article_${article.id}'),
        onTap: () => context.push(RoutePaths.helpArticlePath(article.id)),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(article.title, style: AppTextStyles.titleSmall()),
            const SizedBox(height: 4),
            Text(
              article.summary,
              style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  const _LinkCard({
    required this.keyName,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String keyName;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: MemyCard(
        key: Key(keyName),
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.titleSmall()),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall(color: AppColors.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}

class SupportArticleDetailScreen extends ConsumerWidget {
  const SupportArticleDetailScreen({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final articlesAsync = ref.watch(supportArticlesProvider);
    return articlesAsync.when(
      loading: () => const Scaffold(body: Center(child: MemyBusyIndicator())),
      error: (e, _) => const Scaffold(
        body: Center(child: Text('Could not load this article.')),
      ),
      data: (articles) {
        SupportArticle? article;
        for (final a in articles) {
          if (a.id == articleId) {
            article = a;
            break;
          }
        }
        if (article == null) {
          return TrustScreenScaffold(
            title: 'Article',
            fallbackPath: RoutePaths.help,
            child: const Text('Article not found.'),
          );
        }
        return TrustScreenScaffold(
          key: Key('help_article_detail_$articleId'),
          title: article.title,
          fallbackPath: RoutePaths.help,
          child: Text(article.bodyMarkdown, style: AppTextStyles.bodyMedium()),
        );
      },
    );
  }
}

class HelpContactScreen extends StatelessWidget {
  const HelpContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = EnvironmentConfig.supportEmail.trim();
    return TrustScreenScaffold(
      key: const Key('help_contact'),
      title: 'Contact',
      fallbackPath: RoutePaths.help,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            email.isEmpty
                ? 'No SUPPORT_EMAIL was provided for this build. '
                      'Use Report a problem to share diagnostics locally, or '
                      'contact MoonTech through your usual channel.'
                : 'Email $email for support questions. Include only what you '
                      'are comfortable sharing — prefer the Report a problem '
                      'flow for redacted diagnostics.',
            style: AppTextStyles.bodyMedium(color: AppColors.secondaryText),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            MemyPrimaryButton(
              key: const Key('help_contact_email'),
              label: 'Open mail app',
              onPressed: () async {
                final uri = Uri(
                  scheme: 'mailto',
                  path: email,
                  queryParameters: {'subject': 'MeMy support'},
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}

class ReportProblemScreen extends ConsumerStatefulWidget {
  const ReportProblemScreen({super.key});

  @override
  ConsumerState<ReportProblemScreen> createState() =>
      _ReportProblemScreenState();
}

class _ReportProblemScreenState extends ConsumerState<ReportProblemScreen> {
  final _message = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TrustScreenScaffold(
      key: const Key('help_report_problem'),
      title: 'Report a problem',
      subtitle: 'Allowlisted fields only',
      fallbackPath: RoutePaths.help,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('report_message'),
            controller: _message,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'What went wrong?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MemyPrimaryButton(
            key: const Key('report_share'),
            label: _busy ? 'Preparing…' : 'Share report',
            onPressed: _busy ? null : _share,
          ),
        ],
      ),
    );
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    try {
      final info = await ref.read(packageInfoProvider.future);
      if (!mounted) return;
      final platform = Theme.of(context).platform.name;
      final locale = Localizations.localeOf(context).toString();
      final sources = environmentDataSourceLabels();
      final report = await ref
          .read(supportReportBuilderProvider)
          .build(
            appVersion: info.version,
            buildNumber: info.buildNumber,
            packageName: info.packageName,
            platform: platform,
            locale: locale,
            goalsDataSource: sources['goals']!,
            financeDataSource: sources['finance']!,
            habitsDataSource: sources['habits']!,
            calendarDataSource: sources['calendar']!,
            healthDataSource: sources['health']!,
            feature: 'report_problem',
            userMessage: _message.text,
          );
      final text = ref.read(supportReportBuilderProvider).toPlainText(report);
      await SharePlus.instance.share(ShareParams(text: text));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not share. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class FeatureRequestScreen extends ConsumerStatefulWidget {
  const FeatureRequestScreen({super.key});

  @override
  ConsumerState<FeatureRequestScreen> createState() =>
      _FeatureRequestScreenState();
}

class _FeatureRequestScreenState extends ConsumerState<FeatureRequestScreen> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TrustScreenScaffold(
      key: const Key('help_feature_request'),
      title: 'Feature request',
      fallbackPath: RoutePaths.help,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const Key('feature_message'),
            controller: _message,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'What would you like MeMy to do?',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MemyPrimaryButton(
            key: const Key('feature_share'),
            label: 'Share request',
            onPressed: () async {
              final text = 'MeMy feature request\n\n${_message.text.trim()}';
              await SharePlus.instance.share(ShareParams(text: text));
            },
          ),
        ],
      ),
    );
  }
}
