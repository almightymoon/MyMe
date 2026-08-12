#!/usr/bin/env bash
# Verify API readiness from inside the container and over HTTPS when configured.
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

echo "Checking in-container health..."
docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" exec -T api \
  wget -qO- http://127.0.0.1:3000/api/v1/health

if [[ -f "$ENV_FILE" ]]; then
  API_HOST="$(grep -E '^MEMY_API_HOST=' "$ENV_FILE" | head -n1 | cut -d= -f2- | tr -d '"' | tr -d "'")"
  if [[ -n "${API_HOST:-}" && "$API_HOST" != *example.com* ]]; then
    echo "Checking public HTTPS health for ${API_HOST}..."
    curl -fsS "https://${API_HOST}/api/v1/health"
    echo
  else
    echo "Skipping public HTTPS check (hostname still placeholder or unset)."
  fi
fi

echo "Health check passed for ${ENVIRONMENT}."
