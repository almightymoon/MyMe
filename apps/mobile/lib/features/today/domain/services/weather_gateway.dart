import '../entities/weather_snapshot.dart';
import 'device_location_service.dart';

abstract class WeatherGateway {
  Future<WeatherSnapshot> fetchCurrent(DeviceCoordinates coordinates);
}
