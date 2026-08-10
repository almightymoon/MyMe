import 'package:flutter/material.dart';

import '../../app/router/app_navigation.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/constants/app_strings.dart';
import '../../features/shell/presentation/memy_bottom_navigation.dart';
import '../../features/shell/presentation/quick_add_sheet.dart';

class ComingSoonView extends StatelessWidget {
  const ComingSoonView({
    super.key,
    required this.featureName,
    required this.explanation,
    this.onBack,
    this.showBottomNav = false,
    this.navIndex = 1,
    this.fallbackPath = RoutePaths.today,
  });

  final String featureName;
  final String explanation;
  final VoidCallback? onBack;
  final bool showBottomNav;
  final int navIndex;
  final String fallbackPath;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const Key('coming_soon_back'),
              onPressed:
                  onBack ?? () => memyBack(context, fallback: fallbackPath),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text(AppStrings.back),
            ),
          ),
          const Spacer(),
          Icon(
            Icons.hourglass_empty_rounded,
            size: 56,
            color: AppColors.ember,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            featureName,
            style: AppTextStyles.displayMedium(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.comingSoon,
            style: AppTextStyles.kicker(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            explanation,
            style: AppTextStyles.bodyLarge(color: AppColors.secondaryText),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );

    if (!showBottomNav) return content;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      extendBody: true,
      body: SafeArea(bottom: false, child: content),
      bottomNavigationBar: MemyBottomNavigation(
        currentIndex: navIndex,
        onDestinationSelected: (index) => memyGoShellTab(context, index),
        onQuickAddPressed: () => showQuickAddSheet(context),
      ),
    );
  }
}
