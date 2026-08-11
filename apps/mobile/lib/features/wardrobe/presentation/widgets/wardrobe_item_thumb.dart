import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/wardrobe_providers.dart';
import '../../domain/entities/wardrobe_models.dart';

class WardrobeItemThumb extends ConsumerWidget {
  const WardrobeItemThumb({
    super.key,
    required this.item,
    this.size = 72,
    this.full = false,
  });

  final WardrobeItem item;
  final double size;
  final bool full;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final image = item.imageReference;
    final label = '${item.name} wardrobe image';
    if (image == null) {
      return Semantics(
        label: 'No photo for ${item.name}',
        child: SizedBox(
          width: size,
          height: size,
          child: const DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFFE8E8EA)),
            child: Icon(Icons.checkroom_outlined),
          ),
        ),
      );
    }
    return FutureBuilder<File?>(
      future: full
          ? ref.read(wardrobeImageStoreProvider).getOriginalFile(image)
          : ref.read(wardrobeImageStoreProvider).getThumbnailFile(image),
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) {
          return Semantics(
            label: 'Photo missing for ${item.name}',
            child: SizedBox(
              width: size,
              height: size,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Color(0xFFE8E8EA)),
                child: Icon(Icons.hide_image_outlined),
              ),
            ),
          );
        }
        return Semantics(
          label: label,
          image: true,
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            cacheWidth: full ? 1200 : 256,
            excludeFromSemantics: true,
          ),
        );
      },
    );
  }
}
