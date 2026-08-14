import '../l10n/app_translations.dart';

abstract final class AppStrings {
  static String _languageCode = 'en';

  static void setLanguageCode(String code) {
    _languageCode = code.trim().toLowerCase();
  }

  static String t(String english) {
    if (_languageCode == 'en') return english;
    return appTranslations[_languageCode]?[english] ?? english;
  }

  static const String appName = 'MeMy';
  static const String company = 'MoonTech';
  static String get tagline => t('Your life, perfectly balanced.');

  /// Shipping tagline for v1. Deliberately avoids "AI" — the v1 build has no
  /// live model, so the product is positioned as a local life companion.
  static String get productTagline => t('Your Personal Life Companion');
  static String get demoMode => t('Demo mode');
  static String get continueToMemy => t('Continue to MeMy');
  static String get signIn => t('Sign In');
  static String get signUp => t('Sign Up');
  static String get forgotPassword => t('Forgot password?');
  static String get forgotPasswordTitle => t('Forgot password?');
  static String get forgotPasswordSubtitle =>
      t('Enter your email or phone and MeMy will send a reset link.');
  static String get sendResetLink => t('Send Reset Link');
  static String get resetLinkSentDemo =>
      t('Demo only — a reset link would be sent.');
  static String get createAccountTitle => t('Create your account');
  static String get createAccountSubtitle =>
      t('One place for goals, health, money, and style — guided by MeMy.');
  static String get fullNameHint => t('Full Name');
  static String get emailOrPhoneHint => t('Email or Phone');
  static String get confirmPasswordHint => t('Confirm Password');
  static String get acceptTerms =>
      t('I agree to MeMy’s Terms of Service and Privacy Policy.');
  static String get welcomeHeading => t('Welcome back');
  static String get emailLabel => t('Email');
  static String get passwordLabel => t('Password');
  static String get demoAuthNote =>
      t('Demo mode — authentication is not connected yet.');

  static String get today => t('Home');
  static String get plan => t('Dashboard');
  static String get modulesKicker => t('Modules');
  static String get dashboardTitle => t('Dashboard');
  static String get coach => t('AI Coach');
  static String get coachPreview => t('Coach Preview');
  static String get coachPreviewNote => t(
    'Coach Preview is a local, scripted demo. No live AI model is contacted '
    'and nothing you type leaves this device.',
  );
  static String get more => t('Insights');
  static String get insightsTitle => t('Insights');
  static String get insightsSubtitle => t('Weekly summary and modules');
  static String get quickAdd => t('Quick Add');

  static String get dayAtAGlance => t('Today at a Glance');
  static String get weather => t('Weather');
  static String get dailyFocus => t("Today's Focus");
  static String get schedulePreview => t('Schedule');
  static String get todaysTasks => t("Today's Tasks");
  static String get goalProgress => t('Goal progress');
  static String get habitPreview => t('Habits');
  static String get financePreview => t('Finance');
  static String get aiRecommendation => t('AI recommendation');
  static String get demoContentLabel => t('Demo content');
  static String get samplePreviewCaption => t('Sample preview');
  static String get lifeScore => t('Life Score');
  static String get buildYourDayTitle => t('Your day');
  static String get buildYourDayMessage =>
      t('Open Goals and Habits to build your day.');
  static String get insightsPlaceholderTitle => t('This week');
  static String get insightsPlaceholderMessage => t(
    'Summaries will grow from the Goals, Habits, and Finance you track '
    'on this device.',
  );

  static String get liveAiNotConnected =>
      t('Live AI is not connected in this foundation build.');
  static String get coachComposerHint => t('Ask MeMy… (demo only)');
  static String get coachComposerDisabled =>
      t('Message composer is demo-only and disabled.');
  static String get demoResponseLabel => t('Demo response');
  static String get coachLocalDemoNote => t(
    'Suggested prompts and replies are local demo content. '
    'No live AI model is contacted.',
  );

  static String get addGoal => t('Add Goal');
  static String get addDailyTask => t('Daily Task');
  static String get addTransaction => t('Add Transaction');
  static String get addEvent => t('Add Event');
  static String get addHabit => t('Add Habit');
  static String get logMeal => t('Log Meal');

  static String get comingSoon => t('Coming soon');
  static String get back => t('Back');
  static String get retry => t('Retry');
  static String get couldNotLoad => t("Couldn't load");
  static String get demoLoadFailed => t(
    'Demo data failed to load. This is a fake repository error for testing.',
  );
  static String get tryAgainHint => t('Check again or retry.');
  static String get nothingHereYet => t('Nothing here yet');
  static String get todayEmptyMessage =>
      t('No daily focus, agenda, or summaries yet. Demo empty state.');
  static String get sectionEmptyMessage => t('No items in this demo section.');
  static String get placeholderFeature => t('Placeholder');
}
