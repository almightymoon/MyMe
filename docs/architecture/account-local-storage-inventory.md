# Account-local storage inventory

User-owned stores are namespaced by backend user ID after sign-in. Raw user IDs are not used in Wardrobe image directory names; those use a SHA-256 prefix.

| Store | Technology | Schema | Isolation | Migration | Deletion | Export | Sync |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Profile / onboarding prefs | SharedPreferences | v1 keys | `memy.acct.<id>.` prefix when signed in; legacy unprefixed until explicit migration | Explicit A/B/C, never auto-merge | Logout-and-remove deletes account keys | Local JSON + optional backend export | Profile/preferences entities |
| Goals | SharedPreferences JSON | v1 | Account key | Same | Account keys | Goals JSON | `goal` |
| Finance | SharedPreferences JSON | v3 | Account key | Same | Account keys | Finance JSON | categories/tx/budgets/positions |
| Habits | SharedPreferences JSON | v2 | Account key | Same | Account keys | Habits JSON | habit/check-in/revisions/periods |
| Wardrobe metadata | SharedPreferences JSON | v1 | Account key | Same | Account keys | Metadata only | items/outfits/plans/wear |
| Wardrobe images | App documents | JPEG copies | `wardrobe/<hash16>/` | Copy into account dir on migrate | Delete account dir | Not raw files in backend export | Private MinIO assets |
| Calendar MeMy events | Drift `memy_calendar` | v3 | Device DB; MeMy-owned rows sync | Keep imported rows local | Tombstone MeMy events only | MeMy-owned metadata | `memyCalendarEvent` |
| Calendar device links | Drift / prefs | v3 | Account + device | Stay device-local | Device-local | Excluded | Never |
| Health connection | Prefs schema v2 | v2 | Account + device | Stay device-local | Connection config only | Excluded values | Never |
| Sync outbox/cursor/conflicts/assets | sqlite `sync/<hash>.sqlite` | v1 tables | Account file | New file per account | Delete file on remove | Queues excluded | All approved entities |
| Secure session | flutter_secure_storage | n/a | Device keychain | n/a | Cleared on logout | Excluded | n/a |

Legacy unowned data (`AccountLocalStore.legacyUnownedMarker`) is quarantined until the signed-in user chooses Move, Start empty, or Decide later.
