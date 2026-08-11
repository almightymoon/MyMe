# Smart Wardrobe v1

Local wardrobe, outfits, planning, and wear history. Photos stay in app-private storage on the device.

## Included

- Items (create, edit, filter, favorite, archive, delete)
- Optional photos from the system gallery/photo picker (not camera in v1)
- Outfits (validation, one-piece dress rule, accessories-only rejected)
- Deterministic local outfit suggestions (not AI)
- Date plans with an optional read-only Calendar event reference
- Wear history
- Today’s planned outfit and Plan upcoming looks
- Settings: recent-wear avoidance, optional default dress code/climate tag, purchase-info toggle, orphan photo cleanup
- Export of metadata only; local deletion of metadata and image files

## Suggestions

Copy: “Suggestions are created locally from your available wardrobe items.”

Never: “AI styled this outfit,” live weather, shopping links, or cloud upload.

Climate tags are chosen by the user. Today’s Open-Meteo glance is not wired into outfit scoring.

## Calendar

Plan Outfit on an event opens the planner with that event id. MeMy does not edit the device event. If the event disappears, the date plan remains and the link is marked unavailable.

## Out of scope

Cloud photos, wardrobe APIs, body scan, virtual try-on, generative images, live AI classification, fashion APIs, social sharing, weather networking for outfits, camera capture, laundry-device integrations.
