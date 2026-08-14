import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_card.dart';
import '../../application/providers/trust_providers.dart';
import '../widgets/trust_screen_scaffold.dart';

class AppearanceAccessibilityScreen extends ConsumerWidget {
  const AppearanceAccessibilityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModePreferenceProvider);
    final reduceMotion = ref.watch(reduceMotionPreferenceProvider);

    return TrustScreenScaffold(
      key: const Key('appearance_accessibility'),
      title: 'Appearance',
      subtitle: 'Theme and motion preferences',
      fallbackPath: RoutePaths.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MemyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Theme', style: AppTextStyles.titleMedium()),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<ThemeMode>(
                  key: const Key('theme_mode_segments'),
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.brightness_auto_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.wb_sunny_outlined),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (values) {
                    final mode = values.first;
                    ref
                        .read(themeModePreferenceProvider.notifier)
                        .setMode(mode);
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Applies across every screen, including sheets and the side menu.',
                  style: AppTextStyles.bodySmall(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MemyCard(
            child: SwitchListTile(
              key: const Key('reduce_motion'),
              title: const Text('Reduce motion'),
              subtitle: const Text(
                'Stored preference for upcoming motion-sensitive UI',
              ),
              value: reduceMotion,
              onChanged: (v) {
                ref.read(reduceMotionPreferenceProvider.notifier).setEnabled(v);
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MemyCard(
            child: Text(
              'Units and language live in Settings. Fuller accessibility '
              'controls are planned.',
              style: AppTextStyles.bodyMedium(color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}
