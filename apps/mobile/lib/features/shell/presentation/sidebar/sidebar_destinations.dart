import 'package:flutter/material.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/config/release_capabilities.dart';
import '../../../trust/domain/entities/sidebar_destination.dart';

/// Canonical MeMy sidebar destinations (trust/support IA).
abstract final class SidebarDestinations {
  static const List<SidebarDestination> all = [
    ...primary,
    ...lifeAreas,
    ...connections,
    ...trustHelp,
  ];

  static const List<SidebarDestination> primary = [
    SidebarDestination(
      id: 'today',
      label: 'Today',
      icon: Icons.wb_sunny_outlined,
      shellTabIndex: 0,
      routePath: RoutePaths.today,
      section: SidebarSectionId.primary,
      availability: SidebarAvailability.available,
      semanticLabel: 'Today',
      keyName: 'drawer_today',
    ),
    SidebarDestination(
      id: 'plan',
      label: 'Plan',
      icon: Icons.grid_view_rounded,
      shellTabIndex: 1,
      routePath: RoutePaths.plan,
      section: SidebarSectionId.primary,
      availability: SidebarAvailability.available,
      semanticLabel: 'Plan',
      keyName: 'drawer_plan',
    ),
    SidebarDestination(
      id: 'coach',
      label: 'Coach Preview',
      icon: Icons.shield_outlined,
      shellTabIndex: 2,
      routePath: RoutePaths.coach,
      section: SidebarSectionId.primary,
      availability: SidebarAvailability.demo,
      badgeLabel: 'Preview',
      semanticLabel: 'Coach Preview, local demo',
      keyName: 'drawer_coach',
    ),
  ];

  static const List<SidebarDestination> lifeAreas = [
    SidebarDestination(
      id: 'goals',
      label: 'Goals',
      icon: Icons.track_changes_outlined,
      routePath: RoutePaths.goals,
      section: SidebarSectionId.lifeAreas,
      availability: SidebarAvailability.available,
      semanticLabel: 'Goals',
      keyName: 'drawer_goals',
    ),
    SidebarDestination(
      id: 'finance',
      label: 'Finance',
      icon: Icons.account_balance_wallet_outlined,
      routePath: RoutePaths.finance,
      section: SidebarSectionId.lifeAreas,
      availability: SidebarAvailability.available,
      semanticLabel: 'Finance',
      keyName: 'drawer_finance',
    ),
    SidebarDestination(
      id: 'habits',
      label: 'Habits',
      icon: Icons.local_fire_department_rounded,
      section: SidebarSectionId.lifeAreas,
      availability: SidebarAvailability.available,
      semanticLabel: 'Habits',
      keyName: 'drawer_habits',
    ),
    SidebarDestination(
      id: 'calendar',
      label: 'Calendar',
      icon: Icons.calendar_today_outlined,
      routePath: RoutePaths.calendar,
      section: SidebarSectionId.lifeAreas,
      availability: SidebarAvailability.available,
      semanticLabel: 'Calendar',
      keyName: 'drawer_calendar',
    ),
    SidebarDestination(
      id: 'health',
      label: 'Health',
      icon: Icons.favorite_border_rounded,
      routePath: RoutePaths.health,
      section: SidebarSectionId.lifeAreas,
      availability: SidebarAvailability.available,
      semanticLabel: 'Health',
      keyName: 'drawer_health',
    ),
    SidebarDestination(
      id: 'exercise',
      label: 'Exercise',
      icon: Icons.fitness_center_outlined,
      routePath: RoutePaths.exercise,
      section: SidebarSectionId.lifeAreas,
      availability: SidebarAvailability.available,
      semanticLabel: 'Exercise',
      keyName: 'drawer_exercise',
    ),
    SidebarDestination(
      id: 'wardrobe',
      label: 'Wardrobe',
      icon: Icons.checkroom_outlined,
      routePath: RoutePaths.wardrobe,
      section: SidebarSectionId.lifeAreas,
      availability: SidebarAvailability.available,
      semanticLabel: 'Wardrobe',
      keyName: 'drawer_wardrobe',
    ),
    SidebarDestination(
      id: 'body',
      label: 'Body',
      icon: Icons.accessibility_new_rounded,
      routePath: RoutePaths.body,
      section: SidebarSectionId.lifeAreas,
      availability: SidebarAvailability.available,
      semanticLabel: 'Body',
      keyName: 'drawer_body',
    ),
  ];

  static const List<SidebarDestination> connections = [
    SidebarDestination(
      id: 'connected_apps',
      label: 'Connected Apps',
      icon: Icons.link_rounded,
      routePath: RoutePaths.connectedApps,
      section: SidebarSectionId.connections,
      availability: SidebarAvailability.available,
      semanticLabel: 'Connected Apps',
      keyName: 'drawer_connected_apps',
    ),
    SidebarDestination(
      id: 'notifications',
      label: 'Notifications',
      icon: Icons.notifications_none_rounded,
      routePath: RoutePaths.notifications,
      section: SidebarSectionId.connections,
      availability: SidebarAvailability.planned,
      badgeLabel: 'Planned',
      semanticLabel: 'Notifications, planned',
      keyName: 'drawer_notifications',
    ),
    SidebarDestination(
      id: 'appearance',
      label: 'Appearance',
      icon: Icons.contrast_rounded,
      routePath: RoutePaths.appearance,
      section: SidebarSectionId.connections,
      availability: SidebarAvailability.available,
      semanticLabel: 'Appearance',
      keyName: 'drawer_appearance',
    ),
    SidebarDestination(
      id: 'settings',
      label: 'Settings',
      icon: Icons.settings_outlined,
      routePath: RoutePaths.settings,
      section: SidebarSectionId.connections,
      availability: SidebarAvailability.available,
      semanticLabel: 'Settings',
      keyName: 'drawer_settings',
    ),
  ];

  static const List<SidebarDestination> trustHelp = [
    SidebarDestination(
      id: 'privacy',
      label: 'Privacy & Data',
      icon: Icons.privacy_tip_outlined,
      routePath: RoutePaths.privacy,
      section: SidebarSectionId.trustHelp,
      availability: SidebarAvailability.available,
      semanticLabel: 'Privacy and Data',
      keyName: 'drawer_privacy',
    ),
    SidebarDestination(
      id: 'security',
      label: 'Security',
      icon: Icons.shield_outlined,
      routePath: RoutePaths.security,
      section: SidebarSectionId.trustHelp,
      availability: SidebarAvailability.available,
      semanticLabel: 'Security',
      keyName: 'drawer_security',
    ),
    SidebarDestination(
      id: 'support',
      label: 'Help & Support',
      icon: Icons.help_outline_rounded,
      routePath: RoutePaths.support,
      section: SidebarSectionId.trustHelp,
      availability: SidebarAvailability.available,
      semanticLabel: 'Help and Support',
      keyName: 'drawer_help',
    ),
    SidebarDestination(
      id: 'legal',
      label: 'Legal',
      icon: Icons.description_outlined,
      routePath: RoutePaths.legal,
      section: SidebarSectionId.trustHelp,
      availability: SidebarAvailability.available,
      semanticLabel: 'Legal',
      keyName: 'drawer_legal',
    ),
    SidebarDestination(
      id: 'about',
      label: 'About MeMy',
      icon: Icons.info_outline_rounded,
      routePath: RoutePaths.about,
      section: SidebarSectionId.trustHelp,
      availability: SidebarAvailability.available,
      semanticLabel: 'About MeMy',
      keyName: 'drawer_about',
    ),
  ];

  static List<SidebarDestination> forSection(SidebarSectionId section) {
    return switch (section) {
      SidebarSectionId.account => const [],
      SidebarSectionId.primary => primary,
      SidebarSectionId.lifeAreas => lifeAreas,
      SidebarSectionId.connections => connections,
      SidebarSectionId.trustHelp => trustHelp,
    };
  }

  /// Section contents filtered down to what this build is allowed to ship.
  ///
  /// Production drops Coach Preview, Wardrobe, Body and every "Planned" row,
  /// leaving Today/Plan, the six live life areas, Connected Apps, Appearance,
  /// Settings and the trust/help group.
  static List<SidebarDestination> visibleForSection(
    SidebarSectionId section,
    ReleaseCapabilities capabilities,
  ) {
    return [
      for (final destination in forSection(section))
        if (_isVisible(destination, capabilities)) destination,
    ];
  }

  static bool _isVisible(
    SidebarDestination destination,
    ReleaseCapabilities capabilities,
  ) {
    if (destination.isPlanned && !capabilities.plannedSidebarItems) {
      return false;
    }
    return switch (destination.id) {
      'coach' => capabilities.coachPreview,
      'wardrobe' => capabilities.wardrobe,
      'body' => capabilities.body,
      'notifications' => capabilities.notifications,
      _ => true,
    };
  }

  static String titleFor(SidebarSectionId section) {
    return switch (section) {
      SidebarSectionId.account => 'Account',
      SidebarSectionId.primary => 'Primary',
      SidebarSectionId.lifeAreas => 'Life Areas',
      SidebarSectionId.connections => 'Connections & Preferences',
      SidebarSectionId.trustHelp => 'Trust & Help',
    };
  }
}
