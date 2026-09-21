#!/bin/bash
# Restore the latest pgBackRest backup, or a specific backup set
# Usage: ./restore-db.sh [BACKUP_SET]

set -euCo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>&1 >/dev/null && pwd)"
export COMPOSE_PROJECT_DIR="${COMPOSE_PROJECT_DIR:-"${SCRIPT_DIR}"/..}"
export COMPOSE_FILE="$SCRIPT_DIR"/../docker-compose.yml
. "$SCRIPT_DIR"/../etc/docker.env

ARGS=(--stanza=misskey --delta)
if [ -n "${1:-}" ]; then
    ARGS+=(--set="$1" --type=immediate --target-action=promote)
fi

docker compose stop db
docker compose run --rm --no-deps --user postgres --entrypoint pgbackrest-env db \
    "${ARGS[@]}" restore
docker compose up -d --wait db
