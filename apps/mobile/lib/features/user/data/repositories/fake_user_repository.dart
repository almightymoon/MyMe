import '../../../../core/data/fake_repository_config.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_repository.dart';
import '../seed/user_seed.dart';

/// In-memory [UserRepository] for UI development and tests.
///
/// Demo only — not backed by auth or a network profile service.
class FakeUserRepository implements UserRepository {
  FakeUserRepository({required this.config});

  final FakeRepositoryConfig config;

  @override
  Future<UserProfile> fetchProfile() {
    return runFakeFetch(
      config: config,
      onData: () => UserSeed.demoProfile,
      onEmpty: () => UserProfile.empty,
    );
  }
}
