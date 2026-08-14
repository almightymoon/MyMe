import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/today/domain/entities/weather_snapshot.dart';
import 'package:memy/features/today/domain/services/wmo_weather_labels.dart';

void main() {
  group('WmoWeatherLabels', () {
    test('maps common WMO codes', () {
      expect(WmoWeatherLabels.labelFor(0), 'Clear');
      expect(WmoWeatherLabels.labelFor(3), 'Cloudy');
      expect(WmoWeatherLabels.labelFor(61), 'Rain');
      expect(WmoWeatherLabels.labelFor(95), 'Thunderstorm');
    });
  });

  group('WeatherSnapshot', () {
    test('formats metric and imperial temperatures', () {
      final snapshot = WeatherSnapshot(
        temperatureC: 22.4,
        conditionLabel: 'Cloudy',
        fetchedAt: DateTime.utc(2026, 8, 11),
      );
      expect(snapshot.temperatureLabel(metric: true), '22°C');
      expect(snapshot.temperatureLabel(metric: false), '72°F');
    });
  });
}
