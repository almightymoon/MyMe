import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/fake_repository_config.dart';
import '../../data/repositories/fake_user_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FakeUserRepository(config: ref.watch(fakeRepositoryConfigProvider));
});

final userProfileProvider = FutureProvider.autoDispose<UserProfile>((
  ref,
) async {
  return ref.watch(userRepositoryProvider).fetchProfile();
});
