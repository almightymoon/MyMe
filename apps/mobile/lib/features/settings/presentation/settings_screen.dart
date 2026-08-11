import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_navigation.dart';
import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/application/providers/core_providers.dart';
import '../../../core/config/release_capabilities.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/l10n/app_language.dart';
import '../../../core/widgets/memy_card.dart';
import '../../finance/application/providers/finance_providers.dart';
import '../../onboarding/application/onboarding_providers.dart';
import '../../onboarding/data/onboarding_preferences.dart';
import '../../trust/application/providers/trust_providers.dart';
import '../../trust/domain/entities/trust_document.dart';
import '../../user/application/providers/user_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(appVersionLabelProvider);
    final capabilities = ref.watch(releaseCapabilitiesProvider);
    final currency = ref.watch(baseCurrencyProvider);
    final units = ref.watch(measurementUnitsProvider);
    final language = ref.watch(appLanguageProvider);
    final themeMode = ref.watch(themeModePreferenceProvider);
    final appearanceValue = switch (themeMode) {
      ThemeMode.light => AppStrings.t('Light'),
      ThemeMode.dark => AppStrings.t('Dark'),
      ThemeMode.system => AppStrings.t('System'),
    };
    final unitsValue = units == MeasurementUnits.metric
        ? AppStrings.t('Metric')
        : AppStrings.t('Imperial');

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: ListView(
          key: const Key('settings_scroll'),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.xxxl,
          ),
          children: [
            Row(
              children: [
                IconButton(
                  key: const Key('settings_back'),
                  onPressed: () => memyBack(context, fallback: RoutePaths.more),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                ),
                Expanded(
                  child: Text(
                    AppStrings.t('Settings'),
                    textAlign: TextAlign.center,
                    style: AppTextStyles.titleLarge().copyWith(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _Section(
              title: AppStrings.t('Account'),
              rows: [
                _SetRow(
                  key: const Key('settings_edit_profile'),
                  icon: Icons.edit_outlined,
                  label: AppStrings.t('Edit profile'),
                  isFirst: true,
                  routePath: RoutePaths.editProfile,
                ),
                _SetRow(
                  icon: Icons.person_outline_rounded,
                  label: AppStrings.t('Profile'),
                  routePath: RoutePaths.profile,
                ),
                if (capabilities.demoAuth)
                  _SetRow(
                    icon: Icons.lock_outline_rounded,
                    label: AppStrings.t('Change Password'),
                    onTap: () => _showPasswordUnavailable(context),
                  ),
                const _SetRow(
                  icon: Icons.shield_outlined,
                  label: 'Security',
                  routePath: RoutePaths.security,
                ),
                _SetRow(
                  key: const Key('settings_connected_apps'),
                  icon: Icons.link_rounded,
                  label: AppStrings.t('Connected Apps'),
                  isLast: true,
                  routePath: RoutePaths.connectedApps,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: AppStrings.t('Preferences'),
              rows: [
                _SetRow(
                  icon: Icons.wb_sunny_outlined,
                  label: AppStrings.t('Appearance'),
                  value: appearanceValue,
                  isFirst: true,
                  routePath: RoutePaths.appearance,
                ),
                _SetRow(
                  key: const Key('settings_currency'),
                  icon: Icons.payments_outlined,
                  label: AppStrings.t('Currency'),
                  value: currency,
                  onTap: () => _pickCurrency(context, ref, currency),
                ),
                _SetRow(
                  key: const Key('settings_units'),
                  icon: Icons.straighten_rounded,
                  label: AppStrings.t('Units'),
                  value: unitsValue,
                  onTap: () => _pickUnits(context, ref, units),
                ),
                _SetRow(
                  key: const Key('settings_language'),
                  icon: Icons.language_rounded,
                  label: AppStrings.t('Language'),
                  value: language.nativeName,
                  onTap: () => _pickLanguage(context, ref, language),
                ),
                if (capabilities.notifications)
                  _SetRow(
                    icon: Icons.notifications_none_rounded,
                    label: AppStrings.t('Notifications'),
                    routePath: RoutePaths.notifications,
                  ),
                if (capabilities.wardrobe)
                  _SetRow(
                    key: const Key('settings_wardrobe'),
                    icon: Icons.checkroom_outlined,
                    label: AppStrings.t('Wardrobe'),
                    routePath: RoutePaths.wardrobeSettings,
                  ),
                _SetRow(
                  icon: Icons.privacy_tip_outlined,
                  label: AppStrings.t('Privacy'),
                  isLast: true,
                  routePath: RoutePaths.privacy,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _Section(
              title: AppStrings.t('More'),
              rows: [
                _SetRow(
                  icon: Icons.help_outline_rounded,
                  label: AppStrings.t('Help & Support'),
                  isFirst: true,
                  routePath: RoutePaths.support,
                ),
                _SetRow(
                  icon: Icons.description_outlined,
                  label: AppStrings.t('Terms & Conditions'),
                  routePath: RoutePaths.legalDocumentPath(
                    TrustDocumentType.termsOfUse.name,
                  ),
                ),
                _SetRow(
                  icon: Icons.policy_outlined,
                  label: AppStrings.t('Privacy Policy'),
                  routePath: RoutePaths.legalDocumentPath(
                    TrustDocumentType.privacyPolicy.name,
                  ),
                ),
                _SetRow(
                  icon: Icons.info_outline_rounded,
                  label: AppStrings.t('About MeMy'),
                  value: version.when(
                    data: (v) => v,
                    loading: () => '…',
                    error: (_, _) => '',
                  ),
                  routePath: RoutePaths.about,
                ),
                _SetRow(
                  key: const Key('settings_reset_onboarding'),
                  icon: Icons.restart_alt_rounded,
                  label: AppStrings.t('Reset onboarding'),
                  isLast: true,
                  onTap: () => _confirmResetOnboarding(context, ref),
                ),
              ],
            ),
            if (capabilities.showSignOut) ...[
              const SizedBox(height: AppSpacing.lg),
              MemyCard(
                key: const Key('settings_logout'),
                onTap: () => context.go(RoutePaths.signIn),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 18,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: AppColors.health),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.t('Log Out'),
                      style: AppTextStyles.titleMedium(
                        color: AppColors.health,
                      ).copyWith(fontSize: 15),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickCurrency(
    BuildContext context,
    WidgetRef ref,
    String current,
  ) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  AppStrings.t('Currency'),
                  style: AppTextStyles.titleMedium().copyWith(fontSize: 16),
                ),
              ),
              for (final code in OnboardingPreferences.supportedCurrencies)
                ListTile(
                  key: Key('settings_currency_$code'),
                  title: Text(code),
                  trailing: code == current
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, code),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == current || !context.mounted) return;

    final prefs = ref.read(sharedPreferencesProvider);
    await OnboardingPreferences.writeBaseCurrency(prefs, selected);
    await ref.read(financeRepositoryProvider).setBaseCurrencyCode(selected);
    ref.read(profileTickProvider.notifier).state++;

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'New amounts use $selected. Existing entries keep their original currency.',
        ),
        duration: const Duration(milliseconds: 2200),
      ),
    );
  }

  Future<void> _pickUnits(
    BuildContext context,
    WidgetRef ref,
    MeasurementUnits current,
  ) async {
    final selected = await showModalBottomSheet<MeasurementUnits>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  AppStrings.t('Units'),
                  style: AppTextStyles.titleMedium().copyWith(fontSize: 16),
                ),
              ),
              for (final units in MeasurementUnits.values)
                ListTile(
                  key: Key('settings_units_${units.name}'),
                  title: Text(
                    units == MeasurementUnits.metric
                        ? AppStrings.t('Metric')
                        : AppStrings.t('Imperial'),
                  ),
                  subtitle: Text(
                    units == MeasurementUnits.metric
                        ? AppStrings.t('°C, kg, km')
                        : AppStrings.t('°F, lb, mi'),
                  ),
                  trailing: units == current
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, units),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (selected == null || selected == current || !context.mounted) return;

    final prefs = ref.read(sharedPreferencesProvider);
    await OnboardingPreferences.writeUnits(prefs, selected);
    ref.read(profileTickProvider.notifier).state++;
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    AppLanguage current,
  ) async {
    final selected = await showModalBottomSheet<AppLanguage>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    AppStrings.t('Language'),
                    style: AppTextStyles.titleMedium().copyWith(fontSize: 16),
                  ),
                ),
                for (final language in AppLanguage.supported)
                  ListTile(
                    key: Key('settings_language_${language.code}'),
                    title: Text(language.nativeName),
                    subtitle: language.code == 'en'
                        ? null
                        : Text(language.englishName),
                    trailing: language.code == current.code
                        ? const Icon(Icons.check_rounded)
                        : null,
                    onTap: () => Navigator.pop(sheetContext, language),
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
    if (selected == null || selected.code == current.code || !context.mounted) {
      return;
    }

    final prefs = ref.read(sharedPreferencesProvider);
    await OnboardingPreferences.writeLanguage(prefs, selected.code);
    AppStrings.setLanguageCode(selected.code);
    ref.read(profileTickProvider.notifier).state++;
  }

  Future<void> _confirmResetOnboarding(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('settings_reset_onboarding_dialog'),
        title: const Text('Reset onboarding?'),
        content: const Text(
          'Setup will run again the next time you open MeMy. Your goals, '
          'transactions, habits and preferences are not deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('settings_reset_onboarding_confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    await ref.read(onboardingCompletionProvider.notifier).reset();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Onboarding will run again on next launch.'),
        duration: Duration(milliseconds: 1600),
      ),
    );
  }

  void _showPasswordUnavailable(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: const Text(
          'Password change is not available in this demo auth build. '
          'A production authentication provider will unlock this later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<_SetRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: AppTextStyles.bodySmall().copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.faintText,
            ),
          ),
        ),
        MemyCard(
          padding: EdgeInsets.zero,
          child: Column(children: rows),
        ),
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.isFirst = false,
    this.isLast = false,
    this.routePath,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String? value;
  final bool isFirst;
  final bool isLast;
  final String? routePath;
  final VoidCallback? onTap;

  BorderRadius get _inkRadius {
    if (isFirst && isLast) return AppRadii.cardRadius;
    if (isFirst) {
      return const BorderRadius.vertical(top: Radius.circular(AppRadii.card));
    }
    if (isLast) {
      return const BorderRadius.vertical(
        bottom: Radius.circular(AppRadii.card),
      );
    }
    return BorderRadius.zero;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
            return;
          }
          if (routePath != null) {
            context.push(routePath!);
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label — planned'),
              duration: const Duration(milliseconds: 1200),
            ),
          );
        },
        borderRadius: _inkRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: isLast
                ? null
                : const Border(bottom: BorderSide(color: Color(0x0D000000))),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.ember),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: AppTextStyles.bodyMedium())),
              if (value != null)
                Text(
                  value!,
                  style: AppTextStyles.bodySmall(
                    color: AppColors.faintText,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: AppColors.navInactive),
            ],
          ),
        ),
      ),
    );
  }
}
