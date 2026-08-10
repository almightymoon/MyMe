# Public Policy Hosting

## Current state

| Asset | Status |
|---|---|
| In-app Privacy Policy | **Draft** markdown in `apps/mobile/assets/trust/legal/privacy-policy.md` |
| In-app Terms of Use | **Draft** |
| Health disclaimer | **Draft** |
| Financial disclaimer | **Draft** |
| Hosted privacy URL for store listings | **None yet** — owner must host |
| Support email (`SUPPORT_EMAIL`) | **Empty by default** — owner must set for store contact |

Drafts are **not** legal-counsel approved. Owner / legal review is required before treating them as binding store policies.

## Why hosting matters

- Google Play and App Store Connect require a **public Privacy Policy URL**.
- Health Connect / Apple Health disclosures often link outward to the same policy.
- In-app markdown alone does not satisfy store URL fields.

## Owner checklist

1. Finalize Privacy Policy, Terms, Health disclaimer, and Financial disclaimer with counsel.
2. Host canonical HTML (or markdown-rendered) pages on a domain MoonTech controls.
3. Record the URLs here (fill in when live):

| Document | Public URL |
|---|---|
| Privacy Policy | _TBD — owner hosts_ |
| Terms of Use | _TBD — owner hosts_ |
| Support / contact | _TBD — owner hosts or mailto_ |
| Health data addendum (optional) | _TBD_ |

4. Pass `--dart-define=SUPPORT_EMAIL=...` on production builds once an inbox exists.
5. Keep in-app `assets/trust/legal/*` synchronized with the hosted versions (same effective date / version).

See also `docs/public/README.md` for placeholder public pages.
