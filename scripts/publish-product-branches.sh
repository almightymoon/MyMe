#!/usr/bin/env bash
# Publish generated product branches from committed main.
#
# Dry-run is the default. Push requires --push.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=lib/product-branch-common.sh
source "${ROOT}/scripts/lib/product-branch-common.sh"

DO_MOBILE=0
DO_BACKEND=0
DO_WEBSITE=0
DO_PUSH=0
DRY_RUN=1
SOURCE_REF="main"
SKIP_VALIDATE=0
WORKTREES=()

usage() {
  cat <<'EOF'
Usage: ./scripts/publish-product-branches.sh [options]

  --dry-run          Validate and build trees without committing (default)
  --commit           Create local commits on generated branches when content changes
  --push             Fast-forward push selected branches (implies --commit)
  --mobile           Publish release/mobile
  --backend          Publish deploy/backend
  --website          Publish deploy/website
  --all              Publish all three products
  --source <ref>     Source git ref (default: main)
  --skip-validate    Skip product validation commands (tests only / emergency)
  -h, --help         Show help

Dry-run is the default. Pushing requires an explicit --push.
EOF
}

cleanup() {
  local wt
  for wt in "${WORKTREES[@]:-}"; do
    if [[ -n "$wt" && -d "$wt" ]]; then
      git -C "$REPO_ROOT" worktree remove --force "$wt" >/dev/null 2>&1 || true
      rm -rf "$wt" >/dev/null 2>&1 || true
    fi
  done
}
trap cleanup EXIT

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1; shift ;;
    --commit) DRY_RUN=0; shift ;;
    --push) DO_PUSH=1; DRY_RUN=0; shift ;;
    --mobile) DO_MOBILE=1; shift ;;
    --backend) DO_BACKEND=1; shift ;;
    --website) DO_WEBSITE=1; shift ;;
    --all) DO_MOBILE=1; DO_BACKEND=1; DO_WEBSITE=1; shift ;;
    --source) SOURCE_REF="${2:-}"; shift 2 ;;
    --skip-validate) SKIP_VALIDATE=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ "$DO_MOBILE" -eq 0 && "$DO_BACKEND" -eq 0 && "$DO_WEBSITE" -eq 0 ]]; then
  # Default dry-run of all when no product selected
  DO_MOBILE=1
  DO_BACKEND=1
  DO_WEBSITE=1
fi

cd "$REPO_ROOT"
require_clean_worktree

echo "Fetching origin..."
git fetch origin --prune

SOURCE_SHA="$(git rev-parse --verify "${SOURCE_REF}^{commit}")"
echo "Source ref: ${SOURCE_REF}"
echo "Source SHA: ${SOURCE_SHA}"

# Ensure source is main lineage messaging; allow explicit SHA but warn if not main tip
MAIN_SHA="$(git rev-parse --verify main^{commit} 2>/dev/null || true)"
if [[ -n "$MAIN_SHA" && "$SOURCE_SHA" != "$MAIN_SHA" ]]; then
  echo "warning: source SHA differs from local main tip (${MAIN_SHA})" >&2
fi

GENERATED_AT="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

validate_mobile() {
  local tree="$1"
  if [[ "$SKIP_VALIDATE" -eq 1 ]]; then
    echo "skipping mobile validation"
    return 0
  fi
  (
    cd "${tree}/apps/mobile"
    flutter pub get
    dart format --output=none --set-exit-if-changed .
    flutter analyze
    flutter test
  )
}

validate_backend() {
  local tree="$1"
  if [[ "$SKIP_VALIDATE" -eq 1 ]]; then
    echo "skipping backend validation"
    return 0
  fi
  (
    cd "${tree}/apps/api"
    npm ci
    npm run format:check
    npm run lint:check
    npm test
    npx prisma validate
    npx prisma generate
    npm run build
  )
  docker build -t memy-api:branch-validation "${tree}/apps/api"

  # Compose files reference absolute VPS env_file paths. Stub them for local config validation.
  local stub
  stub="$(mktemp -d "${TMPDIR:-/tmp}/memy-compose-stubs.XXXXXX")"
  mkdir -p "${stub}/etc/memy/staging" "${stub}/etc/memy"
  for f in \
    "${stub}/etc/memy/api.env" \
    "${stub}/etc/memy/postgres.env" \
    "${stub}/etc/memy/minio.env" \
    "${stub}/etc/memy/staging/api.env" \
    "${stub}/etc/memy/staging/postgres.env" \
    "${stub}/etc/memy/staging/minio.env"
  do
    printf 'STUB=1\n' >"$f"
  done
  mkdir -p "${stub}/www"
  printf '<!doctype html><title>stub</title>\n' >"${stub}/www/index.html"

  local stg_cfg prd_cfg
  stg_cfg="$(mktemp)"
  prd_cfg="$(mktemp)"
  sed "s|/etc/memy|${stub}/etc/memy|g" "${tree}/docker-compose.staging.yml" >"$stg_cfg"
  sed "s|/etc/memy|${stub}/etc/memy|g" "${tree}/docker-compose.production.yml" >"$prd_cfg"

  MEMY_WWW_HOST=www.example.com \
  MEMY_API_HOST=api.example.com \
  MEMY_WEBSITE_ROOT="${stub}/www" \
  docker compose -f "$stg_cfg" config >/dev/null

  MEMY_WWW_HOST=www.example.com \
  MEMY_API_HOST=api.example.com \
  MEMY_WEBSITE_ROOT="${stub}/www" \
  docker compose -f "$prd_cfg" config >/dev/null

  rm -rf "$stub" "$stg_cfg" "$prd_cfg"
}

validate_website() {
  local tree="$1"
  if [[ "$SKIP_VALIDATE" -eq 1 ]]; then
    echo "skipping website validation"
    return 0
  fi
  "${ROOT}/scripts/validate-website-content.sh" "$tree"
}

assert_exclusions() {
  local tree="$1"
  local product="$2"
  case "$product" in
    mobile)
      [[ ! -e "${tree}/apps/api" ]] || { echo "mobile contains apps/api" >&2; return 1; }
      [[ ! -e "${tree}/apps/www" ]] || { echo "mobile contains apps/www" >&2; return 1; }
      [[ ! -e "${tree}/prototype" ]] || { echo "mobile contains prototype" >&2; return 1; }
      [[ ! -e "${tree}/docker-compose.production.yml" ]] || { echo "mobile contains compose" >&2; return 1; }
      ;;
    backend)
      [[ ! -e "${tree}/apps/mobile" ]] || { echo "backend contains apps/mobile" >&2; return 1; }
      [[ ! -e "${tree}/apps/www" ]] || { echo "backend contains apps/www" >&2; return 1; }
      [[ ! -e "${tree}/prototype" ]] || { echo "backend contains prototype" >&2; return 1; }
      ;;
    website)
      [[ ! -e "${tree}/apps/mobile" ]] || { echo "website contains apps/mobile" >&2; return 1; }
      [[ ! -e "${tree}/apps/api" ]] || { echo "website contains apps/api" >&2; return 1; }
      [[ ! -e "${tree}/prototype" ]] || { echo "website contains prototype" >&2; return 1; }
      [[ ! -e "${tree}/docker-compose.production.yml" ]] || { echo "website contains compose" >&2; return 1; }
      ;;
  esac
}

publish_one() {
  local product="$1"
  local branch
  local manifest
  local paths_file
  local worktree
  local tmp_extract
  local path_count
  local before_sha=""
  local after_sha=""
  local remote_sha=""

  branch="$(branch_name_for "$product")"
  manifest="$(manifest_path_for "$product")"
  echo ""
  echo "=== Publishing ${product} → ${branch} ==="

  paths_file="$(mktemp)"
  expand_manifest_paths "$SOURCE_SHA" "$manifest" >"$paths_file"
  path_count="$(wc -l <"$paths_file" | tr -d ' ')"
  if [[ "$path_count" -lt 1 ]]; then
    echo "error: no paths expanded for ${product}" >&2
    rm -f "$paths_file"
    return 1
  fi
  echo "Allowlisted committed paths: ${path_count}"

  worktree="$(mktemp -d "${TMPDIR:-/tmp}/memy-${product}.XXXXXX")"
  WORKTREES+=("$worktree")

  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    if ! git show "${branch}:.memy-generated-branch" >/dev/null 2>&1; then
      echo "error: local branch ${branch} exists but is not a generated MeMy branch; refusing to overwrite" >&2
      rm -f "$paths_file"
      return 1
    fi
    git worktree add --force "$worktree" "$branch"
    before_sha="$(git -C "$worktree" rev-parse HEAD)"
  elif git show-ref --verify --quiet "refs/remotes/origin/${branch}"; then
    if ! git show "origin/${branch}:.memy-generated-branch" >/dev/null 2>&1; then
      echo "error: remote branch origin/${branch} exists but is not a generated MeMy branch; refusing to overwrite" >&2
      rm -f "$paths_file"
      return 1
    fi
    git worktree add --force -b "$branch" "$worktree" "origin/${branch}"
    before_sha="$(git -C "$worktree" rev-parse HEAD)"
  else
    # Orphan generated branch rooted at an empty tree then first commit
    git worktree add --force --detach "$worktree" "$SOURCE_SHA"
    git -C "$worktree" checkout --orphan "$branch"
    git -C "$worktree" rm -rf . >/dev/null 2>&1 || true
    # Clear any leftover files
    find "$worktree" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
  fi

  # Remove previous snapshot contents (keep .git)
  find "$worktree" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +

  tmp_extract="$(mktemp -d "${TMPDIR:-/tmp}/memy-extract.XXXXXX")"
  # Extract only allowlisted paths from the committed source tree (Bash 3.2-safe).
  ARCHIVE_PATHS=()
  while IFS= read -r _archive_path; do
    [[ -n "$_archive_path" ]] && ARCHIVE_PATHS+=("$_archive_path")
  done <"$paths_file"
  git -C "$REPO_ROOT" archive "$SOURCE_SHA" "${ARCHIVE_PATHS[@]}" | tar -x -C "$tmp_extract"
  # Preserve modes by copying into worktree
  cp -a "${tmp_extract}/." "$worktree/"
  rm -rf "$tmp_extract"
  rm -f "$paths_file"

  write_generated_markers "$worktree" "$branch" "$SOURCE_SHA" "$GENERATED_AT"
  write_product_readme "$worktree" "$product" "$branch" "$SOURCE_SHA" "$GENERATED_AT"

  # Also keep branch-manifests entry for auditability (from committed source)
  mkdir -p "${worktree}/branch-manifests"
  git -C "$REPO_ROOT" show "${SOURCE_SHA}:branch-manifests/${product}.txt" \
    >"${worktree}/branch-manifests/${product}.txt"

  assert_exclusions "$worktree" "$product"
  "${ROOT}/scripts/scan-generated-secrets.sh" "$worktree" "$branch"

  case "$product" in
    mobile) validate_mobile "$worktree" ;;
    backend) validate_backend "$worktree" ;;
    website) validate_website "$worktree" ;;
  esac

  git -C "$worktree" add -A
  if [[ -n "$before_sha" ]]; then
    local new_tree old_tree prev_at
    prev_at="$(git -C "$worktree" show "${before_sha}:.memy-generated-at" 2>/dev/null || true)"
    # Normalize timestamp churn in README + marker for meaningful-change detection.
    write_product_readme "$worktree" "$product" "$branch" "$SOURCE_SHA" "${prev_at:-$GENERATED_AT}"
    if [[ -f "${worktree}/.memy-generated-at" ]]; then
      git -C "$worktree" update-index --force-remove .memy-generated-at 2>/dev/null || true
      rm -f "${worktree}/.memy-generated-at"
    fi
    git -C "$worktree" add -A
    new_tree="$(git -C "$worktree" write-tree)"
    # Previous tree without .memy-generated-at
    old_tree="$(git -C "$worktree" rev-parse "${before_sha}^{tree}")"
    if git -C "$worktree" cat-file -e "${before_sha}:.memy-generated-at" 2>/dev/null; then
      # Rebuild previous tree minus generated-at for fair compare
      local tmp_index
      tmp_index="$(mktemp)"
      GIT_INDEX_FILE="$tmp_index" git -C "$worktree" read-tree "$before_sha"
      GIT_INDEX_FILE="$tmp_index" git -C "$worktree" update-index --force-remove .memy-generated-at 2>/dev/null || true
      old_tree="$(GIT_INDEX_FILE="$tmp_index" git -C "$worktree" write-tree)"
      rm -f "$tmp_index"
    fi

    # Restore current generated metadata
    write_product_readme "$worktree" "$product" "$branch" "$SOURCE_SHA" "$GENERATED_AT"
    printf '%s\n' "$GENERATED_AT" >"${worktree}/.memy-generated-at"
    git -C "$worktree" add -A

    if [[ "$new_tree" == "$old_tree" ]]; then
      echo "No meaningful content change for ${branch}; skipping commit."
      after_sha="$before_sha"
      echo "Local ${branch}: ${after_sha}"
      if [[ "$DO_PUSH" -eq 1 ]]; then
        if ! git -C "$worktree" push origin "HEAD:refs/heads/${branch}"; then
          echo "error: push failed for ${branch}" >&2
          return 1
        fi
        remote_sha="$(git ls-remote --heads origin "$branch" | awk '{print $1}')"
        echo "Remote ${branch}: ${remote_sha}"
      fi
      return 0
    fi
  fi

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY-RUN: would commit and update ${branch} from ${SOURCE_SHA}"
    echo "DRY-RUN path sample:"
    git -C "$worktree" ls-files | head -20
    return 0
  fi

  local msg
  case "$product" in
    mobile) msg="chore(release): publish mobile snapshot from ${SOURCE_SHA}" ;;
    backend) msg="chore(deploy): publish backend snapshot from ${SOURCE_SHA}" ;;
    website) msg="chore(deploy): publish website snapshot from ${SOURCE_SHA}" ;;
  esac

  git -C "$worktree" -c user.email="memy-bot@users.noreply.github.com" -c user.name="MeMy Branch Publisher" commit -m "$msg"
  after_sha="$(git -C "$worktree" rev-parse HEAD)"
  echo "Local ${branch}: ${after_sha}"

  if [[ "$DO_PUSH" -eq 1 ]]; then
    # Enforce fast-forward without relying on git push --ff-only (portability).
    if git ls-remote --heads origin "$branch" | grep -q .; then
      remote_sha="$(git ls-remote --heads origin "$branch" | awk '{print $1}')"
      if ! git -C "$worktree" merge-base --is-ancestor "$remote_sha" "$after_sha"; then
        echo "error: push failed for ${branch} (non-fast-forward)" >&2
        return 1
      fi
    fi
    if ! git -C "$worktree" push origin "HEAD:refs/heads/${branch}"; then
      echo "error: push failed for ${branch}" >&2
      return 1
    fi
    remote_sha="$(git ls-remote --heads origin "$branch" | awk '{print $1}')"
    echo "Remote ${branch}: ${remote_sha}"
    if [[ -z "$remote_sha" || "$remote_sha" != "$after_sha" ]]; then
      echo "error: remote SHA mismatch for ${branch}" >&2
      return 1
    fi
  fi
}

publish_one_safe() {
  local product="$1"
  publish_one "$product"
}

[[ "$DO_MOBILE" -eq 1 ]] && publish_one_safe mobile
[[ "$DO_BACKEND" -eq 1 ]] && publish_one_safe backend
[[ "$DO_WEBSITE" -eq 1 ]] && publish_one_safe website

echo ""
echo "Done. main remains unchanged."
git -C "$REPO_ROOT" rev-parse main
git -C "$REPO_ROOT" status --short
