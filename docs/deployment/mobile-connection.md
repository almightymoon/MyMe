# Mobile ↔ VPS connection

The mobile app never embeds VPS secrets. It connects with **dart-defines** at
build time and stores refresh credentials in the platform secure store after
Google / Sign in with Apple exchange.

## Staging build (TestFlight / internal APK)

```bash
cd apps/mobile
flutter build ipa \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=account \
  --dart-define=API_BASE_URL=https://staging-api.<your-domain>/api/v1 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<staging-web-client-id> \
  --dart-define=GOOGLE_IOS_CLIENT_ID=<staging-ios-client-id> \
  --dart-define=SUPPORT_EMAIL=support@<your-domain>
```

Android uses the same `GOOGLE_SERVER_CLIENT_ID` (web/backend client) for the
ID token audience. Register the release keystore SHA-1/SHA-256 in Google Cloud
for the Android OAuth client.

## Production build

Use the production API hostname and **separate** OAuth clients from staging:

```bash
flutter build appbundle \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=account \
  --dart-define=API_BASE_URL=https://api.memy.athariqbal.com/api/v1 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<production-web-client-id> \
  --dart-define=GOOGLE_IOS_CLIENT_ID=<production-ios-client-id> \
  --dart-define=SUPPORT_EMAIL=support@athariqbal.com
```

Run against the live VPS from a device/simulator:

```bash
./apps/mobile/tool/run_vps.sh
```

`EnvironmentConfig.validate()` rejects production builds that still point at
`localhost`, private LAN, `.invalid`, or non-HTTPS API hosts.

## What the app does at runtime

1. User signs in with Google or Apple (native SDK).
2. Mobile sends the provider ID token to `POST /api/v1/auth/google` or
   `POST /api/v1/auth/apple`.
3. API returns a short-lived access token + rotating refresh token.
4. Refresh token is stored in `flutter_secure_storage` (Keychain / EncryptedSharedPreferences).
5. Module sync pushes local mutations through the durable outbox and pulls with string cursors.
6. Wardrobe images upload through presigned MinIO URLs — the bucket is never public.

## Health check from a device

After deploy, confirm:

```bash
curl -fsS https://api.memy.athariqbal.com/api/v1/health
```

Expected JSON includes `"status":"ok"` and `"database":"up"`.

## Never ship in the mobile binary

- PostgreSQL passwords
- JWT / refresh secrets or pepper
- MinIO root or access keys
- VPS SSH keys

Those live only in `/etc/memy/**` on the server.
