enum WardrobeItemCategory {
  tops,
  bottoms,
  dresses,
  outerwear,
  footwear,
  activewear,
  traditionalWear,
  formalWear,
  accessories,
  watches,
  bags,
  other;

  String get label => switch (this) {
    WardrobeItemCategory.tops => 'Tops',
    WardrobeItemCategory.bottoms => 'Bottoms',
    WardrobeItemCategory.dresses => 'Dresses',
    WardrobeItemCategory.outerwear => 'Outerwear',
    WardrobeItemCategory.footwear => 'Footwear',
    WardrobeItemCategory.activewear => 'Activewear',
    WardrobeItemCategory.traditionalWear => 'Traditional wear',
    WardrobeItemCategory.formalWear => 'Formal wear',
    WardrobeItemCategory.accessories => 'Accessories',
    WardrobeItemCategory.watches => 'Watches',
    WardrobeItemCategory.bags => 'Bags',
    WardrobeItemCategory.other => 'Other',
  };

  bool get isOnePiece =>
      this == WardrobeItemCategory.dresses ||
      this == WardrobeItemCategory.traditionalWear;

  bool get isPrimaryClothing =>
      this == WardrobeItemCategory.tops ||
      this == WardrobeItemCategory.bottoms ||
      this == WardrobeItemCategory.dresses ||
      this == WardrobeItemCategory.outerwear ||
      this == WardrobeItemCategory.activewear ||
      this == WardrobeItemCategory.traditionalWear ||
      this == WardrobeItemCategory.formalWear;

  static WardrobeItemCategory? tryParse(String? raw) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

enum WardrobeItemStatus {
  available,
  inLaundry,
  needsCleaning,
  unavailable,
  archived;

  String get label => switch (this) {
    WardrobeItemStatus.available => 'Available',
    WardrobeItemStatus.inLaundry => 'In laundry',
    WardrobeItemStatus.needsCleaning => 'Needs cleaning',
    WardrobeItemStatus.unavailable => 'Unavailable',
    WardrobeItemStatus.archived => 'Archived',
  };

  bool get canBeWorn => this == WardrobeItemStatus.available;

  static WardrobeItemStatus? tryParse(String? raw) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

enum WardrobeSeason {
  allSeason,
  spring,
  summer,
  autumn,
  winter;

  String get label => switch (this) {
    WardrobeSeason.allSeason => 'All season',
    WardrobeSeason.spring => 'Spring',
    WardrobeSeason.summer => 'Summer',
    WardrobeSeason.autumn => 'Autumn',
    WardrobeSeason.winter => 'Winter',
  };

  static WardrobeSeason? tryParse(String? raw) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

enum WardrobeOccasion {
  casual,
  work,
  business,
  formal,
  wedding,
  religious,
  interview,
  travel,
  workout,
  outdoor,
  party,
  custom;

  String get label => switch (this) {
    WardrobeOccasion.casual => 'Casual',
    WardrobeOccasion.work => 'Work',
    WardrobeOccasion.business => 'Business',
    WardrobeOccasion.formal => 'Formal',
    WardrobeOccasion.wedding => 'Wedding',
    WardrobeOccasion.religious => 'Religious',
    WardrobeOccasion.interview => 'Interview',
    WardrobeOccasion.travel => 'Travel',
    WardrobeOccasion.workout => 'Workout',
    WardrobeOccasion.outdoor => 'Outdoor',
    WardrobeOccasion.party => 'Party',
    WardrobeOccasion.custom => 'Custom',
  };

  static WardrobeOccasion? tryParse(String? raw) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

enum DressCode {
  casual,
  smartCasual,
  businessCasual,
  businessFormal,
  formal,
  traditional,
  athletic,
  custom;

  String get label => switch (this) {
    DressCode.casual => 'Casual',
    DressCode.smartCasual => 'Smart casual',
    DressCode.businessCasual => 'Business casual',
    DressCode.businessFormal => 'Business formal',
    DressCode.formal => 'Formal',
    DressCode.traditional => 'Traditional',
    DressCode.athletic => 'Athletic',
    DressCode.custom => 'Custom',
  };

  static DressCode? tryParse(String? raw) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

enum ClimateTag {
  hot,
  warm,
  mild,
  cool,
  cold,
  rain,
  dry,
  indoor,
  outdoor;

  String get label => switch (this) {
    ClimateTag.hot => 'Hot',
    ClimateTag.warm => 'Warm',
    ClimateTag.mild => 'Mild',
    ClimateTag.cool => 'Cool',
    ClimateTag.cold => 'Cold',
    ClimateTag.rain => 'Rain',
    ClimateTag.dry => 'Dry',
    ClimateTag.indoor => 'Indoor',
    ClimateTag.outdoor => 'Outdoor',
  };

  static ClimateTag? tryParse(String? raw) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

enum WardrobeColorKey {
  black,
  white,
  navy,
  gray,
  beige,
  brown,
  blue,
  green,
  red,
  pink,
  yellow,
  orange,
  purple,
  cream,
  other;

  String get label => switch (this) {
    WardrobeColorKey.black => 'Black',
    WardrobeColorKey.white => 'White',
    WardrobeColorKey.navy => 'Navy',
    WardrobeColorKey.gray => 'Gray',
    WardrobeColorKey.beige => 'Beige',
    WardrobeColorKey.brown => 'Brown',
    WardrobeColorKey.blue => 'Blue',
    WardrobeColorKey.green => 'Green',
    WardrobeColorKey.red => 'Red',
    WardrobeColorKey.pink => 'Pink',
    WardrobeColorKey.yellow => 'Yellow',
    WardrobeColorKey.orange => 'Orange',
    WardrobeColorKey.purple => 'Purple',
    WardrobeColorKey.cream => 'Cream',
    WardrobeColorKey.other => 'Other',
  };

  static WardrobeColorKey? tryParse(String? raw) {
    for (final value in values) {
      if (value.name == raw) return value;
    }
    return null;
  }
}

enum OutfitValidationIssue {
  missingItems,
  duplicateItems,
  archivedOrUnavailable,
  accessoriesOnly,
  coverageIncomplete,
  dressCodeMismatch,
  occasionMismatch,
  emptyOutfit,
}

extension OutfitValidationIssueCopy on OutfitValidationIssue {
  String get userMessage => switch (this) {
    OutfitValidationIssue.missingItems =>
      'One or more selected items are no longer in your wardrobe.',
    OutfitValidationIssue.duplicateItems =>
      'An outfit cannot include the same item twice.',
    OutfitValidationIssue.archivedOrUnavailable =>
      'Archived or unavailable items cannot be added to a new outfit.',
    OutfitValidationIssue.accessoriesOnly =>
      'Accessories alone cannot form an outfit.',
    OutfitValidationIssue.coverageIncomplete =>
      'Add a dress or both a top and bottoms.',
    OutfitValidationIssue.dressCodeMismatch =>
      'Some items do not match this dress code.',
    OutfitValidationIssue.occasionMismatch =>
      'Some items do not match this occasion.',
    OutfitValidationIssue.emptyOutfit => 'Choose at least one clothing item.',
  };
}
