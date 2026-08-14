import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_names.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import 'widgets/auth_atmosphere.dart';
import 'widgets/auth_glass_field.dart';
import 'widgets/auth_wave_button.dart';
import '../../../app/theme/app_radii.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendReset() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _error = 'Enter your email or phone.';
        _sent = false;
      });
      return;
    }
    setState(() {
      _error = null;
      _sent = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(AppStrings.resetLinkSentDemo)));
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
                          Material(
                            color: AppColors.hairline,
                            shape: const CircleBorder(),
                            child: InkWell(
                              key: const Key('forgot_back'),
                              customBorder: const CircleBorder(),
                              onTap: () => context.go(RoutePaths.signIn),
                              child: const SizedBox(
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.chevron_left_rounded,
                                  size: 22,
                                ),
                              ),
                            ),
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
                      const SizedBox(height: 36),
                      Center(
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppColors.orangeSoft,
                            borderRadius: AppRadii.cardRadius,
                            boxShadow: AppColors.softShadow,
                          ),
                          child: Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.ember,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        AppStrings.forgotPasswordTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.displayMedium(),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppStrings.forgotPasswordSubtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium(),
                      ),
                      const SizedBox(height: 22),
                      AuthGlassField(
                        controller: _emailController,
                        hint: AppStrings.emailOrPhoneHint,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _sendReset(),
                      ),
                      if (_error != null)
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall(
                            color: AppColors.health,
                          ),
                        ),
                      if (_sent)
                        Text(
                          AppStrings.resetLinkSentDemo,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall(
                            color: AppColors.finance,
                          ),
                        ),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Remembered it? ',
                              style: AppTextStyles.bodySmall(),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.baseline,
                              baseline: TextBaseline.alphabetic,
                              child: GestureDetector(
                                onTap: () => context.go(RoutePaths.signIn),
                                child: Text(
                                  'Back to sign in',
                                  style: AppTextStyles.bodySmall(
                                    color: AppColors.ember,
                                  ).copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              AuthWaveButton(
                key: const Key('forgot_send'),
                label: AppStrings.sendResetLink,
                onPressed: _sendReset,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
