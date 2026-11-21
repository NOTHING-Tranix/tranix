#!/usr/bin/env bash
# B-1405: logical backup of the Tranix database (custom format, compressed).
# Usage: tools/db-backup.sh [out-dir]    — uses DB_HOST/DB_PORT/DB_NAME/DB_USER (+ PGPASSWORD) or the local docker compose db.
set -euo pipefail
OUT_DIR="${1:-./backups}"
mkdir -p "$OUT_DIR"
FILE="$OUT_DIR/tranix-$(date -u +%Y%m%dT%H%M%SZ).dump"
pg_dump --format=custom --no-owner --host="${DB_HOST:-localhost}" --port="${DB_PORT:-5432}" \
  --username="${DB_USER:-tranix}" --dbname="${DB_NAME:-tranixdb}" --file="$FILE"
echo "backup written: $FILE"
