import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/config/release_capabilities.dart';
import 'package:memy/features/onboarding/data/onboarding_preferences.dart';
import 'package:memy/features/today/application/providers/weather_providers.dart';
import 'package:memy/features/today/data/gateways/open_meteo_weather_gateway.dart';
import 'package:memy/features/today/domain/entities/weather_snapshot.dart';
import 'package:memy/features/today/domain/services/device_location_service.dart';
import 'package:memy/features/today/domain/services/weather_gateway.dart';
import 'package:memy/features/today/domain/weather_exception.dart';

import '../../helpers/test_app.dart';

class _FixedLocation implements DeviceLocationService {
  _FixedLocation(this.coordinates, {this.error});

  final DeviceCoordinates coordinates;
  final WeatherException? error;

  @override
  Future<DeviceCoordinates> currentCoordinates() async {
    final failure = error;
    if (failure != null) throw failure;
    return coordinates;
  }

  @override
  Future<bool> openLocationSettings() async => true;
}

class _FixedWeatherGateway implements WeatherGateway {
  _FixedWeatherGateway(this.snapshot);

  final WeatherSnapshot snapshot;

  @override
  Future<WeatherSnapshot> fetchCurrent(DeviceCoordinates coordinates) async {
    return snapshot;
  }
}

void main() {
  test('OpenMeteoWeatherGateway parses current temperature and code', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.open-meteo.com'));
    dio.httpClientAdapter = _MapAdapter({
      'current': {'temperature_2m': 18.6, 'weather_code': 3},
    });
    final gateway = OpenMeteoWeatherGateway(dio: dio);
    final snapshot = await gateway.fetchCurrent(
      const DeviceCoordinates(latitude: 31.5, longitude: 74.3),
    );
    expect(snapshot.temperatureC, closeTo(18.6, 0.01));
    expect(snapshot.conditionLabel, 'Cloudy');
  });

  testWidgets('Today glance shows live weather temperature', (tester) async {
    final prefs = await setupTestPreferences();
    await OnboardingPreferences.markComplete(prefs);
    await OnboardingPreferences.writeUnits(prefs, MeasurementUnits.metric);

    await pumpMemyApp(
      tester,
      prefs: prefs,
      overrides: [
        releaseCapabilitiesProvider.overrideWithValue(
          ReleaseCapabilities.production(),
        ),
        deviceLocationServiceProvider.overrideWithValue(
          _FixedLocation(
            const DeviceCoordinates(latitude: 31.5, longitude: 74.3),
          ),
        ),
        weatherGatewayProvider.overrideWithValue(
          _FixedWeatherGateway(
            WeatherSnapshot(
              temperatureC: 27,
              conditionLabel: 'Clear',
              fetchedAt: DateTime.utc(2026, 8, 11),
            ),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today_glance_weather')), findsOneWidget);
    expect(find.byKey(const Key('today_weather_data')), findsOneWidget);
    expect(find.text('27°C'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
    expect(find.text('22°C'), findsNothing);
  });

  testWidgets('Today glance weather shows permission error and retry', (
    tester,
  ) async {
    final prefs = await setupTestPreferences();
    await OnboardingPreferences.markComplete(prefs);

    await pumpMemyApp(
      tester,
      prefs: prefs,
      overrides: [
        releaseCapabilitiesProvider.overrideWithValue(
          ReleaseCapabilities.production(),
        ),
        deviceLocationServiceProvider.overrideWithValue(
          _FixedLocation(
            const DeviceCoordinates(latitude: 0, longitude: 0),
            error: const WeatherException(
              kind: WeatherFailureKind.locationPermissionDenied,
              message: 'Allow location access to show today’s weather.',
            ),
          ),
        ),
      ],
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('today_weather_error')), findsOneWidget);
    expect(find.byKey(const Key('today_weather_retry')), findsOneWidget);
    expect(find.textContaining('Allow location access'), findsOneWidget);
  });
}

class _MapAdapter implements HttpClientAdapter {
  _MapAdapter(this.payload);

  final Map<String, dynamic> payload;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}
