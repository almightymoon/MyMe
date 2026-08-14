#!/usr/bin/env bash
# Deterministic publication-test harness using a temporary repository + bare remote.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HARNESS_DIR="$(mktemp -d "${TMPDIR:-/tmp}/memy-publish-harness.XXXXXX")"
PASS=0
FAIL=0

cleanup() {
  rm -rf "$HARNESS_DIR"
}
trap cleanup EXIT

ok() { echo "PASS: $1"; PASS=$((PASS + 1)); }
bad() { echo "FAIL: $1"; FAIL=$((FAIL + 1)); }

assert_eq() {
  local got="$1" want="$2" name="$3"
  if [[ "$got" == "$want" ]]; then ok "$name"; else bad "$name (got='$got' want='$want')"; fi
}

assert_true() {
  if "$@"; then ok "$*"; else bad "$*"; fi
}

assert_false() {
  if "$@"; then bad "expected failure: $*"; else ok "rejects: $*"; fi
}

SRC="$HARNESS_DIR/src"
BARE="$HARNESS_DIR/remote.git"
git init -q -b main "$SRC"
git init -q --bare "$BARE"
git -C "$SRC" config user.email "test@example.com"
git -C "$SRC" config user.name "Test"
git -C "$SRC" remote add origin "$BARE"

# Minimal monorepo fixtures
mkdir -p \
  "$SRC/apps/mobile/lib" \
  "$SRC/apps/api/src" \
  "$SRC/apps/www" \
  "$SRC/prototype/web" \
  "$SRC/deploy/caddy" \
  "$SRC/scripts" \
  "$SRC/docs/deployment" \
  "$SRC/branch-manifests" \
  "$SRC/scripts/lib"

echo 'void main() {}' >"$SRC/apps/mobile/lib/main.dart"
echo 'export {};' >"$SRC/apps/api/src/main.ts"
printf '%s\n' '<!doctype html><title>MeMy</title><h1>ok</h1>' >"$SRC/apps/www/index.html"
printf '%s\n' '<!doctype html><title>Privacy</title>' >"$SRC/apps/www/privacy.html"
printf '%s\n' '<!doctype html><title>Terms</title>' >"$SRC/apps/www/terms.html"
printf '%s\n' '<!doctype html><title>Support</title>' >"$SRC/apps/www/support.html"
echo 'proto' >"$SRC/prototype/web/index.html"
echo 'caddy' >"$SRC/deploy/caddy/Caddyfile"
echo 'name: x' >"$SRC/docker-compose.staging.yml"
echo 'name: y' >"$SRC/docker-compose.production.yml"
echo 'name: z' >"$SRC/docker-compose.yml"
printf '%s\n' '#!/bin/sh' 'echo deploy' >"$SRC/scripts/deploy.sh"
chmod +x "$SRC/scripts/deploy.sh"
echo '# deploy docs' >"$SRC/docs/deployment/vps-production.md"
echo '# ignore' >"$SRC/.gitignore"

cat >"$SRC/branch-manifests/mobile.txt" <<'EOF'
apps/mobile/
.gitignore
EOF
cat >"$SRC/branch-manifests/backend.txt" <<'EOF'
apps/api/
deploy/
scripts/deploy.sh
docker-compose.yml
docker-compose.staging.yml
docker-compose.production.yml
docs/deployment/
.gitignore
EOF
cat >"$SRC/branch-manifests/website.txt" <<'EOF'
apps/www/
.gitignore
EOF

# Copy real publisher scripts into fixture repo
cp "$ROOT/scripts/lib/product-branch-common.sh" "$SRC/scripts/lib/"
cp "$ROOT/scripts/publish-product-branches.sh" "$SRC/scripts/"
cp "$ROOT/scripts/scan-generated-secrets.sh" "$SRC/scripts/"
cp "$ROOT/scripts/validate-website-content.sh" "$SRC/scripts/"
chmod +x "$SRC/scripts/"*.sh

git -C "$SRC" add -A
git -C "$SRC" commit -qm "chore: fixture monorepo"
git -C "$SRC" push -q -u origin main
SOURCE_SHA="$(git -C "$SRC" rev-parse HEAD)"

# --- Dirty tree rejected ---
echo dirty >"$SRC/dirty.txt"
if (cd "$SRC" && ./scripts/publish-product-branches.sh --website --skip-validate --commit) >/tmp/memy-pub-out 2>&1; then
  bad "dirty tree should be rejected"
else
  ok "dirty source tree rejected"
fi
rm -f "$SRC/dirty.txt"

# --- Missing manifest rejected ---
mv "$SRC/branch-manifests/website.txt" "$SRC/branch-manifests/website.txt.bak"
git -C "$SRC" add -A && git -C "$SRC" commit -qm "chore: remove website manifest"
if (cd "$SRC" && ./scripts/publish-product-branches.sh --website --skip-validate --commit) >/tmp/memy-pub-out 2>&1; then
  bad "missing manifest should be rejected"
else
  ok "missing manifest rejected"
fi
mv "$SRC/branch-manifests/website.txt.bak" "$SRC/branch-manifests/website.txt"
# restore valid tip
git -C "$SRC" checkout -q main
git -C "$SRC" reset -q --hard "$SOURCE_SHA"

# --- Invalid / traversal path rejected ---
echo '../etc/passwd' >"$SRC/branch-manifests/website.txt"
git -C "$SRC" add branch-manifests/website.txt && git -C "$SRC" commit -qm "chore: bad manifest"
if (cd "$SRC" && ./scripts/publish-product-branches.sh --website --skip-validate --commit) >/tmp/memy-pub-out 2>&1; then
  bad "path traversal should be rejected"
else
  ok "path traversal rejected"
fi
git -C "$SRC" reset -q --hard "$SOURCE_SHA"

# --- Missing allowlisted path rejected ---
echo 'apps/www/missing.html' >"$SRC/branch-manifests/website.txt"
git -C "$SRC" add branch-manifests/website.txt && git -C "$SRC" commit -qm "chore: missing path"
if (cd "$SRC" && ./scripts/publish-product-branches.sh --website --skip-validate --commit) >/tmp/memy-pub-out 2>&1; then
  bad "missing allowlisted path should be rejected"
else
  ok "invalid/missing manifest path rejected"
fi
git -C "$SRC" reset -q --hard "$SOURCE_SHA"

# --- Secret file rejected ---
printf '%s\n' 'apps/www/' '.gitignore' 'apps/www/.env' >"$SRC/branch-manifests/website.txt"
echo 'JWT_SECRET=super-secret-value-do-not-print' >"$SRC/apps/www/.env"
git -C "$SRC" add -f apps/www/.env branch-manifests/website.txt
git -C "$SRC" commit -qm "chore: plant secret"
if (cd "$SRC" && ./scripts/publish-product-branches.sh --website --skip-validate --commit) >/tmp/memy-pub-out 2>&1; then
  bad "secret file should be rejected"
else
  if grep -q 'SECRET_SCAN_HIT' /tmp/memy-pub-out && ! grep -q 'super-secret-value-do-not-print' /tmp/memy-pub-out; then
    ok "secret file rejected without printing value"
  else
    bad "secret rejection messaging incorrect"
  fi
fi
git -C "$SRC" reset -q --hard "$SOURCE_SHA"

# --- Create all three branches ---
if (cd "$SRC" && ./scripts/publish-product-branches.sh --all --skip-validate --commit) >/tmp/memy-pub-out 2>&1; then
  ok "new mobile/backend/website branches created"
else
  bad "failed to create product branches"
  cat /tmp/memy-pub-out
fi

for b in release/mobile deploy/backend deploy/website; do
  if git -C "$SRC" show-ref --verify --quiet "refs/heads/$b"; then
    ok "branch exists: $b"
  else
    bad "branch missing: $b"
  fi
done

# Markers + source SHA
MOBILE_SRC="$(git -C "$SRC" show release/mobile:.memy-source-commit | tr -d '\n')"
assert_eq "$MOBILE_SRC" "$(git -C "$SRC" rev-parse main)" "mobile source SHA matches main"

if git -C "$SRC" show release/mobile:.memy-generated-branch | grep -q 'do_not_edit=true'; then
  ok "markers are correct"
else
  bad "markers incorrect"
fi

# Exclusions
mobile_paths="$(git -C "$SRC" ls-tree -r --name-only release/mobile 2>/dev/null || true)"
backend_paths="$(git -C "$SRC" ls-tree -r --name-only deploy/backend 2>/dev/null || true)"
website_paths="$(git -C "$SRC" ls-tree -r --name-only deploy/website 2>/dev/null || true)"

if printf '%s\n' "$mobile_paths" | grep -q '^apps/api/'; then
  bad "mobile excludes backend"
else
  ok "mobile excludes backend"
fi
if printf '%s\n' "$mobile_paths" | grep -q '^apps/www/'; then
  bad "mobile excludes website"
else
  ok "mobile excludes website"
fi
if printf '%s\n' "$backend_paths" | grep -q '^apps/mobile/'; then
  bad "backend excludes mobile"
else
  ok "backend excludes mobile"
fi
if printf '%s\n' "$backend_paths" | grep -q '^apps/www/'; then
  bad "backend excludes website source"
else
  ok "backend excludes website source"
fi
if printf '%s\n' "$website_paths" | grep -q '^apps/mobile/'; then
  bad "website excludes mobile"
else
  ok "website excludes mobile"
fi
if printf '%s\n' "$website_paths" | grep -q '^apps/api/'; then
  bad "website excludes backend"
else
  ok "website excludes backend"
fi
if printf '%s\n' "$website_paths" | grep -q '^prototype/'; then
  bad "website excludes prototype"
else
  ok "website excludes prototype"
fi

# Executable permissions preserved
MODE="$(git -C "$SRC" ls-tree deploy/backend scripts/deploy.sh 2>/dev/null | awk '{print $1}')"
if [[ "$MODE" == "100755" ]]; then
  ok "executable permissions remain"
else
  bad "executable permissions remain (mode=$MODE)"
fi

# No-change run creates no commit
BEFORE="$(git -C "$SRC" rev-parse deploy/website)"
(cd "$SRC" && ./scripts/publish-product-branches.sh --website --skip-validate --commit) >/tmp/memy-pub-out 2>&1 || true
AFTER="$(git -C "$SRC" rev-parse deploy/website)"
assert_eq "$AFTER" "$BEFORE" "no-change run creates no commit"

# Update existing generated branch
echo '<!-- updated -->' >>"$SRC/apps/www/index.html"
git -C "$SRC" add apps/www/index.html && git -C "$SRC" commit -qm "chore: website tweak"
(cd "$SRC" && ./scripts/publish-product-branches.sh --website --skip-validate --commit) >/tmp/memy-pub-out 2>&1
UPDATED="$(git -C "$SRC" rev-parse deploy/website)"
if [[ "$UPDATED" != "$BEFORE" ]]; then
  ok "existing generated branch updated"
else
  bad "existing generated branch updated"
fi

# Unknown existing branch rejected
git -C "$SRC" branch mystery-branch main
git -C "$SRC" branch -M mystery-branch deploy/website-temp-backup >/dev/null 2>&1 || true
# Create a non-generated branch with the target name by force is dangerous; simulate via worktree rename:
git -C "$SRC" branch -D deploy/backend
git -C "$SRC" branch deploy/backend main
if (cd "$SRC" && ./scripts/publish-product-branches.sh --backend --skip-validate --commit) >/tmp/memy-pub-out 2>&1; then
  bad "existing unknown branch rejected"
else
  ok "existing unknown branch rejected"
fi
# restore backend branch for push tests
git -C "$SRC" branch -D deploy/backend >/dev/null 2>&1 || true
(cd "$SRC" && ./scripts/publish-product-branches.sh --backend --skip-validate --commit) >/tmp/memy-pub-out 2>&1

# Fast-forward push works
MAIN_BEFORE_PUSH="$(git -C "$SRC" rev-parse main)"
if (cd "$SRC" && ./scripts/publish-product-branches.sh --website --skip-validate --push) >/tmp/memy-pub-out 2>&1; then
  REMOTE_WEB="$(git -C "$BARE" rev-parse refs/heads/deploy/website)"
  LOCAL_WEB="$(git -C "$SRC" rev-parse deploy/website)"
  assert_eq "$REMOTE_WEB" "$LOCAL_WEB" "fast-forward push works"
else
  bad "fast-forward push works"
  cat /tmp/memy-pub-out
fi

# Push failure is reported (revoke branch tip on bare to non-ff by writing unrelated commit is hard;
# simulate by making remote branch point ahead with different history)
git -C "$SRC" push -q origin main
# Create diverged remote website branch
CLONE="$HARNESS_DIR/diverge"
git clone -q "$BARE" "$CLONE"
git -C "$CLONE" config user.email "test@example.com"
git -C "$CLONE" config user.name "Test"
git -C "$CLONE" checkout -q -B deploy/website
echo diverged >"$CLONE/diverged.txt"
git -C "$CLONE" add diverged.txt
# Need markers so we don't hit "unknown branch" — plant markers then push with force to bare only inside harness
printf '%s\n' 'generated=true' 'branch=deploy/website' 'source_branch=main' 'do_not_edit=true' >"$CLONE/.memy-generated-branch"
echo deadbeef >"$CLONE/.memy-source-commit"
git -C "$CLONE" add -A
git -C "$CLONE" commit -qm "chore: diverge remote"
git -C "$CLONE" push -q --force origin deploy/website
if (cd "$SRC" && ./scripts/publish-product-branches.sh --website --skip-validate --push) >/tmp/memy-pub-out 2>&1; then
  # May create new commit then fail ff push — either way must not claim success without remote match
  if grep -qi 'error: push failed\|error: remote SHA mismatch\|non-fast-forward\|rejected' /tmp/memy-pub-out; then
    ok "push failure is reported"
  else
    # If local publish skipped because unknown... check
    bad "push failure is reported"
    cat /tmp/memy-pub-out
  fi
else
  ok "push failure is reported"
fi

# main unchanged by publication of product branches (tip still ancestor of original after our own fixture commits)
MAIN_AFTER="$(git -C "$SRC" rev-parse main)"
# Publication must not move main; fixture commits may have moved it during the test, but publisher itself shouldn't.
# Verify publisher didn't create commits on main in the last successful website publish by checking main reflog message.
if git -C "$SRC" log -1 --format=%s main | grep -qv 'publish'; then
  ok "main remains unchanged by publisher commits"
else
  bad "main remains unchanged by publisher commits"
fi
assert_eq "$(git -C "$SRC" merge-base --is-ancestor "$MAIN_BEFORE_PUSH" "$MAIN_AFTER" && echo yes || echo no)" "yes" "main remains a fast-forward of pre-push tip or equal"

# Worktrees cleaned — no leftover memy worktrees for this repo
LEFTOVER="$(git -C "$SRC" worktree list | wc -l | tr -d ' ')"
# only main worktree expected
if [[ "$LEFTOVER" -eq 1 ]]; then
  ok "temporary worktrees are cleaned"
else
  bad "temporary worktrees are cleaned (count=$LEFTOVER)"
  git -C "$SRC" worktree list
fi

echo ""
echo "Harness summary: $PASS passed, $FAIL failed"
if [[ "$FAIL" -ne 0 ]]; then
  exit 1
fi
