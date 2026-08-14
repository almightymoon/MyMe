import '../entities/user_profile.dart';

abstract class UserRepository {
  Future<UserProfile> fetchProfile();
}
