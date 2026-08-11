import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/application/providers/core_providers.dart';
import '../../../../core/domain/services/money_format.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/wardrobe_enums.dart';
import '../../domain/entities/wardrobe_models.dart';
import '../providers/wardrobe_providers.dart';

class ItemFormState {
  const ItemFormState({
    this.name = '',
    this.category = WardrobeItemCategory.tops,
    this.status = WardrobeItemStatus.available,
    this.isFavorite = false,
    this.colorKeys = const [WardrobeColorKey.navy],
    this.seasons = const [WardrobeSeason.allSeason],
    this.occasions = const [WardrobeOccasion.casual],
    this.dressCodes = const [DressCode.casual],
    this.brand = '',
    this.size = '',
    this.material = '',
    this.notes = '',
    this.purchasePriceText = '',
    this.pendingImagePath,
    this.removeExistingImage = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.fieldErrors = const {},
    this.editingId,
  });

  final String name;
  final WardrobeItemCategory category;
  final WardrobeItemStatus status;
  final bool isFavorite;
  final List<WardrobeColorKey> colorKeys;
  final List<WardrobeSeason> seasons;
  final List<WardrobeOccasion> occasions;
  final List<DressCode> dressCodes;
  final String brand;
  final String size;
  final String material;
  final String notes;
  final String purchasePriceText;
  final String? pendingImagePath;
  final bool removeExistingImage;
  final bool isSubmitting;
  final String? errorMessage;
  final Map<String, String> fieldErrors;
  final String? editingId;

  bool get isEditing => editingId != null;

  ItemFormState copyWith({
    String? name,
    WardrobeItemCategory? category,
    WardrobeItemStatus? status,
    bool? isFavorite,
    List<WardrobeColorKey>? colorKeys,
    List<WardrobeSeason>? seasons,
    List<WardrobeOccasion>? occasions,
    List<DressCode>? dressCodes,
    String? brand,
    String? size,
    String? material,
    String? notes,
    String? purchasePriceText,
    String? pendingImagePath,
    bool? removeExistingImage,
    bool? isSubmitting,
    String? errorMessage,
    Map<String, String>? fieldErrors,
    String? editingId,
    bool clearError = false,
    bool clearPendingImage = false,
  }) {
    return ItemFormState(
      name: name ?? this.name,
      category: category ?? this.category,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      colorKeys: colorKeys ?? this.colorKeys,
      seasons: seasons ?? this.seasons,
      occasions: occasions ?? this.occasions,
      dressCodes: dressCodes ?? this.dressCodes,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      material: material ?? this.material,
      notes: notes ?? this.notes,
      purchasePriceText: purchasePriceText ?? this.purchasePriceText,
      pendingImagePath: clearPendingImage
          ? null
          : (pendingImagePath ?? this.pendingImagePath),
      removeExistingImage: removeExistingImage ?? this.removeExistingImage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      fieldErrors: fieldErrors ?? this.fieldErrors,
      editingId: editingId ?? this.editingId,
    );
  }
}

class ItemFormController extends StateNotifier<ItemFormState> {
  ItemFormController(this._ref, {WardrobeItem? existing})
    : super(
        existing == null
            ? const ItemFormState()
            : ItemFormState(
                name: existing.name,
                category: existing.category,
                status: existing.status,
                isFavorite: existing.isFavorite,
                colorKeys: existing.colorKeys,
                seasons: existing.seasons,
                occasions: existing.occasions,
                dressCodes: existing.dressCodes,
                brand: existing.brand ?? '',
                size: existing.size ?? '',
                material: existing.material ?? '',
                notes: existing.notes ?? '',
                purchasePriceText: existing.purchasePriceMinor == null
                    ? ''
                    : MoneyFormat.majorStringFromMinor(
                        existing.purchasePriceMinor!,
                      ),
                editingId: existing.id,
              ),
      );

  final Ref _ref;

  void setName(String value) =>
      state = state.copyWith(name: value, clearError: true);
  void setCategory(WardrobeItemCategory value) =>
      state = state.copyWith(category: value);
  void setStatus(WardrobeItemStatus value) =>
      state = state.copyWith(status: value);
  void setFavorite(bool value) => state = state.copyWith(isFavorite: value);
  void setPendingImagePath(String? path) => state = state.copyWith(
    pendingImagePath: path,
    removeExistingImage: false,
  );
  void clearPendingImage() => state = state.copyWith(
    clearPendingImage: true,
    removeExistingImage: true,
  );
  void setOccasions(List<WardrobeOccasion> value) =>
      state = state.copyWith(occasions: value);
  void setDressCodes(List<DressCode> value) =>
      state = state.copyWith(dressCodes: value);
  void setColorKeys(List<WardrobeColorKey> value) =>
      state = state.copyWith(colorKeys: value);

  void hydrate(WardrobeItem existing) {
    if (state.editingId == existing.id && state.name.isNotEmpty) return;
    state = ItemFormState(
      name: existing.name,
      category: existing.category,
      status: existing.status,
      isFavorite: existing.isFavorite,
      colorKeys: existing.colorKeys,
      seasons: existing.seasons,
      occasions: existing.occasions,
      dressCodes: existing.dressCodes,
      brand: existing.brand ?? '',
      size: existing.size ?? '',
      material: existing.material ?? '',
      notes: existing.notes ?? '',
      editingId: existing.id,
    );
  }

  Future<String?> submit() async {
    if (state.isSubmitting) return null;
    final errors = <String, String>{};
    if (state.name.trim().isEmpty) errors['name'] = 'Name is required';
    if (errors.isNotEmpty) {
      state = state.copyWith(fieldErrors: errors);
      return null;
    }
    state = state.copyWith(
      isSubmitting: true,
      fieldErrors: const {},
      clearError: true,
    );
    WardrobeImageReference? createdImage;
    try {
      final repo = _ref.read(wardrobeRepositoryProvider);
      final store = _ref.read(wardrobeImageStoreProvider);
      final uuid = _ref.read(uuidProvider);
      final now = DateTime.now();
      WardrobeItem? existing;
      if (state.isEditing) {
        existing = await repo.getItem(state.editingId!);
        if (existing == null) {
          throw AppException.notFound('Item not found.');
        }
      }
      var image = existing?.imageReference;
      if (state.removeExistingImage && image != null) {
        await store.deleteImage(image);
        image = null;
      }
      if (state.pendingImagePath != null) {
        createdImage = await store.importFromPickedFile(
          state.pendingImagePath!,
        );
        if (image != null) await store.deleteImage(image);
        image = createdImage;
      }
      final item = WardrobeItem(
        id: existing?.id ?? uuid.v4(),
        name: state.name.trim(),
        category: state.category,
        colorKeys: state.colorKeys,
        seasons: state.seasons,
        occasions: state.occasions,
        dressCodes: state.dressCodes,
        brand: state.brand.trim().isEmpty ? null : state.brand.trim(),
        size: state.size.trim().isEmpty ? null : state.size.trim(),
        material: state.material.trim().isEmpty ? null : state.material.trim(),
        status: state.status,
        isFavorite: state.isFavorite,
        imageReference: image,
        notes: state.notes.trim().isEmpty ? null : state.notes.trim(),
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        purchaseDate: existing?.purchaseDate,
        purchasePriceMinor: existing?.purchasePriceMinor,
        purchaseCurrencyCode: existing?.purchaseCurrencyCode,
      );
      if (existing == null) {
        await repo.createItem(item);
      } else {
        await repo.updateItem(item);
      }
      createdImage = null;
      _ref
        ..invalidate(wardrobeItemsProvider)
        ..invalidate(wardrobeOutfitsProvider)
        ..invalidate(wardrobePlansProvider)
        ..invalidate(wardrobeWearProvider);
      state = state.copyWith(isSubmitting: false);
      return item.id;
    } catch (error) {
      if (createdImage != null) {
        await _ref.read(wardrobeImageStoreProvider).deleteImage(createdImage);
      }
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: userFacingErrorMessage(error),
      );
      return null;
    }
  }
}

final addWardrobeItemControllerProvider =
    StateNotifierProvider.autoDispose<ItemFormController, ItemFormState>((ref) {
      return ItemFormController(ref);
    });

final editWardrobeItemControllerProvider = StateNotifierProvider.autoDispose
    .family<ItemFormController, ItemFormState, String>((ref, id) {
      return ItemFormController(ref);
    });
