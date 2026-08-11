# Google Sign-In (owner setup)

Do not commit OAuth client secrets.

Mobile will use a currently maintained `google_sign_in` plugin once Android and iOS client IDs exist. Until then, the app talks to the API through `IdentityAuthGateway` so tests never call live Google.

Backend:

- `POST /api/v1/auth/google`
- `google-auth-library` verifies signature, issuer, audience, and expiry
- Identity key is `google` + `sub`
- Email match with an Apple account does not link accounts

Required owner inputs: Android client ID, iOS client ID, backend web client ID (audience), SHA fingerprints.
