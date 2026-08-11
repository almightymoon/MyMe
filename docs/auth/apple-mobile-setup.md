# Sign in with Apple (mobile)

Package: `sign_in_with_apple` `^6.1.4`.

The app generates a cryptographically secure nonce, sends SHA-256(nonce) to Apple, and posts the identity token plus the original nonce to `POST /api/v1/auth/apple`. The API verifies signature, issuer, audience (`APPLE_CLIENT_ID`), expiry, and nonce.

Apple Sign-In is shown only on iOS. First authorization may include name/email; later authorizations may omit them. Hide-my-email addresses are accepted. Providers are never linked by matching email.

## Owner inputs (do not invent)

- Apple Team ID
- Bundle ID `com.moontech.memy` with Sign in with Apple capability (already listed in `Runner.entitlements`)
- Services ID / app ID used as token audience (`APPLE_CLIENT_ID`)
- If the API verifies tokens with a client secret, the Apple private key stays on the VPS and is never committed

## iOS

Xcode: Signing & Capabilities → Sign in with Apple. The entitlement `com.apple.developer.applesignin` is present in `apps/mobile/ios/Runner/Runner.entitlements`.

## Privacy

MeMy does not require a non-private email. Identity tokens are not stored after exchange.
