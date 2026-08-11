import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_strings.dart';
import '../core/l10n/app_language.dart';
import '../features/auth/application/auth_session_controller.dart';
import '../features/trust/application/providers/trust_providers.dart';
import '../features/user/application/providers/user_providers.dart';
import 'router/app_router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

class MemyApp extends ConsumerWidget {
  const MemyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hydration = ref.watch(sessionHydrationProvider);
    if (hydration.isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModePreferenceProvider);
    final language = ref.watch(appLanguageProvider);
    AppStrings.setLanguageCode(language.code);

    return MaterialApp.router(
      title: 'MeMy',
      debugShowCheckedModeBanner: false,
      locale: language.locale,
      supportedLocales: AppLanguage.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      builder: (context, child) {
        AppColors.bindFromContext(context);
        final brightness = Theme.of(context).brightness;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: AppTheme.systemOverlayFor(brightness),
          child: child ?? const SizedBox.shrink(),
        );
      },
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
      ),
      routerConfig: router,
    );
  }
}
