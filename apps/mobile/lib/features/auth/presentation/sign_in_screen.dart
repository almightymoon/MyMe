import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  // Prefill credentials only in debug/profile demo builds — never in release.
  late final _emailController = TextEditingController(
    text: kReleaseMode ? '' : 'emma@memy.app',
  );
  late final _passwordController = TextEditingController(
    text: kReleaseMode ? '' : 'memy2026',
  );
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter email and password to continue.');
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
                  padding: const EdgeInsets.fromLTRB(28, 52, 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        AppStrings.appName,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayLarge(
                          color: AppColors.ember,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.tagline,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium(
                          color: AppColors.primaryText,
                        ).copyWith(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 12),
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
                      const SizedBox(height: 18),
                      Center(
                        child: SvgPicture.asset(
                          'assets/images/branding/logo.svg',
                          width: 148,
                          height: 123,
                          placeholderBuilder: (_) =>
                              const SizedBox(width: 148, height: 123),
                        ),
                      ),
                      const SizedBox(height: 22),
                      AuthGlassField(
                        controller: _emailController,
                        hint: AppStrings.emailOrPhoneHint,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.username],
                      ),
                      AuthGlassField(
                        controller: _passwordController,
                        hint: AppStrings.passwordLabel,
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _signIn(),
                        autofillHints: const [AutofillHints.password],
                        suffix: IconButton(
                          tooltip: _obscure ? 'Show password' : 'Hide password',
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 18,
                            color: _obscure
                                ? AppColors.faintText
                                : AppColors.ember,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          key: const Key('auth_forgot_link'),
                          onPressed: () =>
                              context.push(RoutePaths.forgotPassword),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.ember,
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            AppStrings.forgotPassword,
                            style: AppTextStyles.bodySmall(
                              color: AppColors.ember,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_error != null) ...[
                        Text(
                          _error!,
                          style: AppTextStyles.bodySmall(
                            color: AppColors.health,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                      ],
                      MemyPrimaryButton(
                        key: const Key('continue_to_memy'),
                        label: AppStrings.signIn,
                        onPressed: _signIn,
                      ),
                    ],
                  ),
                ),
              ),
              AuthWaveButton(
                key: const Key('auth_go_signup'),
                label: AppStrings.signUp,
                onPressed: () => context.push(RoutePaths.signUp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
