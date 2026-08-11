class DeviceCoordinates {
  const DeviceCoordinates({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

/// Resolves a coarse device position for weather only.
abstract class DeviceLocationService {
  Future<DeviceCoordinates> currentCoordinates();

  Future<bool> openLocationSettings();
}
