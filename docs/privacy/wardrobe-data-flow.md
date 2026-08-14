# Wardrobe data flow

```
Gallery picker → app-private JPEG originals/thumbnails
       ↓
Local JSON metadata (SharedPreferences, schema v1)
       ↓
UI / suggestions / Today / Plan  (on device)
```

- No MeMy backend transfer
- No AI / OpenAI image upload
- No inclusion of wardrobe images in support diagnostics
- No logging of local image paths
- EXIF (including geolocation) stripped by re-encode where decoding succeeds

Export: metadata only. Deletion: items, outfits, plans, wear records, originals, thumbnails, then orphan cleanup. Deleting all Wardrobe data does not reseed demo clothes.
