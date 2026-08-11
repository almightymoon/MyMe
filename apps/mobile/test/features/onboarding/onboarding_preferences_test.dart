import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/goals/data/repositories/local_goal_repository.dart';
import 'package:memy/features/onboarding/data/onboarding_preferences.dart';
import 'package:memy/features/user/domain/entities/profile_avatar.dart';
import 'package:memy/features/trust/domain/services/memy_owned_preference_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<SharedPreferences> freshPrefs() async {
  SharedPreferences.setMockInitialValues({});
  return SharedPreferences.getInstance();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts incomplete with PKR and metric defaults', () async {
    final prefs = await freshPrefs();

    expect(OnboardingPreferences.isComplete(prefs), isFalse);
    expect(OnboardingPreferences.readBaseCurrency(prefs), 'PKR');
    expect(OnboardingPreferences.readLanguage(prefs).code, 'en');
    expect(OnboardingPreferences.readUnits(prefs), MeasurementUnits.metric);
    expect(OnboardingPreferences.readWeekStart(prefs), WeekStart.monday);
    expect(OnboardingPreferences.readDisplayName(prefs), isNull);
  });

  test('detects a timezone without any stored value', () async {
    final prefs = await freshPrefs();

    expect(OnboardingPreferences.readTimezone(prefs), isNotEmpty);
    expect(
      OnboardingPreferences.readTimezone(prefs),
      OnboardingPreferences.detectTimezone(),
    );
  });

  test('persists captured preferences', () async {
    final prefs = await freshPrefs();

    await OnboardingPreferences.writeBaseCurrency(prefs, 'usd');
    await OnboardingPreferences.writeLanguage(prefs, 'ur');
    await OnboardingPreferences.writeUnits(prefs, MeasurementUnits.imperial);
    await OnboardingPreferences.writeWeekStart(prefs, WeekStart.sunday);
    await OnboardingPreferences.writeTimezone(prefs, 'PKT');
    await OnboardingPreferences.writeDisplayName(prefs, '  Moon  ');

    expect(OnboardingPreferences.readBaseCurrency(prefs), 'USD');
    expect(OnboardingPreferences.readLanguage(prefs).code, 'ur');
    expect(OnboardingPreferences.readUnits(prefs), MeasurementUnits.imperial);
    expect(OnboardingPreferences.readWeekStart(prefs), WeekStart.sunday);
    expect(OnboardingPreferences.readTimezone(prefs), 'PKT');
    expect(OnboardingPreferences.readDisplayName(prefs), 'Moon');
  });

  test('unsupported language falls back to English', () async {
    final prefs = await freshPrefs();

    await OnboardingPreferences.writeLanguage(prefs, 'xx');

    expect(OnboardingPreferences.readLanguage(prefs).code, 'en');
  });

  test('unsupported currency falls back to PKR', () async {
    final prefs = await freshPrefs();

    await OnboardingPreferences.writeBaseCurrency(prefs, 'xyz');

    expect(OnboardingPreferences.readBaseCurrency(prefs), 'PKR');
  });

  test('avatar id persists and unknown values fall back', () async {
    final prefs = await freshPrefs();
    expect(
      OnboardingPreferences.readAvatarId(prefs),
      ProfileAvatarCatalog.defaultId,
    );

    await OnboardingPreferences.writeAvatarId(prefs, 'sky');
    expect(OnboardingPreferences.readAvatarId(prefs), 'memy_3d_01');

    await OnboardingPreferences.writeAvatarId(prefs, 'memy_3d_08');
    expect(OnboardingPreferences.readAvatarId(prefs), 'memy_3d_08');

    await OnboardingPreferences.writeAvatarId(prefs, 'not-a-real-avatar');
    expect(
      OnboardingPreferences.readAvatarId(prefs),
      ProfileAvatarCatalog.defaultId,
    );
  });

  test('blank display name is cleared rather than stored', () async {
    final prefs = await freshPrefs();

    await OnboardingPreferences.writeDisplayName(prefs, 'Moon');
    await OnboardingPreferences.writeDisplayName(prefs, '   ');

    expect(OnboardingPreferences.readDisplayName(prefs), isNull);
    expect(prefs.containsKey(OnboardingPreferences.displayNameKey), isFalse);
  });

  test('completion cannot be recorded twice', () async {
    final prefs = await freshPrefs();

    expect(await OnboardingPreferences.markComplete(prefs), isTrue);
    expect(await OnboardingPreferences.markComplete(prefs), isFalse);
    expect(OnboardingPreferences.isComplete(prefs), isTrue);
  });

  test('reset clears completion but keeps preferences and user data', () async {
    final prefs = await freshPrefs();
    await prefs.setString(
      LocalGoalRepository.storageKey,
      '{"schemaVersion":1,"goals":[]}',
    );
    await OnboardingPreferences.writeBaseCurrency(prefs, 'EUR');
    await OnboardingPreferences.writeDisplayName(prefs, 'Moon');
    await OnboardingPreferences.markComplete(prefs);

    await OnboardingPreferences.resetCompletion(prefs);

    expect(OnboardingPreferences.isComplete(prefs), isFalse);
    expect(OnboardingPreferences.readBaseCurrency(prefs), 'EUR');
    expect(OnboardingPreferences.readDisplayName(prefs), 'Moon');
    expect(prefs.getString(LocalGoalRepository.storageKey), isNotNull);
  });

  test('onboarding keys are audited and wiped with preferences', () {
    expect(
      MemyOwnedPreferenceKeys.all,
      containsAll(OnboardingPreferences.allKeys),
    );
    expect(
      MemyOwnedPreferenceKeys.preferencesWipeTargets,
      contains(OnboardingPreferences.completeKey),
    );
  });
}
