import 'package:flutter/widgets.dart';

/// Languages offered in Settings and first-run setup.
class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.nativeName,
    required this.englishName,
  });

  final String code;
  final String nativeName;
  final String englishName;

  Locale get locale => Locale(code);

  static const english = AppLanguage(
    code: 'en',
    nativeName: 'English',
    englishName: 'English',
  );

  static const List<AppLanguage> supported = [
    english,
    AppLanguage(code: 'ur', nativeName: 'اردو', englishName: 'Urdu'),
    AppLanguage(code: 'ar', nativeName: 'العربية', englishName: 'Arabic'),
    AppLanguage(code: 'hi', nativeName: 'हिन्दी', englishName: 'Hindi'),
    AppLanguage(code: 'es', nativeName: 'Español', englishName: 'Spanish'),
    AppLanguage(code: 'fr', nativeName: 'Français', englishName: 'French'),
    AppLanguage(code: 'de', nativeName: 'Deutsch', englishName: 'German'),
  ];

  static const String defaultCode = 'en';

  static AppLanguage resolve(String? code) {
    final normalized = code?.trim().toLowerCase();
    for (final language in supported) {
      if (language.code == normalized) return language;
    }
    return english;
  }

  static List<Locale> get supportedLocales => [
    for (final language in supported) language.locale,
  ];
}
