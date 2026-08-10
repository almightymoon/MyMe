# Support Center

Offline Help Center at `/support`.

## Features
- Categorized articles (assets under `assets/trust/support/`)
- Local keyword search
- Contact Support (`/support/contact`)
- Report a Problem (`/support/report`)
- Feature Request (`/support/feature`)

## Configuration
```bash
--dart-define=SUPPORT_EMAIL=support@example.com
```
When unset, the app explains that email support is not configured and still
allows generating / sharing a redacted support report.

## Truthful contact behavior
Opening the email app does **not** claim the message was sent.
MeMy cannot confirm delivery without a support backend.

## Diagnostics
`SupportReportBuilder` uses an allowlist only:
app version, OS, locale, timezone, integration statuses, sanitized codes,
schema versions, data-source modes.

Forbidden: Goals/Finance/Habits content, Calendar titles/notes/locations,
Health values, source-device IDs, secrets, raw stack traces.
