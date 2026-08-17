#!/usr/bin/env bash
# Deploy MeMy on a shared Apache VPS (same pattern as MyShelf lab deploy).
# Pulls generated product branches, rebuilds API behind 127.0.0.1:4020,
# refreshes only memy* Apache vhosts. Never edits forex/portfolio/lab configs.
set -euo pipefail

WEBSITE_ONLY=0
API_ONLY=0
BACKEND_ROOT="${MEMY_BACKEND_ROOT:-/opt/memy/backend}"
WEBSITE_ROOT_CLONE="${MEMY_WEBSITE_CLONE:-/opt/memy/website}"
ENV_FILE="${MEMY_ENV_FILE:-/etc/memy/production.env}"
APACHE_OVERRIDE="${MEMY_APACHE_COMPOSE:-/etc/memy/docker-compose.apache.yml}"

usage() {
  cat <<'EOF'
Usage: ./scripts/vps-apache-deploy.sh [--website-only] [--api-only]

  --website-only  Pull website only; skip Docker rebuild
  --api-only      Pull backend + rebuild API; skip website pull
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --website-only) WEBSITE_ONLY=1; shift ;;
    --api-only) API_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing compose env file: $ENV_FILE" >&2
  exit 1
fi

# shellcheck disable=SC1090
set -a
source "$ENV_FILE"
set +a

pull_branch() {
  local dir="$1"
  local branch="$2"
  if [[ ! -d "$dir/.git" ]]; then
    echo "Missing git clone: $dir" >&2
    exit 1
  fi
  echo "==> Pulling $branch in $dir"
  git -C "$dir" fetch origin "$branch"
  git -C "$dir" checkout "$branch"
  git -C "$dir" reset --hard "origin/$branch"
  echo "    HEAD $(git -C "$dir" rev-parse --short HEAD)"
}

sync_apache_override() {
  local src="$BACKEND_ROOT/deploy/apache/docker-compose.apache.yml"
  if [[ -f "$src" ]]; then
    install -m 0644 "$src" "$APACHE_OVERRIDE"
  elif [[ ! -f "$APACHE_OVERRIDE" ]]; then
    echo "Missing Apache compose override: $APACHE_OVERRIDE" >&2
    exit 1
  fi
}

sync_apache_vhosts() {
  local src_dir="$BACKEND_ROOT/deploy/apache"
  if [[ ! -d "$src_dir" ]]; then
    echo "No deploy/apache in backend clone; skipping Apache file sync"
    return 0
  fi

  echo "==> Syncing MeMy Apache vhosts only"
  a2enmod proxy proxy_http rewrite headers ssl >/dev/null 2>&1 || true

  for conf in memy.conf memy-api.conf; do
    if [[ -f "$src_dir/$conf" ]]; then
      cp "$src_dir/$conf" "/etc/apache2/sites-available/$conf"
      a2ensite "$conf" >/dev/null
    fi
  done

  if [[ -f /etc/letsencrypt/live/memy.athariqbal.com/fullchain.pem && -f "$src_dir/memy-le-ssl.conf" ]]; then
    cp "$src_dir/memy-le-ssl.conf" /etc/apache2/sites-available/memy-le-ssl.conf
    a2ensite memy-le-ssl.conf >/dev/null
  fi
  if [[ -f /etc/letsencrypt/live/api.memy.athariqbal.com/fullchain.pem && -f "$src_dir/memy-api-le-ssl.conf" ]]; then
    cp "$src_dir/memy-api-le-ssl.conf" /etc/apache2/sites-available/memy-api-le-ssl.conf
    a2ensite memy-api-le-ssl.conf >/dev/null
  fi

  apache2ctl configtest
  systemctl reload apache2
}

wait_api_health() {
  local ok=0
  local i
  for i in $(seq 1 40); do
    if curl -fsS --connect-timeout 2 --max-time 5 http://127.0.0.1:4020/api/v1/health/live >/dev/null 2>&1; then
      ok=1
      break
    fi
    echo "API not ready yet (attempt $i/40)..."
    sleep 3
  done
  if [[ "$ok" -ne 1 ]]; then
    echo "API health check failed" >&2
    docker compose \
      --project-directory "$BACKEND_ROOT" \
      --env-file "$ENV_FILE" \
      -f "$BACKEND_ROOT/docker-compose.production.yml" \
      -f "$APACHE_OVERRIDE" \
      logs --tail=80 api || true
    exit 1
  fi
}

if [[ "$API_ONLY" -eq 0 ]]; then
  pull_branch "$WEBSITE_ROOT_CLONE" deploy/website
fi

if [[ "$WEBSITE_ONLY" -eq 1 ]]; then
  sync_apache_vhosts
  curl -fsS -H 'Host: memy.athariqbal.com' http://127.0.0.1/ >/dev/null
  echo "==> Website deploy finished"
  exit 0
fi

pull_branch "$BACKEND_ROOT" deploy/backend
sync_apache_override
chmod +x "$BACKEND_ROOT/scripts/"*.sh 2>/dev/null || true

echo "==> Docker stack (API 127.0.0.1:4020; Caddy disabled)"
cd "$BACKEND_ROOT"
docker compose \
  --project-directory "$BACKEND_ROOT" \
  --env-file "$ENV_FILE" \
  -f "$BACKEND_ROOT/docker-compose.production.yml" \
  -f "$APACHE_OVERRIDE" \
  up -d --build

# Ensure Caddy never binds 80/443 on this shared host
docker rm -f memy-production-caddy-1 2>/dev/null || true

echo "==> Migrations"
docker compose \
  --project-directory "$BACKEND_ROOT" \
  --env-file "$ENV_FILE" \
  -f "$BACKEND_ROOT/docker-compose.production.yml" \
  -f "$APACHE_OVERRIDE" \
  run --rm --no-deps --entrypoint npx api prisma migrate deploy

wait_api_health
sync_apache_vhosts

echo "==> Health"
curl -fsS http://127.0.0.1:4020/api/v1/health; echo
curl -fsS -H 'Host: memy.athariqbal.com' http://127.0.0.1/api/v1/health; echo
curl -fsS -H 'Host: api.memy.athariqbal.com' http://127.0.0.1/api/v1/health; echo

echo "==> Public: https://memy.athariqbal.com  https://api.memy.athariqbal.com"
echo "Deploy finished."
