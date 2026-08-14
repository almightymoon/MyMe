#!/usr/bin/env bash
# Lightweight secret scan for a generated product-branch tree.
# Prints branch, path, and category only — never secret values.
set -euo pipefail

ROOT="${1:-}"
BRANCH_LABEL="${2:-unknown}"

if [[ -z "$ROOT" || ! -d "$ROOT" ]]; then
  echo "Usage: $0 <tree-root> [branch-label]" >&2
  exit 2
fi

FOUND=0

report() {
  local path="$1"
  local category="$2"
  echo "SECRET_SCAN_HIT branch=${BRANCH_LABEL} path=${path} category=${category}"
  FOUND=1
}

# Filename-based detections (relative paths)
while IFS= read -r -d '' file; do
  rel="${file#"$ROOT"/}"
  base="$(basename "$file")"
  case "$base" in
    .env|.env.*|*.pem|*.p12|*.pfx|*.jks|*.keystore|*.mobileprovision|id_rsa|id_rsa.*|id_ed25519|id_ed25519.*)
      # Allow committed example templates only
      if [[ "$base" == *.example || "$base" == *.example.* ]]; then
        continue
      fi
      if [[ "$base" == .env.example || "$base" == .env.test.example || "$base" == .env.production.example ]]; then
        continue
      fi
      report "$rel" "sensitive-filename"
      ;;
  esac
  case "$rel" in
    */credentials.json|*/service-account*.json|**/google-services.json)
      # google-services.json can be public client config; still flag for review if present with private keys below
      ;;
  esac
done < <(find "$ROOT" -type f -print0)

# Content-based detections — print path/category only
scan_content() {
  local file="$1"
  local rel="${file#"$ROOT"/}"
  # Skip binaries via file heuristic
  if ! grep -Iq . "$file" 2>/dev/null; then
    return 0
  fi
  if grep -Eq -- 'BEGIN (RSA |OPENSSH |EC |DSA )?PRIVATE KEY' "$file"; then
    report "$rel" "private-key-pem"
  fi
  if grep -Eq -- '-----BEGIN PRIVATE KEY-----' "$file"; then
    report "$rel" "private-key-pkcs8"
  fi
  if grep -Eqi -- 'AKIA[0-9A-Z]{16}' "$file"; then
    report "$rel" "aws-access-key-id"
  fi
  if grep -Eqi -- 'ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{20,}' "$file"; then
    report "$rel" "github-token"
  fi
  if grep -Eqi -- '-----BEGIN CERTIFICATE-----' "$file" && [[ "$rel" == *apple* || "$rel" == *.p8 ]]; then
    report "$rel" "apple-related-cert"
  fi
  # Password-bearing database URLs (not placeholder examples)
  if grep -Eqi -- 'postgres(ql)?://[^:]+:[^@[:space:]]+@' "$file"; then
    if ! grep -Eqi -- 'change-me|example\.com|memy_dev_password|password=change' "$file"; then
      # Still allow *.example files with documented placeholders
      if [[ "$rel" != *.example && "$rel" != *.example.* && "$rel" != *README* ]]; then
        report "$rel" "database-url-with-password"
      fi
    fi
  fi
  if grep -Eqi -- '^(JWT_SECRET|REFRESH_TOKEN_PEPPER|MINIO_ROOT_PASSWORD|POSTGRES_PASSWORD|APPLE_PRIVATE_KEY)=' "$file"; then
    if [[ "$rel" != *.example && "$rel" != *.example.* ]]; then
      report "$rel" "credential-assignment"
    fi
  fi
}

while IFS= read -r -d '' file; do
  scan_content "$file"
done < <(find "$ROOT" -type f -print0)

if [[ "$FOUND" -ne 0 ]]; then
  echo "error: secret scan failed for ${BRANCH_LABEL}" >&2
  exit 1
fi

echo "secret scan clean: ${BRANCH_LABEL}"
