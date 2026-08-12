#!/usr/bin/env bash
# Apply Prisma migrations inside the running API container.
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

docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" exec -T api \
  npx prisma migrate deploy

echo "Migrations applied for ${ENVIRONMENT}."
