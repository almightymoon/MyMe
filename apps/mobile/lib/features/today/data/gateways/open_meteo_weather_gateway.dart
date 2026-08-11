import 'package:dio/dio.dart';

import '../../domain/entities/weather_snapshot.dart';
import '../../domain/services/device_location_service.dart';
import '../../domain/services/weather_gateway.dart';
import '../../domain/services/wmo_weather_labels.dart';
import '../../domain/weather_exception.dart';

/// Open-Meteo current weather — no API key required.
///
/// https://open-meteo.com/en/docs
class OpenMeteoWeatherGateway implements WeatherGateway {
  OpenMeteoWeatherGateway({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.open-meteo.com',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: const {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;

  @override
  Future<WeatherSnapshot> fetchCurrent(DeviceCoordinates coordinates) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/v1/forecast',
        queryParameters: {
          'latitude': coordinates.latitude,
          'longitude': coordinates.longitude,
          'current': 'temperature_2m,weather_code',
          'timezone': 'auto',
        },
      );
      final data = response.data;
      if (data == null) {
        throw const WeatherException(
          kind: WeatherFailureKind.invalidResponse,
          message: 'Weather data was incomplete. Try again.',
        );
      }
      final current = data['current'];
      if (current is! Map) {
        throw const WeatherException(
          kind: WeatherFailureKind.invalidResponse,
          message: 'Weather data was incomplete. Try again.',
        );
      }
      final tempRaw = current['temperature_2m'];
      final codeRaw = current['weather_code'];
      if (tempRaw is! num || codeRaw is! num) {
        throw const WeatherException(
          kind: WeatherFailureKind.invalidResponse,
          message: 'Weather data was incomplete. Try again.',
        );
      }
      return WeatherSnapshot(
        temperatureC: tempRaw.toDouble(),
        conditionLabel: WmoWeatherLabels.labelFor(codeRaw.round()),
        fetchedAt: DateTime.now().toUtc(),
      );
    } on WeatherException {
      rethrow;
    } on DioException catch (error) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        throw const WeatherException(
          kind: WeatherFailureKind.network,
          message: 'Weather is offline right now. Try again.',
        );
      }
      throw const WeatherException(
        kind: WeatherFailureKind.network,
        message: 'Could not load weather. Try again.',
      );
    } catch (_) {
      throw const WeatherException(
        kind: WeatherFailureKind.unknown,
        message: 'Could not load weather. Try again.',
      );
    }
  }
}
