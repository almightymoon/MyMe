#!/usr/bin/env bash
# PostgreSQL dump + optional MinIO mirror. Secrets come from the environment.
set -euo pipefail

ENVIRONMENT="${1:-staging}"
if [[ "$ENVIRONMENT" != "staging" && "$ENVIRONMENT" != "production" ]]; then
  echo "Usage: $0 [staging|production]" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

COMPOSE_FILE="docker-compose.${ENVIRONMENT}.yml"
ENV_FILE="${MEMY_ENV_FILE:-/etc/memy/${ENVIRONMENT}.env}"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
DEST="${BACKUP_PATH:-/var/backups/memy-${ENVIRONMENT}}/$STAMP"
mkdir -p "$DEST"

docker compose -f "$COMPOSE_FILE" --env-file "$ENV_FILE" exec -T postgres \
  sh -c 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' \
  | gzip > "$DEST/postgres.sql.gz"

if command -v mc >/dev/null 2>&1; then
  mc mirror "local/${OBJECT_STORAGE_BUCKET:-memy-private}" "$DEST/minio" || true
fi

echo "Backup written under $DEST"
