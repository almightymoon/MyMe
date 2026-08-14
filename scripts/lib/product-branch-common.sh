#!/usr/bin/env bash
# Shared helpers for product-branch publication.
# shellcheck shell=bash

set -euo pipefail

PRODUCT_BRANCH_COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${PRODUCT_BRANCH_COMMON_DIR}/../.." && pwd)"

PRODUCT_BRANCH_MOBILE="release/mobile"
PRODUCT_BRANCH_BACKEND="deploy/backend"
PRODUCT_BRANCH_WEBSITE="deploy/website"

manifest_path_for() {
  local product="$1"
  echo "${REPO_ROOT}/branch-manifests/${product}.txt"
}

branch_name_for() {
  local product="$1"
  case "$product" in
    mobile) echo "$PRODUCT_BRANCH_MOBILE" ;;
    backend) echo "$PRODUCT_BRANCH_BACKEND" ;;
    website) echo "$PRODUCT_BRANCH_WEBSITE" ;;
    *)
      echo "Unknown product: $product" >&2
      return 1
      ;;
  esac
}

require_clean_worktree() {
  if [[ -n "$(git -C "$REPO_ROOT" status --porcelain)" ]]; then
    echo "error: working tree is dirty; commit or stash before publishing" >&2
    git -C "$REPO_ROOT" status --short >&2
    return 1
  fi
}

read_manifest_entries() {
  local manifest="$1"
  if [[ ! -f "$manifest" ]]; then
    echo "error: missing manifest: $manifest" >&2
    return 1
  fi
  # Strip comments/blank lines
  sed -e 's/#.*$//' -e 's/[[:space:]]*$//' -e '/^$/d' "$manifest"
}

# Expand allowlist entries against committed tree at SOURCE_SHA.
# Prints one repository-relative path per line.
expand_manifest_paths() {
  local source_sha="$1"
  local manifest="$2"
  local entry
  local matched
  local all_paths
  all_paths="$(git -C "$REPO_ROOT" ls-tree -r --name-only "$source_sha")"

  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    if [[ "$entry" == *".."* || "$entry" == /* ]]; then
      echo "error: invalid manifest path (traversal or absolute): $entry" >&2
      return 1
    fi

    matched="$(printf '%s\n' "$all_paths" | awk -v e="$entry" '
      BEGIN { found=0 }
      {
        if (e ~ /\/$/) {
          prefix=e
          if (index($0, prefix) == 1) { print; found=1 }
        } else if ($0 == e) {
          print
          found=1
        } else if (index($0, e "/") == 1) {
          print
          found=1
        }
      }
      END { if (!found) exit 2 }
    ')" || {
      echo "error: allowlisted path missing from source tree ${source_sha}: ${entry}" >&2
      return 1
    }
    printf '%s\n' "$matched"
  done < <(read_manifest_entries "$manifest") | awk 'NF' | sort -u
}

write_generated_markers() {
  local dest="$1"
  local branch="$2"
  local source_sha="$3"
  local generated_at="${4:-}"

  cat >"${dest}/.memy-generated-branch" <<EOF
generated=true
branch=${branch}
source_branch=main
do_not_edit=true
EOF
  printf '%s\n' "$source_sha" >"${dest}/.memy-source-commit"
  if [[ -n "$generated_at" ]]; then
    printf '%s\n' "$generated_at" >"${dest}/.memy-generated-at"
  fi
}

write_product_readme() {
  local dest="$1"
  local product="$2"
  local branch="$3"
  local source_sha="$4"
  local generated_at="$5"
  local file="${dest}/README.md"

  {
    cat <<EOF
This branch is generated from main.

Do not develop or manually commit product changes here.

Make changes on main and publish a new snapshot.

---

# MeMy ${product} snapshot

| Field | Value |
| --- | --- |
| Source branch | \`main\` |
| Source commit | \`${source_sha}\` |
| Generated (UTC) | ${generated_at} |
| Branch | \`${branch}\` |

EOF

    case "$product" in
      mobile)
        cat <<'EOF'
## Flutter setup

```bash
cd apps/mobile
flutter pub get
```

### Android

```bash
cd apps/mobile
flutter run -d android
flutter build appbundle --release \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=account \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

### iOS

```bash
cd apps/mobile
flutter run -d ios
flutter build ipa --release \
  --dart-define=APP_ENV=production \
  --dart-define=AUTH_MODE=account \
  --dart-define=API_BASE_URL=https://api.example.com/api/v1
```

### API configuration

- Staging: pass `--dart-define=API_BASE_URL=https://<staging-api-host>/api/v1`
- Production: pass `--dart-define=API_BASE_URL=https://<api-host>/api/v1`

### OAuth client IDs

Configure **public** Google / Apple client IDs via dart-defines or platform config.
**No backend secret belongs in the mobile application** (no JWT keys, no DB passwords,
no MinIO credentials, no Apple private keys).
EOF
        ;;
      backend)
        cat <<'EOF'
## VPS requirements

- Docker + Docker Compose
- Host env files under `/etc/memy/` (see `deploy/env/`)
- Separate website clone at `/opt/memy/website` (do not put website source here)

## Required environment files

See `deploy/env/README.md`. Never commit filled copies.

## Staging

```bash
./scripts/deploy.sh staging
```

## Production

```bash
./scripts/deploy.sh production
```

## Database migrations

```bash
./scripts/migrate.sh staging
./scripts/migrate.sh production
```

## MinIO

Initialize buckets/credentials via the MinIO env files on the VPS.
Do not expose MinIO ports publicly.

## Backup / restore

```bash
./scripts/backup.sh production
./scripts/backup-staging.sh
```

## Health verification

```bash
./scripts/health-check.sh staging
./scripts/health-check.sh production
```

## Website clone integration

Set `MEMY_WEBSITE_ROOT` to the public site directory from the website clone, for example:

```bash
export MEMY_WEBSITE_ROOT=/opt/memy/website/apps/www
```

Compose mounts that path read-only into Caddy as `/srv/www`.
EOF
        ;;
      website)
        cat <<'EOF'
## Public website

Static files under `apps/www/`:

- Landing page (`index.html`)
- Privacy, Terms, Support
- Health and Financial disclaimer pages when present
- Assets under `apps/www/assets/`

## Local preview

```bash
cd apps/www
python3 -m http.server 8765
```

## VPS

Clone this branch to `/opt/memy/website` and point backend Compose at:

```bash
MEMY_WEBSITE_ROOT=/opt/memy/website/apps/www
```

Do not publish the interactive prototype (`prototype/web`) from this branch.
EOF
        ;;
    esac
  } >"$file"
}
