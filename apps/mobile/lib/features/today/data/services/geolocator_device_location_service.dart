import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../domain/services/device_location_service.dart';
import '../../domain/weather_exception.dart';

class GeolocatorDeviceLocationService implements DeviceLocationService {
  @override
  Future<DeviceCoordinates> currentCoordinates() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const WeatherException(
        kind: WeatherFailureKind.locationDisabled,
        message: 'Turn on Location Services to show today’s weather.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const WeatherException(
        kind: WeatherFailureKind.locationPermissionDenied,
        message: 'Allow location access to show today’s weather.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const WeatherException(
        kind: WeatherFailureKind.locationPermissionPermanentlyDenied,
        message:
            'Location access is off. Enable it in Settings to show weather.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 12),
        ),
      );
      return DeviceCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on TimeoutException {
      throw const WeatherException(
        kind: WeatherFailureKind.locationUnavailable,
        message: 'Could not determine your location. Try again.',
      );
    } catch (_) {
      throw const WeatherException(
        kind: WeatherFailureKind.locationUnavailable,
        message: 'Could not determine your location. Try again.',
      );
    }
  }

  @override
  Future<bool> openLocationSettings() {
    return Geolocator.openAppSettings();
  }
}
