import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'environment_config.dart';

/// What the current build is allowed to show and do.
///
/// This is the single place the UI asks "is this shippable?" so the v1 feature
/// freeze is enforced by configuration instead of by scattered `kDebugMode`
/// checks. Derive with [ReleaseCapabilities.fromEnvironment]; read in widgets
/// through [releaseCapabilitiesProvider].
@immutable
class ReleaseCapabilities {
  const ReleaseCapabilities({
    required this.environment,
    required this.authMode,
    required this.localOnboarding,
    required this.goals,
    required this.finance,
    required this.habits,
    required this.deviceCalendar,
    required this.platformHealth,
    required this.exercise,
    required this.coachPreview,
    required this.notifications,
    required this.weather,
    required this.directWearables,
    required this.cloudAccount,
    required this.cloudSync,
    required this.debugIntegrationLab,
    required this.wardrobe,
    required this.body,
    required this.nutritionQuickAdd,
    required this.plannedSidebarItems,
    required this.exerciseSessions,
  });

  factory ReleaseCapabilities.fromEnvironment() {
    final environment = EnvironmentConfig.appEnvironment;
    final isProduction = environment == AppEnvironment.production;
    final showPlanned = EnvironmentConfig.showPlannedFeatures;

    return ReleaseCapabilities(
      environment: environment,
      authMode: EnvironmentConfig.authMode,
      localOnboarding: true,
      goals: true,
      finance: true,
      habits: true,
      deviceCalendar: true,
      platformHealth: true,
      exercise: true,
      coachPreview: EnvironmentConfig.enableAiPreview,
      notifications: false,
      weather: true,
      directWearables: false,
      cloudAccount: EnvironmentConfig.usesAccountAuth,
      cloudSync: EnvironmentConfig.usesAccountAuth,
      debugIntegrationLab:
          !isProduction &&
          EnvironmentConfig.enableIntegrationLab &&
          (kDebugMode || environment == AppEnvironment.internal),
      wardrobe: true,
      body: !isProduction,
      nutritionQuickAdd: !isProduction,
      plannedSidebarItems: showPlanned,
      // No live workout-session tracker in v1 — hide Start Workout in prod.
      exerciseSessions: !isProduction,
    );
  }

  /// Locked-down v1 shipping surface, independent of dart-defines. Useful for
  /// tests and for previewing the production IA from a debug build.
  factory ReleaseCapabilities.production() {
    return const ReleaseCapabilities(
      environment: AppEnvironment.production,
      authMode: AuthMode.account,
      localOnboarding: true,
      goals: true,
      finance: true,
      habits: true,
      deviceCalendar: true,
      platformHealth: true,
      exercise: true,
      coachPreview: false,
      notifications: false,
      weather: true,
      directWearables: false,
      cloudAccount: true,
      cloudSync: true,
      debugIntegrationLab: false,
      wardrobe: true,
      body: false,
      nutritionQuickAdd: false,
      plannedSidebarItems: false,
      exerciseSessions: false,
    );
  }

  final AppEnvironment environment;
  final AuthMode authMode;

  /// Local first-run setup (never a cloud account).
  final bool localOnboarding;
  final bool goals;
  final bool finance;
  final bool habits;
  final bool deviceCalendar;
  final bool platformHealth;
  final bool exercise;

  /// Local, scripted coach preview — never a live model.
  final bool coachPreview;

  /// Reminders/notifications scheduling. Not built for v1.
  final bool notifications;

  /// Live Open-Meteo glance weather using device location (no API key).
  final bool weather;

  /// Direct wearable SDKs (as opposed to reading platform Health).
  final bool directWearables;
  final bool cloudAccount;
  final bool cloudSync;
  final bool debugIntegrationLab;
  final bool wardrobe;
  final bool body;
  final bool nutritionQuickAdd;

  /// Whether "Planned" placeholder rows/badges are shown at all.
  final bool plannedSidebarItems;

  /// Live workout-session flow. Off in production until a real tracker ships.
  final bool exerciseSessions;

  bool get isProduction => environment == AppEnvironment.production;

  /// Demo sign-in / sign-up / forgot-password screens are reachable.
  bool get demoAuth => authMode == AuthMode.demo && !isProduction;

  bool get accountAuth => authMode == AuthMode.account;

  /// Sign out is available for demo auth and real accounts.
  bool get showSignOut => demoAuth || accountAuth;
}

/// Override in tests to exercise the production IA.
final releaseCapabilitiesProvider = Provider<ReleaseCapabilities>((ref) {
  return ReleaseCapabilities.fromEnvironment();
});
