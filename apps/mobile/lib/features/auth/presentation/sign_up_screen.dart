import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/memy_primary_button.dart';
import 'widgets/auth_atmosphere.dart';
import 'widgets/auth_glass_field.dart';
import 'widgets/auth_wave_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final _nameController = TextEditingController(
    text: kReleaseMode ? '' : 'Emma Chen',
  );
  late final _emailController = TextEditingController(
    text: kReleaseMode ? '' : 'emma@memy.app',
  );
  late final _passwordController = TextEditingController(
    text: kReleaseMode ? '' : 'memy2026',
  );
  late final _confirmController = TextEditingController(
    text: kReleaseMode ? '' : 'memy2026',
  );
  bool _obscure = true;
  bool _acceptedTerms = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _signUp() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Fill in all fields to create your account.');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }
    if (!_acceptedTerms) {
      setState(() => _error = 'Accept the terms to continue.');
      return;
    }
    setState(() => _error = null);
    context.go(RoutePaths.today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthAtmosphere(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 44, 28, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          _AuthBackButton(
                            onPressed: () => context.go(RoutePaths.signIn),
                          ),
                          Expanded(
                            child: Text(
                              AppStrings.appName,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.titleMedium(
                                color: AppColors.ember,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Semantics(
                        label: AppStrings.demoAuthNote,
                        child: Container(
                          key: const Key('demo_auth_notice'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.orangeSoft.withValues(alpha: 0.85),
                            borderRadius: AppRadii.controlRadius,
                            border: Border.all(
                              color: AppColors.ember.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Text(
                            AppStrings.demoAuthNote,
                            textAlign: TextAlign.center,
                            style:
                                AppTextStyles.bodySmall(
                                  color: AppColors.emberDark,
                                ).copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppStrings.createAccountTitle,
                        style: AppTextStyles.displayMedium(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.createAccountSubtitle,
                        style: AppTextStyles.bodyMedium(),
                      ),
                      const SizedBox(height: 22),
                      AuthGlassField(
                        controller: _nameController,
                        hint: AppStrings.fullNameHint,
                        prefixIcon: Icons.person_outline_rounded,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.name],
                      ),
                      AuthGlassField(
                        controller: _emailController,
                        hint: AppStrings.emailLabel,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                      ),
                      AuthGlassField(
                        controller: _passwordController,
                        hint: AppStrings.passwordLabel,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        suffix: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: AppColors.faintText,
                          ),
                        ),
                      ),
                      AuthGlassField(
                        controller: _confirmController,
                        hint: AppStrings.confirmPasswordHint,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _signUp(),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Checkbox(
                              value: _acceptedTerms,
                              activeColor: AppColors.ember,
                              onChanged: (value) => setState(
                                () => _acceptedTerms = value ?? false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppStrings.acceptTerms,
                              style: AppTextStyles.bodySmall(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: AppTextStyles.bodySmall(
                            color: AppColors.health,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      MemyPrimaryButton(
                        key: const Key('signup_submit'),
                        label: AppStrings.signUp,
                        onPressed: _signUp,
                      ),
                    ],
                  ),
                ),
              ),
              AuthWaveButton(
                key: const Key('auth_go_signin'),
                label: AppStrings.signIn,
                onPressed: () => context.go(RoutePaths.signIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthBackButton extends StatelessWidget {
  const _AuthBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.hairline,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.chevron_left_rounded, size: 22),
        ),
      ),
    );
  }
}
