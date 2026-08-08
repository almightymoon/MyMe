import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_radii.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/memy_primary_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController(text: 'emma@memy.app');
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _continue() {
    context.go(RoutePaths.today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.canvas, Color(0xFFF3EEE4), AppColors.canvasDeep],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.page,
                  vertical: AppSpacing.xl,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.ember.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                AppRadii.pill,
                              ),
                            ),
                            child: Text(
                              AppStrings.demoMode,
                              style: AppTextStyles.kicker(),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Center(
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.asset(
                                  'assets/images/branding/logo-mark.png',
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    width: 96,
                                    height: 96,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: AppColors.ember,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      'M',
                                      style: AppTextStyles.displayMedium(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                AppStrings.appName,
                                style: AppTextStyles.displayLarge(),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                AppStrings.tagline,
                                style: AppTextStyles.bodyMedium(),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        Text(
                          AppStrings.welcomeHeading,
                          style: AppTextStyles.titleLarge(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          AppStrings.demoAuthNote,
                          style: AppTextStyles.bodySmall(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: AppStrings.emailLabel,
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscure,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _continue(),
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: AppStrings.passwordLabel,
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              tooltip: _obscure
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        MemyPrimaryButton(
                          key: const Key('continue_to_memy'),
                          label: AppStrings.continueToMemy,
                          onPressed: _continue,
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          '${AppStrings.company} · ${AppStrings.appName}',
                          style: AppTextStyles.labelSmall(),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
