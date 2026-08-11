# Google Sign-In (mobile)

Package: `google_sign_in` `^6.3.0`.

The mobile app requests an ID token whose audience is the backend web client ID (`GOOGLE_SERVER_CLIENT_ID`). The Nest API verifies signature, issuer, audience, and expiry with `google-auth-library`. MeMy never stores the Google ID token after exchange.

## Owner inputs (do not invent)

- Android package: `com.moontech.memy`
- iOS bundle ID: `com.moontech.memy`
- Google Cloud project
- Android OAuth client (package + SHA-1 / SHA-256 of the upload keystore)
- iOS OAuth client
- Web client ID used as backend audience (`GOOGLE_CLIENT_ID` / `--dart-define=GOOGLE_SERVER_CLIENT_ID=`)
- Optional iOS client ID (`GOOGLE_IOS_CLIENT_ID`) and reversed client URL scheme in `Info.plist`

## Android

1. Create the Android OAuth client for `com.moontech.memy`.
2. Place `google-services.json` locally if the Google Services plugin is used. Do not commit production files.
3. Pass `--dart-define=GOOGLE_SERVER_CLIENT_ID=<web-client-id>` on release builds.

## iOS

1. Create the iOS OAuth client for `com.moontech.memy`.
2. Add the reversed client ID URL scheme when Google documents it for the client.
3. Keep HealthKit and Calendar usage strings intact.

## Privacy

Google receives a basic identity request (openid, email, profile). MeMy sends only the ID token to the API. Display name/email are taken from the verified token, not from the client.
