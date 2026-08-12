#!/usr/bin/env bash
# Back-compat wrapper — prefer scripts/backup.sh staging
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
exec "$ROOT/scripts/backup.sh" staging
