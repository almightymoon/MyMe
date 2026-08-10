# Trust & support foundation

## Packages
| Package | Version (approx) | Reason |
|---------|------------------|--------|
| `package_info_plus` | ^9 | App version / build |
| `url_launcher` | ^6 | mailto when SUPPORT_EMAIL set |
| `share_plus` | ^12 | Share export / support reports |
| `flutter_markdown` | ^0.7 | Offline legal / article rendering |
| `path_provider` | existing | Temp export files |

`flutter_markdown` is discontinued upstream in favor of `flutter_markdown_plus`;
acceptable for this milestone — revisit before production.

## Modules
- `features/trust` — privacy, support, legal, about, export, deletion
- `DataModuleRegistry` — capability source for catalog / export / deletion
- `ExportFileLifecycleService` — temp export cleanup policy
- `SupportDiagnosticsReport` — typed allowlist diagnostics (no blacklist walk)
- `features/shell/.../sidebar` — typed drawer destinations
- Assets: `assets/trust/{legal,support,changelog}`

## Boundaries enforced in code
- Local wipe never calls API `deleteGoal` (cache clear only in API mode)
- Global wipe never expands to device calendar event deletion
- Health wipe merges cache + connection into a single disconnect
- Export uses `exportVersion: 2` with app version/build and data-source modes
- Diagnostics serialize only typed fields

## Configuration
- `SUPPORT_EMAIL` dart-define (optional)
- Theme mode: System / Light / Dark via SharedPreferences (`appearance_preferences`)

## Non-claims
No E2EE, HIPAA, GDPR certification, MFA, or biometric app lock in this build.
Legal documents remain **draft — requires legal review**.
