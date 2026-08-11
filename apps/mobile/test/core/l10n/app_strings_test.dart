import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/constants/app_strings.dart';

void main() {
  tearDown(() => AppStrings.setLanguageCode('en'));

  test('falls back to English and switches chrome copy', () {
    expect(AppStrings.today, 'Home');
    expect(AppStrings.t('Units'), 'Units');

    AppStrings.setLanguageCode('es');
    expect(AppStrings.today, 'Inicio');
    expect(AppStrings.t('Units'), 'Unidades');
    expect(AppStrings.t('Unknown label'), 'Unknown label');
  });
}
