#!/usr/bin/env bash
# Safe deploy helper for staging or production VPS stacks.
set -euo pipefail

ENVIRONMENT="${1:-}"
if [[ -z "$ENVIRONMENT" || ( "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ) ]]; then
  echo "Usage: $0 <staging|production>" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

COMPOSE_FILE="docker-compose.${ENVIRONMENT}.yml"
ENV_FILE="${MEMY_ENV_FILE:-/etc/memy/${ENVIRONMENT}.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing compose env file: $ENV_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "$ENV_FILE"
set +a

if [[ -z "${MEMY_WWW_HOST:-}" || -z "${MEMY_API_HOST:-}" ]]; then
  echo "MEMY_WWW_HOST and MEMY_API_HOST must be set in $ENV_FILE" >&2
  exit 1
fi

WEBSITE_ROOT="${MEMY_WEBSITE_ROOT:-$ROOT/apps/www}"
if [[ ! -d "$WEBSITE_ROOT" ]]; then
  echo "Missing website root: $WEBSITE_ROOT" >&2
  echo "Clone deploy/website to /opt/memy/website and set MEMY_WEBSITE_ROOT=/opt/memy/website/apps/www" >&2
  exit 1
fi
if [[ ! -f "$WEBSITE_ROOT/index.html" ]]; then
  echo "Website root missing index.html: $WEBSITE_ROOT" >&2
  exit 1
fi
export MEMY_WEBSITE_ROOT="$WEBSITE_ROOT"

echo "Deploying MeMy ${ENVIRONMENT} (${MEMY_API_HOST})"
echo "Website root: ${MEMY_WEBSITE_ROOT}"

docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" pull api 2>/dev/null || true
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" up -d --build

"$ROOT/scripts/migrate.sh" "$ENVIRONMENT"
"$ROOT/scripts/health-check.sh" "$ENVIRONMENT"

echo "Deploy finished. Roll back with the previous MEMY_API_IMAGE tag if needed."
