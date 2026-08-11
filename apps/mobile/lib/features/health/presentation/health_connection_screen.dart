import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/integrations/domain/integration_availability.dart';
import '../../../core/widgets/memy_busy_indicator.dart';
import '../../../core/widgets/memy_module_scaffold.dart';
import '../application/providers/health_providers.dart';
import 'widgets/health_disclaimer_banner.dart';

/// Explains the Health connection before requesting any permission.
///
/// Never requests permission itself — that only happens from
/// [HealthPermissionSelectionScreen] after explicit user action, per the
/// "never auto-request permissions" rule.
class HealthConnectionScreen extends ConsumerWidget {
  const HealthConnectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availabilityAsync = ref.watch(healthAvailabilityProvider);

    return MemyModuleScaffold(
      key: const Key('health_connection_screen'),
      title: 'Connect Health',
      fallbackPath: RoutePaths.health,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.favorite_rounded, color: AppColors.ember, size: 40),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Bring in your Health data',
            style: AppTextStyles.displayMedium().copyWith(fontSize: 22),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'MeMy can read steps, distance, heart rate, sleep, exercise '
            'minutes, and weight from Apple Health or Health Connect. This '
            'is read-only — MeMy never writes to or edits your Health data, '
            'and nothing is uploaded anywhere.',
            style: AppTextStyles.bodyMedium(),
          ),
          const SizedBox(height: AppSpacing.xl),
          _InfoRow(
            icon: Icons.visibility_outlined,
            text: 'You choose exactly which categories to share, next.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.lock_outline_rounded,
            text: 'Read-only. MeMy cannot modify your Health records.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: Icons.toggle_off_outlined,
            text: 'Disconnect anytime from Manage access.',
          ),
          const SizedBox(height: AppSpacing.xxl),
          availabilityAsync.when(
            data: (availability) => _ContinueButton(availability: availability),
            loading: () => const Center(child: MemyBusyIndicator()),
            error: (error, _) => const _ContinueButton(
              availability: IntegrationAvailability.unavailable,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const HealthDisclaimerBanner(),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryText),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: AppTextStyles.bodyMedium())),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.availability});

  final IntegrationAvailability availability;

  @override
  Widget build(BuildContext context) {
    final isAvailable = availability == IntegrationAvailability.available;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isAvailable)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                borderRadius: AppRadii.chipRadius,
              ),
              child: Text(
                availability == IntegrationAvailability.notSupported
                    ? "Health isn't available on this device. On Android, "
                          'install Health Connect from the Play Store first.'
                    : "Couldn't check Health availability. Try again in a "
                          'moment.',
                style: AppTextStyles.bodySmall(color: AppColors.emberDark),
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('health_choose_permissions_button'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.ember,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadii.controlRadius,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: isAvailable
                ? () => context.push(RoutePaths.healthPermissions)
                : null,
            child: const Text('Choose what to share'),
          ),
        ),
      ],
    );
  }
}
