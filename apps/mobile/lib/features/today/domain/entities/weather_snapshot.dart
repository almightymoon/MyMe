/// Current conditions for the Today glance — ephemeral display DTO only.
///
/// Coordinates and raw provider payloads are never persisted.
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.temperatureC,
    required this.conditionLabel,
    required this.fetchedAt,
    this.sourceLabel = 'Open-Meteo',
  });

  final double temperatureC;
  final String conditionLabel;
  final DateTime fetchedAt;
  final String sourceLabel;

  double get temperatureF => temperatureC * 9 / 5 + 32;

  String temperatureLabel({required bool metric}) {
    final value = metric ? temperatureC.round() : temperatureF.round();
    final unit = metric ? '°C' : '°F';
    return '$value$unit';
  }
}
