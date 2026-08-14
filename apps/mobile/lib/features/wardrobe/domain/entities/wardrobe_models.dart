import '../../../../core/domain/value_objects/local_date.dart';
import '../../../../core/domain/value_objects/money_minor.dart';
import 'wardrobe_enums.dart';

class WardrobeImageReference {
  const WardrobeImageReference({
    required this.id,
    required this.relativeOriginalPath,
    required this.relativeThumbnailPath,
    required this.mimeType,
    required this.width,
    required this.height,
    required this.byteSize,
    required this.createdAt,
  });

  final String id;
  final String relativeOriginalPath;
  final String relativeThumbnailPath;
  final String mimeType;
  final int width;
  final int height;
  final int byteSize;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'relativeOriginalPath': relativeOriginalPath,
    'relativeThumbnailPath': relativeThumbnailPath,
    'mimeType': mimeType,
    'width': width,
    'height': height,
    'byteSize': byteSize,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  static WardrobeImageReference? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final id = json['id'] as String?;
      final original = json['relativeOriginalPath'] as String?;
      final thumb = json['relativeThumbnailPath'] as String?;
      final mime = json['mimeType'] as String? ?? 'image/jpeg';
      final width = (json['width'] as num?)?.toInt() ?? 0;
      final height = (json['height'] as num?)?.toInt() ?? 0;
      final bytes = (json['byteSize'] as num?)?.toInt() ?? 0;
      final created = DateTime.tryParse(
        json['createdAt'] as String? ?? '',
      )?.toLocal();
      if (id == null ||
          id.isEmpty ||
          original == null ||
          original.isEmpty ||
          original.startsWith('/') ||
          thumb == null ||
          thumb.isEmpty ||
          thumb.startsWith('/') ||
          created == null) {
        return null;
      }
      return WardrobeImageReference(
        id: id,
        relativeOriginalPath: original,
        relativeThumbnailPath: thumb,
        mimeType: mime,
        width: width,
        height: height,
        byteSize: bytes,
        createdAt: created,
      );
    } catch (_) {
      return null;
    }
  }
}

class WardrobeItem {
  const WardrobeItem({
    required this.id,
    required this.name,
    required this.category,
    required this.status,
    required this.isFavorite,
    required this.colorKeys,
    required this.seasons,
    required this.occasions,
    required this.dressCodes,
    required this.createdAt,
    required this.updatedAt,
    this.subcategory,
    this.description,
    this.brand,
    this.size,
    this.material,
    this.imageReference,
    this.purchaseDate,
    this.purchasePriceMinor,
    this.purchaseCurrencyCode,
    this.notes,
    this.archivedAt,
  });

  final String id;
  final String name;
  final WardrobeItemCategory category;
  final String? subcategory;
  final String? description;
  final List<WardrobeColorKey> colorKeys;
  final List<WardrobeSeason> seasons;
  final List<WardrobeOccasion> occasions;
  final List<DressCode> dressCodes;
  final String? brand;
  final String? size;
  final String? material;
  final WardrobeItemStatus status;
  final bool isFavorite;
  final WardrobeImageReference? imageReference;
  final LocalDate? purchaseDate;
  final MoneyMinor? purchasePriceMinor;
  final String? purchaseCurrencyCode;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived =>
      archivedAt != null || status == WardrobeItemStatus.archived;

  WardrobeItem copyWith({
    String? name,
    WardrobeItemCategory? category,
    String? subcategory,
    String? description,
    List<WardrobeColorKey>? colorKeys,
    List<WardrobeSeason>? seasons,
    List<WardrobeOccasion>? occasions,
    List<DressCode>? dressCodes,
    String? brand,
    String? size,
    String? material,
    WardrobeItemStatus? status,
    bool? isFavorite,
    WardrobeImageReference? imageReference,
    LocalDate? purchaseDate,
    MoneyMinor? purchasePriceMinor,
    String? purchaseCurrencyCode,
    String? notes,
    DateTime? updatedAt,
    DateTime? archivedAt,
    bool clearImage = false,
    bool clearArchivedAt = false,
    bool clearPurchase = false,
  }) {
    return WardrobeItem(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      description: description ?? this.description,
      colorKeys: colorKeys ?? this.colorKeys,
      seasons: seasons ?? this.seasons,
      occasions: occasions ?? this.occasions,
      dressCodes: dressCodes ?? this.dressCodes,
      brand: brand ?? this.brand,
      size: size ?? this.size,
      material: material ?? this.material,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      imageReference: clearImage
          ? null
          : (imageReference ?? this.imageReference),
      purchaseDate: clearPurchase ? null : (purchaseDate ?? this.purchaseDate),
      purchasePriceMinor: clearPurchase
          ? null
          : (purchasePriceMinor ?? this.purchasePriceMinor),
      purchaseCurrencyCode: clearPurchase
          ? null
          : (purchaseCurrencyCode ?? this.purchaseCurrencyCode),
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category.name,
    'subcategory': subcategory,
    'description': description,
    'colorKeys': colorKeys.map((c) => c.name).toList(),
    'seasons': seasons.map((s) => s.name).toList(),
    'occasions': occasions.map((o) => o.name).toList(),
    'dressCodes': dressCodes.map((d) => d.name).toList(),
    'brand': brand,
    'size': size,
    'material': material,
    'status': status.name,
    'isFavorite': isFavorite,
    'imageReference': imageReference?.toJson(),
    'purchaseDate': purchaseDate?.toIso8601String(),
    'purchasePriceMinor': purchasePriceMinor?.toJson(),
    'purchaseCurrencyCode': purchaseCurrencyCode,
    'notes': notes,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'archivedAt': archivedAt?.toUtc().toIso8601String(),
  };

  static WardrobeItem? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final id = json['id'] as String?;
      final name = json['name'] as String?;
      final category = WardrobeItemCategory.tryParse(
        json['category'] as String?,
      );
      final status =
          WardrobeItemStatus.tryParse(json['status'] as String?) ??
          WardrobeItemStatus.available;
      final created = DateTime.tryParse(
        json['createdAt'] as String? ?? '',
      )?.toLocal();
      final updated = DateTime.tryParse(
        json['updatedAt'] as String? ?? '',
      )?.toLocal();
      if (id == null ||
          id.isEmpty ||
          name == null ||
          name.trim().isEmpty ||
          category == null ||
          created == null ||
          updated == null) {
        return null;
      }
      MoneyMinor? price;
      if (json['purchasePriceMinor'] != null) {
        price = MoneyMinor.tryParse(json['purchasePriceMinor']);
      }
      return WardrobeItem(
        id: id,
        name: name.trim(),
        category: category,
        subcategory: json['subcategory'] as String?,
        description: json['description'] as String?,
        colorKeys: _parseColors(json['colorKeys']),
        seasons: _parseSeasons(json['seasons']),
        occasions: _parseOccasions(json['occasions']),
        dressCodes: _parseDressCodes(json['dressCodes']),
        brand: json['brand'] as String?,
        size: json['size'] as String?,
        material: json['material'] as String?,
        status: status,
        isFavorite: json['isFavorite'] == true,
        imageReference: json['imageReference'] is Map
            ? WardrobeImageReference.fromJson(
                Map<String, dynamic>.from(json['imageReference'] as Map),
              )
            : null,
        purchaseDate: () {
          final raw = json['purchaseDate'] as String?;
          if (raw == null || raw.isEmpty) return null;
          return LocalDate.tryParse(raw);
        }(),
        purchasePriceMinor: price,
        purchaseCurrencyCode: (json['purchaseCurrencyCode'] as String?)
            ?.trim()
            .toUpperCase(),
        notes: json['notes'] as String?,
        createdAt: created,
        updatedAt: updated,
        archivedAt: DateTime.tryParse(
          json['archivedAt'] as String? ?? '',
        )?.toLocal(),
      );
    } catch (_) {
      return null;
    }
  }
}

class Outfit {
  const Outfit({
    required this.id,
    required this.name,
    required this.itemIds,
    required this.occasions,
    required this.dressCode,
    required this.season,
    required this.climateTags,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.archivedAt,
  });

  final String id;
  final String name;
  final List<String> itemIds;
  final List<WardrobeOccasion> occasions;
  final DressCode dressCode;
  final WardrobeSeason season;
  final List<ClimateTag> climateTags;
  final bool isFavorite;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? archivedAt;

  bool get isArchived => archivedAt != null;

  Outfit copyWith({
    String? name,
    List<String>? itemIds,
    List<WardrobeOccasion>? occasions,
    DressCode? dressCode,
    WardrobeSeason? season,
    List<ClimateTag>? climateTags,
    bool? isFavorite,
    String? notes,
    DateTime? updatedAt,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
  }) {
    return Outfit(
      id: id,
      name: name ?? this.name,
      itemIds: itemIds ?? this.itemIds,
      occasions: occasions ?? this.occasions,
      dressCode: dressCode ?? this.dressCode,
      season: season ?? this.season,
      climateTags: climateTags ?? this.climateTags,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'itemIds': itemIds,
    'occasions': occasions.map((o) => o.name).toList(),
    'dressCode': dressCode.name,
    'season': season.name,
    'climateTags': climateTags.map((c) => c.name).toList(),
    'isFavorite': isFavorite,
    'notes': notes,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
    'archivedAt': archivedAt?.toUtc().toIso8601String(),
  };

  static Outfit? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final id = json['id'] as String?;
      final name = json['name'] as String?;
      final dressCode = DressCode.tryParse(json['dressCode'] as String?);
      final season =
          WardrobeSeason.tryParse(json['season'] as String?) ??
          WardrobeSeason.allSeason;
      final created = DateTime.tryParse(
        json['createdAt'] as String? ?? '',
      )?.toLocal();
      final updated = DateTime.tryParse(
        json['updatedAt'] as String? ?? '',
      )?.toLocal();
      final itemIds = (json['itemIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList();
      if (id == null ||
          id.isEmpty ||
          name == null ||
          name.trim().isEmpty ||
          dressCode == null ||
          created == null ||
          updated == null) {
        return null;
      }
      return Outfit(
        id: id,
        name: name.trim(),
        itemIds: itemIds,
        occasions: _parseOccasions(json['occasions']),
        dressCode: dressCode,
        season: season,
        climateTags: _parseClimate(json['climateTags']),
        isFavorite: json['isFavorite'] == true,
        notes: json['notes'] as String?,
        createdAt: created,
        updatedAt: updated,
        archivedAt: DateTime.tryParse(
          json['archivedAt'] as String? ?? '',
        )?.toLocal(),
      );
    } catch (_) {
      return null;
    }
  }
}

class OutfitPlan {
  const OutfitPlan({
    required this.id,
    required this.outfitId,
    required this.localDate,
    required this.occasion,
    required this.dressCode,
    required this.createdAt,
    required this.updatedAt,
    this.calendarEventId,
    this.calendarEventSource,
    this.eventLinkUnavailable = false,
    this.notes,
  });

  final String id;
  final String outfitId;
  final LocalDate localDate;
  final String? calendarEventId;
  final String? calendarEventSource;
  final bool eventLinkUnavailable;
  final WardrobeOccasion occasion;
  final DressCode dressCode;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  OutfitPlan copyWith({
    String? outfitId,
    LocalDate? localDate,
    String? calendarEventId,
    String? calendarEventSource,
    bool? eventLinkUnavailable,
    WardrobeOccasion? occasion,
    DressCode? dressCode,
    String? notes,
    DateTime? updatedAt,
    bool clearCalendar = false,
  }) {
    return OutfitPlan(
      id: id,
      outfitId: outfitId ?? this.outfitId,
      localDate: localDate ?? this.localDate,
      calendarEventId: clearCalendar
          ? null
          : (calendarEventId ?? this.calendarEventId),
      calendarEventSource: clearCalendar
          ? null
          : (calendarEventSource ?? this.calendarEventSource),
      eventLinkUnavailable: eventLinkUnavailable ?? this.eventLinkUnavailable,
      occasion: occasion ?? this.occasion,
      dressCode: dressCode ?? this.dressCode,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'outfitId': outfitId,
    'localDate': localDate.toIso8601String(),
    'calendarEventId': calendarEventId,
    'calendarEventSource': calendarEventSource,
    'eventLinkUnavailable': eventLinkUnavailable,
    'occasion': occasion.name,
    'dressCode': dressCode.name,
    'notes': notes,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  static OutfitPlan? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final id = json['id'] as String?;
      final outfitId = json['outfitId'] as String?;
      final rawDate = json['localDate'] as String?;
      final date = rawDate == null ? null : LocalDate.tryParse(rawDate);
      final occasion =
          WardrobeOccasion.tryParse(json['occasion'] as String?) ??
          WardrobeOccasion.casual;
      final dressCode =
          DressCode.tryParse(json['dressCode'] as String?) ?? DressCode.casual;
      final created = DateTime.tryParse(
        json['createdAt'] as String? ?? '',
      )?.toLocal();
      final updated = DateTime.tryParse(
        json['updatedAt'] as String? ?? '',
      )?.toLocal();
      if (id == null ||
          outfitId == null ||
          date == null ||
          created == null ||
          updated == null) {
        return null;
      }
      return OutfitPlan(
        id: id,
        outfitId: outfitId,
        localDate: date,
        calendarEventId: json['calendarEventId'] as String?,
        calendarEventSource: json['calendarEventSource'] as String?,
        eventLinkUnavailable: json['eventLinkUnavailable'] == true,
        occasion: occasion,
        dressCode: dressCode,
        notes: json['notes'] as String?,
        createdAt: created,
        updatedAt: updated,
      );
    } catch (_) {
      return null;
    }
  }
}

class WearRecord {
  const WearRecord({
    required this.id,
    required this.localDate,
    required this.itemIds,
    required this.createdAt,
    required this.updatedAt,
    this.outfitId,
    this.calendarEventId,
    this.notes,
  });

  final String id;
  final LocalDate localDate;
  final String? outfitId;
  final List<String> itemIds;
  final String? calendarEventId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'localDate': localDate.toIso8601String(),
    'outfitId': outfitId,
    'itemIds': itemIds,
    'calendarEventId': calendarEventId,
    'notes': notes,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  static WearRecord? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    try {
      final id = json['id'] as String?;
      final rawDate = json['localDate'] as String?;
      final date = rawDate == null ? null : LocalDate.tryParse(rawDate);
      final created = DateTime.tryParse(
        json['createdAt'] as String? ?? '',
      )?.toLocal();
      final updated = DateTime.tryParse(
        json['updatedAt'] as String? ?? '',
      )?.toLocal();
      final itemIds = (json['itemIds'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList();
      if (id == null || date == null || created == null || updated == null) {
        return null;
      }
      return WearRecord(
        id: id,
        localDate: date,
        outfitId: json['outfitId'] as String?,
        itemIds: itemIds,
        calendarEventId: json['calendarEventId'] as String?,
        notes: json['notes'] as String?,
        createdAt: created,
        updatedAt: updated,
      );
    } catch (_) {
      return null;
    }
  }
}

class OutfitSuggestionRequest {
  const OutfitSuggestionRequest({
    required this.localDate,
    required this.occasion,
    required this.dressCode,
    this.climateTags = const [],
    this.calendarEventId,
    this.preferredColorKeys = const [],
    this.excludedItemIds = const <String>{},
    this.maximumSuggestions = 3,
    this.avoidRecentlyWornDays = 7,
  });

  final LocalDate localDate;
  final WardrobeOccasion occasion;
  final DressCode dressCode;
  final List<ClimateTag> climateTags;
  final String? calendarEventId;
  final List<WardrobeColorKey> preferredColorKeys;
  final Set<String> excludedItemIds;
  final int maximumSuggestions;
  final int avoidRecentlyWornDays;
}

class OutfitSuggestion {
  const OutfitSuggestion({
    required this.itemIds,
    required this.score,
    required this.reasons,
    required this.warnings,
    required this.occasionMatch,
    required this.dressCodeMatch,
    required this.climateMatch,
    required this.colorCompatibility,
    required this.recentWearPenalty,
  });

  final List<String> itemIds;
  final int score;
  final List<String> reasons;
  final List<String> warnings;
  final bool occasionMatch;
  final bool dressCodeMatch;
  final bool climateMatch;
  final bool colorCompatibility;
  final int recentWearPenalty;
}

List<WardrobeColorKey> _parseColors(Object? raw) =>
    (raw as List<dynamic>? ?? [])
        .map((e) => WardrobeColorKey.tryParse(e as String?))
        .whereType<WardrobeColorKey>()
        .toList();

List<WardrobeSeason> _parseSeasons(Object? raw) => (raw as List<dynamic>? ?? [])
    .map((e) => WardrobeSeason.tryParse(e as String?))
    .whereType<WardrobeSeason>()
    .toList();

List<WardrobeOccasion> _parseOccasions(Object? raw) =>
    (raw as List<dynamic>? ?? [])
        .map((e) => WardrobeOccasion.tryParse(e as String?))
        .whereType<WardrobeOccasion>()
        .toList();

List<DressCode> _parseDressCodes(Object? raw) => (raw as List<dynamic>? ?? [])
    .map((e) => DressCode.tryParse(e as String?))
    .whereType<DressCode>()
    .toList();

List<ClimateTag> _parseClimate(Object? raw) => (raw as List<dynamic>? ?? [])
    .map((e) => ClimateTag.tryParse(e as String?))
    .whereType<ClimateTag>()
    .toList();
