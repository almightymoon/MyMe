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
- `features/shell/.../sidebar` — typed drawer destinations
- Assets: `assets/trust/{legal,support,changelog}`

## Configuration
- `SUPPORT_EMAIL` dart-define (optional)
- Theme mode: System / Light via SharedPreferences (`appearance_preferences`)

## Non-claims
No E2EE, HIPAA, GDPR certification, MFA, or biometric app lock in this build.
