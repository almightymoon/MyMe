import 'package:flutter_test/flutter_test.dart';

import 'package:memy/core/config/environment_config.dart';

void main() {
  group('API_BASE_URL validation (production)', () {
    test('rejects http scheme', () {
      expect(
        () => EnvironmentConfig.validateApiBaseUrl(
          environment: AppEnvironment.production,
          apiBaseUrlOverride: 'http://api.example.com/api/v1',
        ),
        throwsA(isA<EnvironmentConfigError>()),
      );
    });

    test('rejects localhost', () {
      expect(
        () => EnvironmentConfig.validateApiBaseUrl(
          environment: AppEnvironment.production,
          apiBaseUrlOverride: 'https://localhost/api/v1',
        ),
        throwsA(isA<EnvironmentConfigError>()),
      );
    });

    test('rejects .invalid hosts', () {
      expect(
        () => EnvironmentConfig.validateApiBaseUrl(
          environment: AppEnvironment.production,
          apiBaseUrlOverride: 'https://api.example.invalid/api/v1',
        ),
        throwsA(isA<EnvironmentConfigError>()),
      );
    });

    test('rejects private LAN hosts', () {
      expect(
        () => EnvironmentConfig.validateApiBaseUrl(
          environment: AppEnvironment.production,
          apiBaseUrlOverride: 'https://10.0.2.2/api/v1',
        ),
        throwsA(isA<EnvironmentConfigError>()),
      );
    });

    test('rejects missing /api/v1 suffix', () {
      expect(
        () => EnvironmentConfig.validateApiBaseUrl(
          environment: AppEnvironment.production,
          apiBaseUrlOverride: 'https://api.example.com/',
        ),
        throwsA(isA<EnvironmentConfigError>()),
      );
    });

    test('accepts safe https endpoint', () {
      EnvironmentConfig.validateApiBaseUrl(
        environment: AppEnvironment.production,
        apiBaseUrlOverride: 'https://api.example.com/api/v1',
      );
    });
  });
}
