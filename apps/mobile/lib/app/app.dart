import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/trust/application/providers/trust_providers.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class MemyApp extends ConsumerWidget {
  const MemyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModePreferenceProvider);

    return MaterialApp.router(
      title: 'MeMy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      themeMode: themeMode == ThemeMode.light
          ? ThemeMode.light
          : ThemeMode.system,
      // Mobile-style: no desktop/web scrollbar gutter on the right edge.
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
      ),
      routerConfig: router,
    );
  }
}
