#!/usr/bin/env bash
# Run the Flutter app against the live VPS API.
# OAuth client IDs stay in the environment — never commit them.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

if [[ -z "${GOOGLE_SERVER_CLIENT_ID:-}" ]]; then
  echo "Set GOOGLE_SERVER_CLIENT_ID (Google web/backend client ID)." >&2
  exit 1
fi

flutter run \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=account \
  --dart-define=API_BASE_URL=https://api.memy.athariqbal.com/api/v1 \
  --dart-define=GOOGLE_SERVER_CLIENT_ID="${GOOGLE_SERVER_CLIENT_ID}" \
  --dart-define=GOOGLE_IOS_CLIENT_ID="${GOOGLE_IOS_CLIENT_ID:-}" \
  --dart-define=SUPPORT_EMAIL="${SUPPORT_EMAIL:-support@athariqbal.com}" \
  "$@"
