#!/bin/bash
# Fail when the latest WAL archive attempt has not recovered

set -euCo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>&1 >/dev/null && pwd)"
export COMPOSE_PROJECT_DIR="${COMPOSE_PROJECT_DIR:-"${SCRIPT_DIR}"/..}"
export COMPOSE_FILE="$SCRIPT_DIR"/../docker-compose.yml
. "$SCRIPT_DIR"/../etc/docker.env

FAILED="$(docker compose exec -T --user postgres db psql \
    -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atqc \
    "SELECT last_failed_time IS NOT NULL AND (last_archived_time IS NULL OR last_failed_time > last_archived_time) FROM pg_stat_archiver")"

if [ "$FAILED" = t ]; then
    echo "WAL archiving is failing; pg_wal will grow until object storage recovers" >&2
    exit 1
fi
