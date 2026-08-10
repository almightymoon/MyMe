import 'package:flutter/material.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/memy_page_header.dart';

/// Shared chrome for Trust Center screens (Privacy, Help, Legal, About…).
class TrustScreenScaffold extends StatelessWidget {
  const TrustScreenScaffold({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.fallbackPath,
    this.trailing,
    this.scrollable = true,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final String? fallbackPath;
  final Widget? trailing;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: title,
              subtitle: subtitle,
              leading: IconButton(
                tooltip: 'Back',
                onPressed: () =>
                    memyBack(context, fallback: fallbackPath ?? '/settings'),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              trailing: trailing,
            ),
            Expanded(
              child: scrollable
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        AppSpacing.xxxl,
                      ),
                      child: child,
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        0,
                        AppSpacing.page,
                        AppSpacing.lg,
                      ),
                      child: child,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
