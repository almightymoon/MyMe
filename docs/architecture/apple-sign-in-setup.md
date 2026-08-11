# Sign in with Apple (owner setup)

Never commit the `.p8` private key.

Required owner inputs (see `docs/release/production-owner-inputs.md`):

- Apple Developer Team ID
- iOS bundle identifier
- Services ID if a web redirect is used
- Key ID
- Sign in with Apple capability on the App ID
- Backend audience (`APPLE_CLIENT_ID`), usually the iOS bundle ID

Mobile:

- Native `sign_in_with_apple` authorization
- SHA-256 nonce sent to the API
- Name/email may appear only on the first authorization

Backend:

- `POST /api/v1/auth/apple`
- Verifies issuer `https://appleid.apple.com`, audience, expiry, signature, nonce
- Identity key is `apple` + `sub`, not email
