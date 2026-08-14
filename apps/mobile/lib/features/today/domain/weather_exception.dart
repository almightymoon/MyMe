/// Typed weather failures so Today can show permission vs network UI.
enum WeatherFailureKind {
  locationDisabled,
  locationPermissionDenied,
  locationPermissionPermanentlyDenied,
  locationUnavailable,
  network,
  invalidResponse,
  unknown,
}

class WeatherException implements Exception {
  const WeatherException({required this.kind, required this.message});

  final WeatherFailureKind kind;
  final String message;

  bool get needsLocationPermission =>
      kind == WeatherFailureKind.locationPermissionDenied ||
      kind == WeatherFailureKind.locationPermissionPermanentlyDenied;

  bool get openSettings =>
      kind == WeatherFailureKind.locationPermissionPermanentlyDenied ||
      kind == WeatherFailureKind.locationDisabled;

  @override
  String toString() => message;
}
