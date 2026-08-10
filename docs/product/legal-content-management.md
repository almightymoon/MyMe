# Legal content management

Documents live as offline Markdown under `assets/trust/legal/` with typed
metadata (`TrustDocument`, `TrustDocumentStatus`).

## Current documents
| Type | Asset | Status |
|------|-------|--------|
| Privacy Policy | `privacy-policy.md` | **draft** v0.1.0 |
| Terms of Use | `terms-of-use.md` | **draft** v0.1.0 |
| Health Disclaimer | `health-disclaimer.md` | **draft** v0.1.0 |
| Financial Disclaimer | `financial-disclaimer.md` | **draft** v0.1.0 |

## Review process
1. Product updates Markdown + metadata version / effective date.
2. Legal review changes status to `legallyReviewed` then `published`.
3. Until then, UI shows: “Draft — requires legal review before public
   production release.”

Do not claim documents are legally approved while status is `draft`.
Do not fetch legal HTML from the network in this milestone.
