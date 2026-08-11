import 'local_wardrobe_repository.dart';

/// Test/demo alias of [LocalWardrobeRepository] using injected prefs + store.
class FakeWardrobeRepository extends LocalWardrobeRepository {
  FakeWardrobeRepository({
    required super.prefs,
    required super.imageStore,
    super.suggestionService,
    super.validation,
  });
}
