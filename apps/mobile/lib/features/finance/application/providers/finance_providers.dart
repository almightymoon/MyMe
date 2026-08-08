import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/fake_repository_config.dart';
import '../../data/repositories/fake_finance_repository.dart';
import '../../domain/entities/finance_summary.dart';
import '../../domain/repositories/finance_repository.dart';

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  return FakeFinanceRepository(config: ref.watch(fakeRepositoryConfigProvider));
});

final financeSummaryProvider = FutureProvider.autoDispose<FinanceSummary>((
  ref,
) async {
  return ref.watch(financeRepositoryProvider).fetchFinanceSummary();
});
