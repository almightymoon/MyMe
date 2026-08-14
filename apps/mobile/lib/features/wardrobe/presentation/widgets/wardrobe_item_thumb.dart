import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/providers/wardrobe_providers.dart';
import '../../domain/entities/wardrobe_models.dart';

class WardrobeItemThumb extends ConsumerStatefulWidget {
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
  ConsumerState<WardrobeItemThumb> createState() => _WardrobeItemThumbState();
}

class _WardrobeItemThumbState extends ConsumerState<WardrobeItemThumb> {
  Future<File?>? _fileFuture;
  String? _imageId;
  bool? _full;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFuture();
  }

  @override
  void didUpdateWidget(covariant WardrobeItemThumb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.imageReference?.id != widget.item.imageReference?.id ||
        oldWidget.full != widget.full) {
      _fileFuture = null;
      _imageId = null;
    }
    _syncFuture();
  }

  void _syncFuture() {
    final image = widget.item.imageReference;
    if (image == null) {
      _fileFuture = null;
      _imageId = null;
      return;
    }
    if (_fileFuture != null && _imageId == image.id && _full == widget.full) {
      return;
    }
    _imageId = image.id;
    _full = widget.full;
    final store = ref.read(wardrobeImageStoreProvider);
    _fileFuture = widget.full
        ? store.getOriginalFile(image)
        : store.getThumbnailFile(image);
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.item.imageReference;
    final size = widget.size;
    if (image == null) {
      return Semantics(
        label: 'No photo for ${widget.item.name}',
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
      future: _fileFuture,
      builder: (context, snapshot) {
        final file = snapshot.data;
        if (file == null) {
          return Semantics(
            label: 'Photo missing for ${widget.item.name}',
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
          label: '${widget.item.name} wardrobe image',
          image: true,
          child: Image.file(
            file,
            width: size,
            height: size,
            fit: BoxFit.cover,
            cacheWidth: widget.full ? 1200 : 256,
            excludeFromSemantics: true,
          ),
        );
      },
    );
  }
}
