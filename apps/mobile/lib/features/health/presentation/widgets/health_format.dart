/// Small display-formatting helpers shared by Health widgets/screens.
///
/// Pure functions only — no widget/business logic here.
abstract final class HealthFormat {
  static String steps(int value) => _thousands(value);

  static String distanceKm(double meters) {
    final km = meters / 1000;
    return '${km.toStringAsFixed(km >= 10 ? 0 : 1)} km';
  }

  static String distance(double meters, {required bool metric}) {
    if (metric) return distanceKm(meters);
    final miles = meters / 1609.344;
    return '${miles.toStringAsFixed(miles >= 10 ? 0 : 1)} mi';
  }

  static String kilocalories(double value) => _thousands(value.round());

  static String beatsPerMinute(double value) => value.round().toString();

  static String weightKg(double value) => value.toStringAsFixed(1);

  static String weightValue(double kg, {required bool metric}) {
    if (metric) return weightKg(kg);
    return (kg * 2.2046226218).toStringAsFixed(1);
  }

  static String weightUnit({required bool metric}) => metric ? 'kg' : 'lb';

  static String minutes(double value) => value.round().toString();

  static String duration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes % 60;
    if (hours <= 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }

  static String freshness(DateTime generatedAt, DateTime now) {
    final diff = now.difference(generatedAt);
    if (diff.inSeconds < 45) return 'Just now';
    if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Updated ${diff.inHours}h ago';
    return 'Updated ${diff.inDays}d ago';
  }

  static String _thousands(int value) {
    final s = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return value < 0 ? '-$buffer' : buffer.toString();
  }
}
