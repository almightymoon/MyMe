import 'dart:io';

import 'local_wardrobe_image_store.dart';

/// File-backed store rooted at an injected temp directory for tests.
class FakeWardrobeImageStore extends LocalWardrobeImageStore {
  FakeWardrobeImageStore({
    required Directory root,
    String Function()? idGenerator,
  }) : super(
         documentsDirectory: () async => root,
         idGenerator: idGenerator ?? () => 'img-${root.hashCode}',
       );
}
