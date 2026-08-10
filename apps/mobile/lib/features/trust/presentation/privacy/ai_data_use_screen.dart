import 'package:flutter/material.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_card.dart';
import '../widgets/trust_screen_scaffold.dart';

class AiDataUseScreen extends StatelessWidget {
  const AiDataUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TrustScreenScaffold(
      key: const Key('privacy_ai_data_use'),
      title: 'AI data use',
      subtitle: 'Current build boundaries',
      fallbackPath: RoutePaths.privacy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MemyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What AI Coach receives',
                  style: AppTextStyles.titleMedium(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'In this build, AI Coach UI does not receive Health sample '
                  'values, calendar event titles, or finance ledger rows. '
                  'Do not assume future AI features keep the same boundary '
                  'until Privacy Policy and this screen are updated.',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MemyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Never sent to AI (this build)',
                  style: AppTextStyles.titleMedium(),
                ),
                const SizedBox(height: AppSpacing.sm),
                const _Bullet('HealthKit / Health Connect sample values'),
                const _Bullet('External device calendar content'),
                const _Bullet('Passwords, tokens, and API secrets'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium())),
        ],
      ),
    );
  }
}
