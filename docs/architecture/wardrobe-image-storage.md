# Wardrobe image storage

## Layout

App documents directory:

- `wardrobe/originals/<random-id>.jpg`
- `wardrobe/thumbnails/<random-id>.jpg`

Domain models store **relative** paths only (`originals/…`, `thumbnails/…`). Filenames are random ids, never the user’s name, item name, brand, or original file name.

## Import

1. System photo picker (`image_picker`, gallery only, `requestFullMetadata: false`)
2. Copy into app-private storage
3. Decode, `bakeOrientation`, JPEG re-encode (strips EXIF including location)
4. Cap edge length (2048 original, 256 thumbnail) and reject files over 8 MB or undecodable bytes

Replacement writes the new files first, then deletes the previous pair. Item deletion deletes image files after metadata deletion succeeds. Settings can clean orphan files.

## Dependencies

| Package | Purpose | Privacy |
|---|---|---|
| `image_picker` | System gallery/photo picker | No broad photo-library permission on modern Android Photo Picker; iOS usage string describes on-device copy only |
| `image` | Decode/re-encode, orientation, thumbnails | Processing stays on device |
| `path_provider` | App documents directory | Already used by MeMy |

Camera capture is not implemented. No `READ_EXTERNAL_STORAGE` added for v1.

## Export / diagnostics

v1 export includes image **metadata** (relative paths, size, mime) and the warning: “Wardrobe image files are not included in this export.” Diagnostics may include schema version, counts, and total image bytes — never paths, names, or pixels.
