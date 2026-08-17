#!/usr/bin/env bash
# Website content safety checks for apps/www (static).
set -euo pipefail

ROOT="${1:-}"
if [[ -z "$ROOT" ]]; then
  echo "Usage: $0 <website-tree-root>" >&2
  exit 2
fi

WWW="${ROOT}/apps/www"
if [[ ! -d "$WWW" ]]; then
  echo "error: missing apps/www under ${ROOT}" >&2
  exit 1
fi

fail=0
hit() {
  echo "WEBSITE_CHECK_FAIL: $1"
  fail=1
}

[[ -f "${WWW}/index.html" ]] || hit "missing index.html"
[[ -f "${WWW}/privacy.html" ]] || hit "missing privacy.html"
[[ -f "${WWW}/terms.html" ]] || hit "missing terms.html"
[[ -f "${WWW}/support.html" ]] || hit "missing support.html"

if ! python3 - "$WWW" <<'PY'
import os, re, sys
www = sys.argv[1]
fail = 0

def hit(msg):
    global fail
    print(f"WEBSITE_CHECK_FAIL: {msg}")
    fail = 1

for dirpath, _, files in os.walk(www):
    for name in files:
        if not name.endswith((".html", ".htm")):
            continue
        path = os.path.join(dirpath, name)
        text = open(path, encoding="utf-8", errors="ignore").read()
        for m in re.finditer(r"""(?:src|href)\s*=\s*["']([^"']+)["']""", text, re.I):
            ref = m.group(1)
            if ref.startswith(("http://", "https://", "mailto:", "tel:", "data:", "#")):
                continue
            if ref.endswith(".apk"):
                continue
            if ref.startswith("/"):
                target = os.path.normpath(www + ref)
            else:
                target = os.path.normpath(os.path.join(dirpath, ref))
            if not os.path.exists(target):
                hit(f"missing asset from {name}: {ref}")

forbidden = re.compile(
    r"demo[_-]?password|DEMO_USER|X-Dev-User-Id|screenshot.?mode|localhost:3000",
    re.I,
)
for dirpath, _, files in os.walk(www):
    for name in files:
        if not name.endswith((".html", ".js", ".css", ".md", ".txt")):
            continue
        path = os.path.join(dirpath, name)
        text = open(path, encoding="utf-8", errors="ignore").read()
        if forbidden.search(text):
            hit(f"forbidden content in {os.path.relpath(path, www)}")

sys.exit(fail)
PY
then
  fail=1
fi

# Snapshot-shaped trees must not ship prototype / owner-only / deploy docs.
# Monorepo checkouts still contain those paths beside apps/www; skip there.
is_snapshot=0
if [[ -f "${ROOT}/.memy-generated-branch" ]]; then
  is_snapshot=1
elif [[ ! -d "${ROOT}/apps/mobile" && ! -d "${ROOT}/apps/api" ]]; then
  is_snapshot=1
fi

if [[ "$is_snapshot" -eq 1 ]]; then
  if find "$ROOT" -type d -name 'prototype' 2>/dev/null | grep -q .; then
    hit "prototype directory must not appear in website snapshot"
  fi
  if find "$ROOT" -type f -path '*/docs/release/owner-actions.md' 2>/dev/null | grep -q .; then
    hit "owner-only document present"
  fi
  if find "$ROOT" -type f -path '*/docs/deployment/*' 2>/dev/null | grep -q .; then
    hit "internal deployment docs must not ship on website branch"
  fi
fi

if [[ "$fail" -ne 0 ]]; then
  echo "error: website content validation failed" >&2
  exit 1
fi

echo "website content validation passed"
