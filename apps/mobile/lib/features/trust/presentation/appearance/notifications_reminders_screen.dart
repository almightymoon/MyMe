import 'package:flutter/material.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/memy_card.dart';
import '../widgets/trust_screen_scaffold.dart';

/// Notifications are planned — no live toggles in this build.
class NotificationsRemindersScreen extends StatelessWidget {
  const NotificationsRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TrustScreenScaffold(
      key: const Key('notifications_reminders'),
      title: 'Notifications',
      subtitle: 'Planned feature',
      fallbackPath: RoutePaths.settings,
      child: MemyCard(
        child: Text(
          'Push notifications and reminders are not available yet. '
          'There are no notification toggles in this build so nothing '
          'appears enabled by mistake.',
          style: AppTextStyles.bodyMedium(color: AppColors.secondaryText),
        ),
      ),
    );
  }
}
