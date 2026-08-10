import 'package:flutter_test/flutter_test.dart';
import 'package:memy/core/data/fake_repository_config.dart';
import 'package:memy/features/today/data/repositories/fake_today_repository.dart';
import 'package:memy/features/today/data/seed/today_seed.dart';

void main() {
  test('FakeTodayRepository returns populated seed data', () async {
    final repo = FakeTodayRepository(
      config: FakeRepositoryConfig(delay: Duration.zero),
    );
    final summary = await repo.fetchTodaySummary();

    expect(summary.hasDailyInformation, isTrue);
    expect(summary.focus?.title, TodaySeed.demoFocus.title);
    // Schedule is composed from CalendarRepository in todaySummaryProvider,
    // not from TodaySeed (which keeps schedule empty).
    expect(summary.schedule, isEmpty);
    expect(summary.coachRecommendation, isNotNull);
  });

  test('FakeTodayRepository empty mode returns no daily information', () async {
    final repo = FakeTodayRepository(
      config: FakeRepositoryConfig(delay: Duration.zero, forceEmpty: true),
    );
    final summary = await repo.fetchTodaySummary();

    expect(summary.hasDailyInformation, isFalse);
  });

  test(
    'FakeTodayRepository failure mode throws FakeRepositoryException',
    () async {
      final repo = FakeTodayRepository(
        config: FakeRepositoryConfig(
          delay: Duration.zero,
          forceFailure: true,
          failureMessage: 'boom',
        ),
      );

      expect(
        () => repo.fetchTodaySummary(),
        throwsA(
          isA<FakeRepositoryException>().having(
            (e) => e.message,
            'message',
            'boom',
          ),
        ),
      );
    },
  );
}
