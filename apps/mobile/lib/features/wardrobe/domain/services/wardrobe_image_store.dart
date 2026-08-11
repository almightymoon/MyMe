import 'dart:io';

import '../entities/wardrobe_models.dart';

abstract interface class WardrobeImageStore {
  Future<WardrobeImageReference> importFromPickedFile(String sourcePath);

  Future<File?> getOriginalFile(WardrobeImageReference reference);

  Future<File?> getThumbnailFile(WardrobeImageReference reference);

  Future<WardrobeImageReference> replaceImage({
    required WardrobeImageReference existing,
    required String sourcePath,
  });

  Future<void> deleteImage(WardrobeImageReference reference);

  Future<int> deleteAllImages();

  Future<List<String>> findOrphanImages(Set<String> knownRelativePaths);

  Future<int> cleanOrphanImages(Set<String> knownRelativePaths);

  Future<int> calculateStorageUsage();
}
