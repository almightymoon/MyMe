# Dependency Audit (v1 Direct Dependencies)

Source: `apps/mobile/pubspec.yaml`. Versions are caret constraints as declared; lockfile may resolve newer compatible patches.

## Major direct dependencies

| Package | Constraint | Role in v1 |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | State / DI |
| `go_router` | ^17.4.0 | Navigation |
| `drift` (+ `drift_flutter`, `sqlite3_flutter_libs`) | ^2.22.1 | Local SQLite (calendar cache, etc.) |
| `health` | ^13.3.1 | HealthKit / Health Connect **read-only** bridge |
| `device_calendar` | ^4.3.3 | Device calendar read/write |
| `share_plus` | ^12.0.2 | Share export archives / diagnostics |
| `package_info_plus` | ^9.0.1 | About / version display |
| `flutter_markdown` | ^0.7.7+1 | In-app legal & help markdown |
| `url_launcher` | ^6.3.2 | Open links / mailto when configured |
| `shared_preferences` | ^2.5.5 | Local preferences & module JSON stores |
| `path_provider` | ^2.1.5 | Local filesystem paths for export/cache |

## Other direct deps (supporting)

`cupertino_icons`, `google_fonts`, `intl`, `uuid`, `dio`, `flutter_svg`, `path`, `timezone`, `permission_handler`.

`dio` is present for optional/API development paths; **production v1 does not ship Goals via API** (`GOALS_DATA_SOURCE` forced `local`) and does not require network for core features.

## Explicitly absent (v1)

- **No bank / open-banking SDKs**
- **No live AI / LLM vendor SDKs** (Coach Preview is internal-only scripted UI; production hides it)
- **No push-notification / FCM / APNs scheduling SDKs** wired for product reminders
- **No cloud auth / OAuth identity SDKs** for MeMy accounts

## Owner note

Re-run `flutter pub outdated` and license review before store submission if the lockfile has drifted. This document is a product-facing summary, not a full SBOM.
