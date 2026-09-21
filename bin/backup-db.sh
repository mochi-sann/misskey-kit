#!/bin/bash
# Back up your database to S3 with pgBackRest
# Usage: ./backup-db.sh [full|diff]

set -euCo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>&1 >/dev/null && pwd)"
export COMPOSE_PROJECT_DIR="${COMPOSE_PROJECT_DIR:-"${SCRIPT_DIR}"/..}"
export COMPOSE_FILE="$SCRIPT_DIR"/../docker-compose.yml
. "$SCRIPT_DIR"/../etc/docker.env

TYPE="${1:-diff}"
case "$TYPE" in
    full|diff) ;;
    *) echo "Usage: $0 [full|diff]" >&2; exit 2 ;;
esac

docker compose exec -T --user postgres db pgbackrest-env --stanza=misskey stanza-create
docker compose exec -T --user postgres db pgbackrest-env --stanza=misskey --type="$TYPE" backup
