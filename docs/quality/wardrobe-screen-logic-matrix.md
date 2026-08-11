# Wardrobe Screen Logic Matrix

Production visibility: `ReleaseCapabilities.wardrobe: true`. Local JSON + app-private images. No AI, no upload.

| Route | Screen | Prod | Data | Loading / empty / error / retry | Primary actions | Persistence | Tests | Status |
|---|---|---|---|---|---|---|---|---|
| `/wardrobe` | WardrobeOverviewScreen | Yes | Future providers | Yes | Add item, items, outfits, suggestions, planner, history | Local | widget | Complete |
| `/wardrobe/items` | WardrobeItemsScreen | Yes | Items | Yes | Filter/search, add, detail | Local | widget | Complete |
| `/wardrobe/items/new` | AddWardrobeItemScreen | Yes | Form + image store | Validation / save error | Save (duplicate-guarded) | Atomic metadata+image | widget | Complete |
| `/wardrobe/items/:id` | WardrobeItemDetailScreen | Yes | Item | Yes | Edit, favorite, delete/archive, wear | Local | widget | Complete |
| `/wardrobe/items/:id/edit` | EditWardrobeItemScreen | Yes | Form | Yes | Save | Local | widget | Complete |
| `/wardrobe/outfits` | OutfitsScreen | Yes | Outfits | Yes | Create, detail | Local | widget | Complete |
| `/wardrobe/outfits/new` | OutfitFormScreen | Yes | Form | Validation | Save | Local | widget | Complete |
| `/wardrobe/outfits/:id` | OutfitDetailScreen | Yes | Outfit | Yes | Edit, plan, wear, delete | Local | widget | Complete |
| `/wardrobe/outfits/:id/edit` | OutfitFormScreen | Yes | Form | Yes | Save | Local | widget | Complete |
| `/wardrobe/suggestions` | OutfitSuggestionsScreen | Yes | Rule engine | Empty explains missing categories | Suggest, save | Local | unit+widget | Complete |
| `/wardrobe/planner` | OutfitPlannerScreen | Yes | Plans + optional event id | Yes | Save plan (replace) | Local | widget | Complete |
| `/wardrobe/history` | WardrobeHistoryScreen | Yes | Wear records | Yes | Delete record | Local | widget | Complete |
| `/settings/wardrobe` | WardrobeSettingsScreen | Yes | Prefs + storage bytes | Yes | Clean orphans | Prefs + files | coverage | Complete |

No production `ComingSoonView` or `WardrobePlaceholderScreen`.
