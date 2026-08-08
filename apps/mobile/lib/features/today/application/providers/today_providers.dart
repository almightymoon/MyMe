import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/fake_repository_config.dart';
import '../../data/repositories/fake_today_repository.dart';
import '../../domain/entities/today_summary.dart';
import '../../domain/repositories/today_repository.dart';

final todayRepositoryProvider = Provider<TodayRepository>((ref) {
  return FakeTodayRepository(config: ref.watch(fakeRepositoryConfigProvider));
});

final todaySummaryProvider = FutureProvider.autoDispose<TodaySummary>((
  ref,
) async {
  return ref.watch(todayRepositoryProvider).fetchTodaySummary();
});
