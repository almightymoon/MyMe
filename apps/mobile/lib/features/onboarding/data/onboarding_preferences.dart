import 'package:shared_preferences/shared_preferences.dart';

import '../../user/domain/entities/profile_avatar.dart';

/// Unit system captured during first-run setup.
enum MeasurementUnits { metric, imperial }

/// First day of the week used by Plan/Habits summaries.
enum WeekStart { monday, sunday }

/// Local, device-only first-run preferences.
///
/// Nothing here leaves the device and none of it is an account: onboarding
/// records how the person wants MeMy to display things, plus a single
/// completion flag so the flow only runs once.
abstract final class OnboardingPreferences {
  static const String completeKey = 'memy_onboarding_complete_v1';
  static const String displayNameKey = 'memy_display_name_v1';
  static const String avatarIdKey = 'memy_avatar_id_v1';
  static const String baseCurrencyKey = 'memy_base_currency_v1';
  static const String unitsKey = 'memy_units_v1';
  static const String weekStartKey = 'memy_week_start_v1';
  static const String timezoneKey = 'memy_timezone_v1';

  static const String defaultCurrency = 'PKR';

  /// Currencies offered during setup. Kept short and editable later.
  static const List<String> supportedCurrencies = [
    'PKR',
    'USD',
    'EUR',
    'GBP',
    'AED',
    'SAR',
    'INR',
  ];

  static const List<String> allKeys = [
    completeKey,
    displayNameKey,
    avatarIdKey,
    baseCurrencyKey,
    unitsKey,
    weekStartKey,
    timezoneKey,
  ];

  static bool isComplete(SharedPreferences prefs) {
    return prefs.getBool(completeKey) ?? false;
  }

  /// Marks setup finished. Returns false when it was already complete, so the
  /// Finish step cannot be double-submitted.
  static Future<bool> markComplete(SharedPreferences prefs) async {
    if (isComplete(prefs)) return false;
    await prefs.setBool(completeKey, true);
    return true;
  }

  /// Clears only the completion flag — never the captured preferences and
  /// never any goals/finance/habits data.
  static Future<void> resetCompletion(SharedPreferences prefs) async {
    await prefs.remove(completeKey);
  }

  static String? readDisplayName(SharedPreferences prefs) {
    final value = prefs.getString(displayNameKey)?.trim();
    return (value == null || value.isEmpty) ? null : value;
  }

  static Future<void> writeDisplayName(
    SharedPreferences prefs,
    String? value,
  ) async {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      await prefs.remove(displayNameKey);
      return;
    }
    await prefs.setString(displayNameKey, trimmed);
  }

  static String readAvatarId(SharedPreferences prefs) {
    return ProfileAvatarCatalog.resolve(prefs.getString(avatarIdKey));
  }

  static Future<void> writeAvatarId(
    SharedPreferences prefs,
    String value,
  ) async {
    await prefs.setString(avatarIdKey, ProfileAvatarCatalog.resolve(value));
  }

  static String readBaseCurrency(SharedPreferences prefs) {
    final value = prefs.getString(baseCurrencyKey)?.trim();
    if (value == null || value.isEmpty) return defaultCurrency;
    return value.toUpperCase();
  }

  static Future<void> writeBaseCurrency(
    SharedPreferences prefs,
    String value,
  ) async {
    await prefs.setString(baseCurrencyKey, value.trim().toUpperCase());
  }

  static MeasurementUnits readUnits(SharedPreferences prefs) {
    return prefs.getString(unitsKey) == 'imperial'
        ? MeasurementUnits.imperial
        : MeasurementUnits.metric;
  }

  static Future<void> writeUnits(
    SharedPreferences prefs,
    MeasurementUnits value,
  ) async {
    await prefs.setString(unitsKey, value.name);
  }

  static WeekStart readWeekStart(SharedPreferences prefs) {
    return prefs.getString(weekStartKey) == 'sunday'
        ? WeekStart.sunday
        : WeekStart.monday;
  }

  static Future<void> writeWeekStart(
    SharedPreferences prefs,
    WeekStart value,
  ) async {
    await prefs.setString(weekStartKey, value.name);
  }

  static String readTimezone(SharedPreferences prefs) {
    final value = prefs.getString(timezoneKey)?.trim();
    if (value == null || value.isEmpty) return detectTimezone();
    return value;
  }

  static Future<void> writeTimezone(
    SharedPreferences prefs,
    String value,
  ) async {
    await prefs.setString(timezoneKey, value.trim());
  }

  /// Device timezone abbreviation, e.g. `PKT`. Never a network lookup.
  static String detectTimezone() {
    final name = DateTime.now().timeZoneName.trim();
    return name.isEmpty ? 'UTC' : name;
  }

  static Map<String, Object?> exportMap(SharedPreferences prefs) {
    return {
      'onboardingComplete': isComplete(prefs),
      'displayName': readDisplayName(prefs),
      'avatarId': readAvatarId(prefs),
      'baseCurrency': readBaseCurrency(prefs),
      'units': readUnits(prefs).name,
      'weekStart': readWeekStart(prefs).name,
      'timezone': prefs.getString(timezoneKey),
    };
  }
}
