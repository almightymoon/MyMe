import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/wardrobe_models.dart';
import '../../domain/services/wardrobe_image_store.dart';

class LocalWardrobeImageStore implements WardrobeImageStore {
  LocalWardrobeImageStore({
    required this.documentsDirectory,
    required this.idGenerator,
    this.accountNamespace = 'legacy',
  });

  final Future<Directory> Function() documentsDirectory;
  final String Function() idGenerator;
  final String accountNamespace;

  static const int maxBytes = 8 * 1024 * 1024;
  static const int maxEdge = 2048;
  static const int thumbEdge = 256;

  Future<Directory> _root() async {
    try {
      return await documentsDirectory();
    } on Object {
      throw const AppException(
        kind: AppErrorKind.unknown,
        message: 'Could not access private photo storage on this device.',
        code: 'storageUnavailable',
      );
    }
  }

  Future<Directory> _originals() async {
    final dir = Directory(
      p.join((await _root()).path, 'wardrobe', accountNamespace, 'originals'),
    );
    await dir.create(recursive: true);
    return dir;
  }

  Future<Directory> _thumbs() async {
    final dir = Directory(
      p.join((await _root()).path, 'wardrobe', accountNamespace, 'thumbnails'),
    );
    await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<WardrobeImageReference> importFromPickedFile(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw AppException.validation(
        'That image could not be read.',
        code: 'unsupportedImage',
      );
    }
    final bytes = await source.readAsBytes();
    if (bytes.length > maxBytes) {
      throw AppException.validation(
        'Choose a smaller image (under 8 MB).',
        code: 'unsupportedImage',
      );
    }
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw AppException.validation(
        'That file is not a supported image.',
        code: 'unsupportedImage',
      );
    }
    final oriented = img.bakeOrientation(decoded);
    final resized = _fit(oriented, maxEdge);
    final encoded = img.encodeJpg(resized, quality: 85);
    final thumb = img.encodeJpg(_fit(resized, thumbEdge), quality: 70);
    final id = idGenerator();
    final originalName = '$id.jpg';
    final thumbName = '$id.jpg';
    try {
      final originalFile = File(
        p.join((await _originals()).path, originalName),
      );
      final thumbFile = File(p.join((await _thumbs()).path, thumbName));
      await originalFile.writeAsBytes(encoded, flush: true);
      await thumbFile.writeAsBytes(thumb, flush: true);
      return WardrobeImageReference(
        id: id,
        relativeOriginalPath: 'originals/$originalName',
        relativeThumbnailPath: 'thumbnails/$thumbName',
        mimeType: 'image/jpeg',
        width: resized.width,
        height: resized.height,
        byteSize: encoded.length,
        createdAt: DateTime.now(),
      );
    } on FileSystemException {
      throw const AppException(
        kind: AppErrorKind.unknown,
        message: 'Could not save the image on this device.',
        code: 'imageWriteFailed',
      );
    }
  }

  img.Image _fit(img.Image source, int maxEdge) {
    final edge = source.width > source.height ? source.width : source.height;
    if (edge <= maxEdge) return source;
    final scale = maxEdge / edge;
    return img.copyResize(
      source,
      width: (source.width * scale).round(),
      height: (source.height * scale).round(),
    );
  }

  @override
  Future<File?> getOriginalFile(WardrobeImageReference reference) async {
    final file = File(
      p.join(
        (await _root()).path,
        'wardrobe',
        accountNamespace,
        reference.relativeOriginalPath,
      ),
    );
    return file.existsSync() ? file : null;
  }

  @override
  Future<File?> getThumbnailFile(WardrobeImageReference reference) async {
    final file = File(
      p.join(
        (await _root()).path,
        'wardrobe',
        accountNamespace,
        reference.relativeThumbnailPath,
      ),
    );
    return file.existsSync() ? file : null;
  }

  @override
  Future<WardrobeImageReference> replaceImage({
    required WardrobeImageReference existing,
    required String sourcePath,
  }) async {
    final next = await importFromPickedFile(sourcePath);
    await deleteImage(existing);
    return next;
  }

  @override
  Future<void> deleteImage(WardrobeImageReference reference) async {
    final original = await getOriginalFile(reference);
    final thumb = await getThumbnailFile(reference);
    if (original != null) await original.delete();
    if (thumb != null) await thumb.delete();
  }

  @override
  Future<int> deleteAllImages() async {
    var count = 0;
    for (final dir in [await _originals(), await _thumbs()]) {
      if (!dir.existsSync()) continue;
      await for (final entity in dir.list()) {
        if (entity is File) {
          await entity.delete();
          count += 1;
        }
      }
    }
    return count;
  }

  @override
  Future<List<String>> findOrphanImages(Set<String> knownRelativePaths) async {
    final orphans = <String>[];
    final root = p.join((await _root()).path, 'wardrobe', accountNamespace);
    for (final folder in ['originals', 'thumbnails']) {
      final dir = Directory(p.join(root, folder));
      if (!dir.existsSync()) continue;
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final relative = '$folder/${p.basename(entity.path)}';
        if (!knownRelativePaths.contains(relative)) {
          orphans.add(relative);
        }
      }
    }
    return orphans;
  }

  @override
  Future<int> cleanOrphanImages(Set<String> knownRelativePaths) async {
    final orphans = await findOrphanImages(knownRelativePaths);
    final root = p.join((await _root()).path, 'wardrobe', accountNamespace);
    for (final relative in orphans) {
      final file = File(p.join(root, relative));
      if (file.existsSync()) await file.delete();
    }
    return orphans.length;
  }

  @override
  Future<int> calculateStorageUsage() async {
    var total = 0;
    for (final dir in [await _originals(), await _thumbs()]) {
      if (!dir.existsSync()) continue;
      await for (final entity in dir.list()) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    }
    return total;
  }
}
