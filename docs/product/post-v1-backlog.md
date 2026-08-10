# Post–v1 Backlog

Items intentionally **out of scope** for MeMy v1 (`docs/product/v1-scope.md`). Track here so they are not mistaken for release blockers.

## Product

- Live AI Coach (real model) — v1 has no live AI; Coach Preview is internal-only
- Cloud account, sync, multi-device restore
- Notifications / reminders engine
- Bank / open-banking connections
- Nutrition / meal logging with a food database
- Wardrobe and body-composition modules beyond placeholders
- Direct wearable SDKs (Garmin, Fitbit, Whoop, …)
- Weather
- Maps
- Insights as a real analytics engine (v1 is a navigation hub)
- Richer Profile attachments and identity

## Trust & platform

- Counsel-approved Privacy / Terms replacing Drafts
- Hosted policy site + support portal beyond mailto
- Stronger encryption / lock-screen app lock / MFA narratives (only if product adds them)
- Third-party crash / analytics (privacy review required first)
- Automated screenshot pipeline in CI

## Engineering

- Replace debug release signing with CI-managed upload keys
- Broader device lab coverage (foldables, low-RAM, RTL, large fonts)
- Goals API mode for non-production experimentation only until cloud account exists
- Performance budgets and startup tracing on mid-tier devices

## Store / growth

- Localized listings
- Tablet-optimized layouts / screenshot sets
- Play / App Store experiments (custom store listings)

Do not pull these into v1 without an explicit scope change.
