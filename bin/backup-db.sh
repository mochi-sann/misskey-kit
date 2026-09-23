#!/bin/bash
# Back up your database to S3 with pgBackRest
# Usage: ./backup-db.sh [full|diff]

set -euCo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>&1 >/dev/null && pwd)"
export COMPOSE_PROJECT_DIR="${COMPOSE_PROJECT_DIR:-"${SCRIPT_DIR}"/..}"
export COMPOSE_FILE="$SCRIPT_DIR"/../docker-compose.yml
. "$SCRIPT_DIR"/lib/log.sh
. "$SCRIPT_DIR"/../etc/docker.env

TYPE="${1:-diff}"
case "$TYPE" in
    full|diff) ;;
    *) echo "Usage: $0 [full|diff]" >&2; exit 2 ;;
esac

# pgBackRest only warns by default; raise it so its own progress is logged too.
LOG_LEVEL="${PGBACKREST_LOG_LEVEL:-detail}"

log_trap_error
log "start: $TYPE backup"

log "[1/2] creating stanza if missing"
docker compose exec -T --user postgres db pgbackrest-env --stanza=misskey \
    --log-level-console="$LOG_LEVEL" stanza-create

log "[2/2] running $TYPE backup (this can take a while)"
docker compose exec -T --user postgres db pgbackrest-env --stanza=misskey \
    --log-level-console="$LOG_LEVEL" --type="$TYPE" backup

log "done: $TYPE backup finished in $(log_elapsed)"
