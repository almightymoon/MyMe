import 'package:flutter_test/flutter_test.dart';
import 'package:memy/features/health/presentation/widgets/health_format.dart';

void main() {
  test('distance and weight follow metric vs imperial', () {
    expect(HealthFormat.distance(2500, metric: true), '2.5 km');
    expect(HealthFormat.distance(1609.344, metric: false), '1.0 mi');
    expect(HealthFormat.weightValue(70, metric: true), '70.0');
    expect(HealthFormat.weightUnit(metric: true), 'kg');
    expect(HealthFormat.weightValue(70, metric: false), '154.3');
    expect(HealthFormat.weightUnit(metric: false), 'lb');
  });
}
