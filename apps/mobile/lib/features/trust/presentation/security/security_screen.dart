import 'package:flutter/material.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_card.dart';
import '../widgets/trust_screen_scaffold.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TrustScreenScaffold(
      key: const Key('security_screen'),
      title: 'Security',
      subtitle: 'Honest status for this build',
      fallbackPath: RoutePaths.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MemyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What is available', style: AppTextStyles.titleMedium()),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Production accounts use Google or Sign in with Apple. '
                  'Refresh tokens stay in platform secure storage. Access tokens '
                  'are short-lived. The API uses HTTPS. App-owned records can '
                  'sync after sign-in; Health samples and imported calendars stay '
                  'on this device. Diagnostics are redacted.',
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
                  'Not claimed in this build',
                  style: AppTextStyles.titleMedium(),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'MeMy does not claim end-to-end encryption, an encrypted '
                  'local database, MFA, biometric app lock, GDPR certification, '
                  'or HIPAA compliance.',
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
