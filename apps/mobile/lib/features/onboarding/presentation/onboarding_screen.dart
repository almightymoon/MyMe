import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/application/providers/core_providers.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/l10n/app_language.dart';
import '../../../core/widgets/memy_card.dart';
import '../../../core/widgets/memy_primary_button.dart';
import '../application/onboarding_providers.dart';
import '../data/onboarding_preferences.dart';
import '../../user/domain/entities/profile_avatar.dart';
import '../../user/presentation/widgets/profile_avatar_view.dart';

/// Local first-run setup. No account, no network, no permission prompts —
/// the Calendar and Health steps only offer to open their connection screens.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Step { welcome, privacy, preferences, calendar, health, finish }

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();

  _Step _step = _Step.welcome;
  late String _currency;
  late AppLanguage _language;
  late MeasurementUnits _units;
  late WeekStart _weekStart;
  late String _timezone;
  late String _avatarId;
  bool _avatarChosen = false;
  String? _avatarError;
  bool _finishing = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _currency = OnboardingPreferences.readBaseCurrency(prefs);
    _language = OnboardingPreferences.readLanguage(prefs);
    _units = OnboardingPreferences.readUnits(prefs);
    _weekStart = OnboardingPreferences.readWeekStart(prefs);
    _timezone = OnboardingPreferences.readTimezone(prefs);
    _nameController.text = OnboardingPreferences.readDisplayName(prefs) ?? '';
    _avatarId = OnboardingPreferences.readAvatarId(prefs);
    _avatarChosen = prefs.containsKey(OnboardingPreferences.avatarIdKey);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _goTo(_Step step) => setState(() => _step = step);

  void _next() {
    final index = _step.index;
    if (index >= _Step.values.length - 1) return;
    _goTo(_Step.values[index + 1]);
  }

  void _back() {
    final index = _step.index;
    if (index == 0) return;
    _goTo(_Step.values[index - 1]);
  }

  Future<void> _savePreferences() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await OnboardingPreferences.writeBaseCurrency(prefs, _currency);
    await OnboardingPreferences.writeLanguage(prefs, _language.code);
    await OnboardingPreferences.writeUnits(prefs, _units);
    await OnboardingPreferences.writeWeekStart(prefs, _weekStart);
    await OnboardingPreferences.writeTimezone(prefs, _timezone);
    await OnboardingPreferences.writeDisplayName(prefs, _nameController.text);
    await OnboardingPreferences.writeAvatarId(prefs, _avatarId);
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final router = GoRouter.of(context);
    await _savePreferences();
    await ref.read(onboardingCompletionProvider.notifier).markComplete();
    if (!mounted) return;
    router.go(RoutePaths.today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('onboarding_screen'),
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _StepIndicator(step: _step.index, total: _Step.values.length),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  AppSpacing.xxxl,
                ),
                child: switch (_step) {
                  _Step.welcome => _buildWelcome(),
                  _Step.privacy => _buildPrivacy(),
                  _Step.preferences => _buildPreferences(),
                  _Step.calendar => _buildCalendar(),
                  _Step.health => _buildHealth(),
                  _Step.finish => _buildFinish(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return _StepBody(
      title: AppStrings.appName,
      subtitle: AppStrings.productTagline,
      body: Text(
        'MeMy keeps your goals, money, habits, calendar, health and exercise '
        'in one place. Everything you record stays on this device.',
        style: AppTextStyles.bodyMedium(color: AppColors.secondaryText),
      ),
      primaryLabel: 'Get started',
      primaryKey: const Key('onboarding_welcome_next'),
      onPrimary: _next,
    );
  }

  Widget _buildPrivacy() {
    return _StepBody(
      title: 'Your data stays here',
      subtitle: 'Local-first by default',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _Bullet('Everything you enter is stored on this device only.'),
          _Bullet('No MeMy account, no cloud sync, no advertising.'),
          _Bullet(
            'Calendar and Health are read with your permission and are '
            'never uploaded.',
          ),
          _Bullet(
            'You can export a copy or delete everything from '
            'Privacy & Data at any time.',
          ),
        ],
      ),
      primaryLabel: 'Continue',
      primaryKey: const Key('onboarding_privacy_next'),
      onPrimary: _next,
      onBack: _back,
    );
  }

  Widget _buildPreferences() {
    return _StepBody(
      title: AppStrings.t('Set your basics'),
      subtitle: AppStrings.t('You can change these later in Settings'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldLabel(AppStrings.t('Base currency')),
          DropdownButtonFormField<String>(
            key: const Key('onboarding_currency'),
            initialValue: _currency,
            decoration: _fieldDecoration(),
            items: [
              for (final code in OnboardingPreferences.supportedCurrencies)
                DropdownMenuItem(value: code, child: Text(code)),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() => _currency = value);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _FieldLabel(AppStrings.t('Language')),
          DropdownButtonFormField<String>(
            key: const Key('onboarding_language'),
            initialValue: _language.code,
            decoration: _fieldDecoration(),
            items: [
              for (final language in AppLanguage.supported)
                DropdownMenuItem(
                  value: language.code,
                  child: Text(language.nativeName),
                ),
            ],
            onChanged: (value) {
              if (value == null) return;
              setState(() {
                _language = AppLanguage.resolve(value);
                AppStrings.setLanguageCode(_language.code);
              });
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _FieldLabel(AppStrings.t('Units')),
          SegmentedButton<MeasurementUnits>(
            key: const Key('onboarding_units'),
            segments: [
              ButtonSegment(
                value: MeasurementUnits.metric,
                label: Text(AppStrings.t('Metric')),
              ),
              ButtonSegment(
                value: MeasurementUnits.imperial,
                label: Text(AppStrings.t('Imperial')),
              ),
            ],
            selected: {_units},
            onSelectionChanged: (value) => setState(() => _units = value.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          _FieldLabel(AppStrings.t('Week starts on')),
          SegmentedButton<WeekStart>(
            key: const Key('onboarding_week_start'),
            segments: [
              ButtonSegment(
                value: WeekStart.monday,
                label: Text(AppStrings.t('Monday')),
              ),
              ButtonSegment(
                value: WeekStart.sunday,
                label: Text(AppStrings.t('Sunday')),
              ),
            ],
            selected: {_weekStart},
            onSelectionChanged: (value) =>
                setState(() => _weekStart = value.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          _FieldLabel(AppStrings.t('Time zone')),
          MemyCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Icon(Icons.schedule_rounded, size: 20, color: AppColors.ember),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _timezone,
                    key: const Key('onboarding_timezone'),
                    style: AppTextStyles.bodyMedium(),
                  ),
                ),
                Text(
                  'Detected',
                  style: AppTextStyles.bodySmall(color: AppColors.faintText),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _FieldLabel('Display name (optional)'),
          TextField(
            key: const Key('onboarding_display_name'),
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _fieldDecoration(
              hintText: 'What should MeMy call you?',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _FieldLabel('Avatar'),
          Text(
            'Pick one of these. MeMy does not use a profile photo.',
            style: AppTextStyles.bodySmall(color: AppColors.faintText),
          ),
          if (_avatarError != null) ...[
            const SizedBox(height: 6),
            Text(
              _avatarError!,
              key: const Key('onboarding_avatar_error'),
              style: AppTextStyles.bodySmall(color: AppColors.health),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          ProfileAvatarPicker(
            selectedId: _avatarChosen
                ? ProfileAvatarCatalog.resolve(_avatarId)
                : '',
            onSelected: (id) => setState(() {
              _avatarId = id;
              _avatarChosen = true;
              _avatarError = null;
            }),
          ),
        ],
      ),
      primaryLabel: 'Continue',
      primaryKey: const Key('onboarding_preferences_next'),
      onPrimary: () async {
        if (!_avatarChosen) {
          setState(() => _avatarError = 'Choose an avatar to continue');
          return;
        }
        await _savePreferences();
        if (mounted) _next();
      },
      onBack: _back,
    );
  }

  Widget _buildCalendar() {
    return _StepBody(
      title: 'Connect your calendar',
      subtitle: 'Optional',
      body: Text(
        'MeMy can read your device calendar so Today and Plan show your real '
        'agenda. Nothing is read until you grant permission on the next '
        'screen, and you can skip this and connect later.',
        style: AppTextStyles.bodyMedium(color: AppColors.secondaryText),
      ),
      primaryLabel: 'Connect calendar',
      primaryKey: const Key('onboarding_calendar_connect'),
      onPrimary: () => context.push(RoutePaths.calendarConnect),
      secondaryLabel: 'Skip for now',
      secondaryKey: const Key('onboarding_calendar_skip'),
      onSecondary: _next,
      onBack: _back,
    );
  }

  Widget _buildHealth() {
    return _StepBody(
      title: 'Connect Health',
      subtitle: 'Optional',
      body: Text(
        'MeMy can read steps, activity and sleep from Apple Health or Health '
        'Connect. Read-only — MeMy never writes to platform Health, and '
        'nothing is read until you grant permission.',
        style: AppTextStyles.bodyMedium(color: AppColors.secondaryText),
      ),
      primaryLabel: 'Connect Health',
      primaryKey: const Key('onboarding_health_connect'),
      onPrimary: () => context.push(RoutePaths.healthConnect),
      secondaryLabel: 'Skip for now',
      secondaryKey: const Key('onboarding_health_skip'),
      onSecondary: _next,
      onBack: _back,
    );
  }

  Widget _buildFinish() {
    return _StepBody(
      title: "You're all set",
      subtitle: 'Everything below is ready to use',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _Bullet('Track goals with progress and forecasts.'),
          _Bullet('Log income and expenses in your base currency.'),
          _Bullet('Build habits and keep streaks.'),
          _Bullet('See your calendar, health and exercise in one place.'),
        ],
      ),
      primaryLabel: 'Open Today',
      primaryKey: const Key('onboarding_finish'),
      onPrimary: _finishing ? null : _finish,
      onBack: _finishing ? null : _back,
    );
  }

  InputDecoration _fieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: AppRadii.controlRadius,
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.primaryKey,
    required this.onPrimary,
    this.subtitle,
    this.secondaryLabel,
    this.secondaryKey,
    this.onSecondary,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final String primaryLabel;
  final Key primaryKey;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final Key? secondaryKey;
  final VoidCallback? onSecondary;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (subtitle != null) ...[
          Text(
            subtitle!,
            style: AppTextStyles.bodySmall(
              color: AppColors.ember,
            ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.4),
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Text(title, style: AppTextStyles.displayMedium()),
        const SizedBox(height: AppSpacing.lg),
        body,
        const SizedBox(height: AppSpacing.xxl),
        MemyPrimaryButton(
          key: primaryKey,
          label: primaryLabel,
          onPressed: onPrimary,
        ),
        if (secondaryLabel != null) ...[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            key: secondaryKey,
            onPressed: onSecondary,
            child: Text(secondaryLabel!),
          ),
        ],
        if (onBack != null) ...[
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            key: const Key('onboarding_back'),
            onPressed: onBack,
            child: const Text('Back'),
          ),
        ],
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.page,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          for (var i = 0; i < total; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= step ? AppColors.ember : AppColors.line,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
            if (i < total - 1) const SizedBox(width: AppSpacing.xs),
          ],
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
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 18,
              color: AppColors.ember,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium(color: AppColors.secondaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
      child: Text(
        text,
        style: AppTextStyles.bodySmall(
          color: AppColors.faintText,
        ).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
