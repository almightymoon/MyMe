import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/gateways/open_meteo_weather_gateway.dart';
import '../../data/services/geolocator_device_location_service.dart';
import '../../domain/entities/weather_snapshot.dart';
import '../../domain/services/device_location_service.dart';
import '../../domain/services/weather_gateway.dart';

final deviceLocationServiceProvider = Provider<DeviceLocationService>((ref) {
  return GeolocatorDeviceLocationService();
});

final weatherGatewayProvider = Provider<WeatherGateway>((ref) {
  return OpenMeteoWeatherGateway();
});

/// Live glance weather. Location is requested only when this provider runs.
final todayWeatherProvider = FutureProvider.autoDispose<WeatherSnapshot>((
  ref,
) async {
  final location = ref.watch(deviceLocationServiceProvider);
  final gateway = ref.watch(weatherGatewayProvider);
  final coordinates = await location.currentCoordinates();
  return gateway.fetchCurrent(coordinates);
});
