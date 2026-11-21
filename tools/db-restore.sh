#!/usr/bin/env bash
# B-1405: restore test — restores a dump into a NEW empty database (never over the live one) and checks row counts.
# Usage: tools/db-restore.sh backups/tranix-<time>.dump tranix_restore_test
set -euo pipefail
DUMP="$1"
TARGET="${2:-tranix_restore_test}"
HOST="${DB_HOST:-localhost}"; PORT="${DB_PORT:-5432}"; USER_="${DB_USER:-tranix}"
createdb --host="$HOST" --port="$PORT" --username="$USER_" "$TARGET"
pg_restore --no-owner --host="$HOST" --port="$PORT" --username="$USER_" --dbname="$TARGET" "$DUMP"
for t in identity_user loads_load wallet_entry trust_event; do
  printf '%-16s %s\n' "$t" "$(psql -tA --host="$HOST" --port="$PORT" --username="$USER_" --dbname="$TARGET" -c "select count(*) from $t")"
done
echo "restore test OK into database $TARGET (drop it when done)"
