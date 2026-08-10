# Public web placeholders (Draft)

This folder is a **placeholder** for content MoonTech will host for store listings and support. Nothing here invents a company street address, registration number, governing law, or live production URL.

## Status

| Page | Purpose | Status |
|---|---|---|
| Privacy Policy | Required public URL for App Store / Play | **Draft** — source of truth today is `apps/mobile/assets/trust/legal/privacy-policy.md`. Owner/legal review required before hosting. |
| Terms of Use | Store / in-app legal | **Draft** — `assets/trust/legal/terms-of-use.md` |
| Health disclaimer | Clarify non-medical use | **Draft** — `assets/trust/legal/health-disclaimer.md` |
| Financial disclaimer | Clarify non-advice / manual ledger | **Draft** — `assets/trust/legal/financial-disclaimer.md` |
| Support | Contact / FAQ landing | **Placeholder** — `SUPPORT_EMAIL` is empty by default in the app; owner must choose an inbox and (optionally) a hosted support page |

## What to publish (when ready)

1. Have counsel approve the four legal drafts.
2. Render them as stable HTTPS pages on a domain MoonTech controls.
3. Record the live URLs in `docs/release/public-policy-hosting.md`.
4. Keep in-app markdown and hosted HTML on the same version / effective date.
5. Do **not** paste fictional addresses, tax IDs, or choice-of-law clauses into these placeholders.

## Support page outline (no invented contact details)

Suggested sections once the owner fills real values:

- How to reach MoonTech about MeMy (_email TBD_)
- What data stays on device vs Health Connect / device calendar
- How to export or delete local data (points at in-app Privacy & Data)
- What v1 does not include (cloud sync, live AI, bank sync, medical advice, notifications)

Until those values exist, App Store Connect / Play Console contact fields and `--dart-define=SUPPORT_EMAIL=...` remain owner actions.

## Related

- `docs/release/public-policy-hosting.md`
- `docs/release/owner-actions.md`
- `docs/product/v1-scope.md`
