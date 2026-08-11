import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/app_navigation.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/inline_error_card.dart';
import '../../../../core/widgets/loading_card_skeleton.dart';
import '../../../../core/widgets/memy_page_header.dart';
import '../../../../core/widgets/memy_primary_button.dart';
import '../../application/controllers/item_form_controller.dart';
import '../../application/providers/wardrobe_providers.dart';
import '../../domain/entities/wardrobe_enums.dart';

class AddWardrobeItemScreen extends ConsumerWidget {
  const AddWardrobeItemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(addWardrobeItemControllerProvider);
    final controller = ref.read(addWardrobeItemControllerProvider.notifier);
    return _ItemFormScaffold(
      title: 'Add item',
      form: form,
      controller: controller,
      fallback: RoutePaths.wardrobeItems,
    );
  }
}

class EditWardrobeItemScreen extends ConsumerWidget {
  const EditWardrobeItemScreen({super.key, required this.itemId});
  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(wardrobeItemByIdProvider(itemId));
    final form = ref.watch(editWardrobeItemControllerProvider(itemId));
    final controller = ref.read(
      editWardrobeItemControllerProvider(itemId).notifier,
    );
    return itemAsync.when(
      loading: () => const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(16),
          child: LoadingCardSkeleton(height: 120, lines: 3),
        ),
      ),
      error: (error, _) => Scaffold(
        body: InlineErrorCard(
          message: userFacingErrorMessage(error),
          onRetry: () => ref.invalidate(wardrobeItemsProvider),
        ),
      ),
      data: (item) {
        if (item != null) controller.hydrate(item);
        return _ItemFormScaffold(
          title: 'Edit item',
          form: form,
          controller: controller,
          fallback: RoutePaths.wardrobeItemPath(itemId),
        );
      },
    );
  }
}

class _ItemFormScaffold extends StatefulWidget {
  const _ItemFormScaffold({
    required this.title,
    required this.form,
    required this.controller,
    required this.fallback,
  });

  final String title;
  final ItemFormState form;
  final ItemFormController controller;
  final String fallback;

  @override
  State<_ItemFormScaffold> createState() => _ItemFormScaffoldState();
}

class _ItemFormScaffoldState extends State<_ItemFormScaffold> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.form.name);
  }

  @override
  void didUpdateWidget(covariant _ItemFormScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.form.name != _name.text) {
      _name.text = widget.form.name;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  ItemFormState get form => widget.form;
  ItemFormController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            MemyPageHeader(
              title: widget.title,
              subtitle: 'Photos stay on this device',
              leading: IconButton(
                onPressed: form.isSubmitting
                    ? null
                    : () => memyBack(context, fallback: widget.fallback),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Expanded(
              child: ListView(
                key: const Key('wardrobe_item_form'),
                padding: const EdgeInsets.all(AppSpacing.page),
                children: [
                  if (form.errorMessage != null) Text(form.errorMessage!),
                  TextField(
                    key: const Key('wardrobe_item_name'),
                    decoration: InputDecoration(
                      labelText: 'Name',
                      errorText: form.fieldErrors['name'],
                    ),
                    onChanged: controller.setName,
                    controller: _name,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<WardrobeItemCategory>(
                    // ignore: deprecated_member_use
                    value: form.category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: [
                      for (final value in WardrobeItemCategory.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                    ],
                    onChanged: form.isSubmitting
                        ? null
                        : (value) {
                            if (value != null) controller.setCategory(value);
                          },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<WardrobeItemStatus>(
                    // ignore: deprecated_member_use
                    value: form.status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: [
                      for (final value in WardrobeItemStatus.values)
                        DropdownMenuItem(
                          value: value,
                          child: Text(value.label),
                        ),
                    ],
                    onChanged: form.isSubmitting
                        ? null
                        : (value) {
                            if (value != null) controller.setStatus(value);
                          },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Favorite'),
                    value: form.isFavorite,
                    onChanged: form.isSubmitting
                        ? null
                        : controller.setFavorite,
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final color in WardrobeColorKey.values)
                        FilterChip(
                          label: Text(color.label),
                          selected: form.colorKeys.contains(color),
                          onSelected: (selected) {
                            final next = [...form.colorKeys];
                            if (selected) {
                              next.add(color);
                            } else {
                              next.remove(color);
                            }
                            controller.setColorKeys(next);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final occasion in WardrobeOccasion.values)
                        FilterChip(
                          label: Text(occasion.label),
                          selected: form.occasions.contains(occasion),
                          onSelected: (selected) {
                            final next = [...form.occasions];
                            if (selected) {
                              next.add(occasion);
                            } else {
                              next.remove(occasion);
                            }
                            controller.setOccasions(next);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final code in DressCode.values)
                        FilterChip(
                          label: Text(code.label),
                          selected: form.dressCodes.contains(code),
                          onSelected: (selected) {
                            final next = [...form.dressCodes];
                            if (selected) {
                              next.add(code);
                            } else {
                              next.remove(code);
                            }
                            controller.setDressCodes(next);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    key: const Key('wardrobe_pick_image'),
                    onPressed: form.isSubmitting
                        ? null
                        : () async {
                            try {
                              final picked = await ImagePicker().pickImage(
                                source: ImageSource.gallery,
                                requestFullMetadata: false,
                              );
                              if (picked == null) return;
                              controller.setPendingImagePath(picked.path);
                            } catch (_) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Photo selection was cancelled or denied.',
                                  ),
                                ),
                              );
                            }
                          },
                    child: Text(
                      form.pendingImagePath == null
                          ? 'Choose photo'
                          : 'Photo selected',
                    ),
                  ),
                  TextButton(
                    onPressed: form.isSubmitting
                        ? null
                        : controller.clearPendingImage,
                    child: const Text('Remove photo'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: MemyPrimaryButton(
                key: const Key('wardrobe_item_save'),
                label: form.isSubmitting ? 'Saving…' : 'Save item',
                onPressed: form.isSubmitting
                    ? null
                    : () async {
                        final id = await controller.submit();
                        if (!context.mounted || id == null) return;
                        context.go(RoutePaths.wardrobeItemPath(id));
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
