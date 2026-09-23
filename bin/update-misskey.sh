#!/bin/bash
# Update misskey container from dockerhub without downtime
# Usage: ./update-misskey.sh [TAG]

set -euCo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>&1 >/dev/null && pwd)"
export COMPOSE_PROJECT_DIR="${COMPOSE_PROJECT_DIR:-"${SCRIPT_DIR}"/..}"
export COMPOSE_FILE="$SCRIPT_DIR"/../docker-compose.yml
. "$SCRIPT_DIR"/lib/log.sh

TAG="${1:-latest}"

log_trap_error
log "start: update to tag '$TAG'"

# Always take a differential backup before starting the update.
log "[1/5] taking a differential backup before the update"
"$SCRIPT_DIR"/backup-db.sh diff

log "[2/5] pruning stopped containers and dangling images"
docker container prune -f
docker image prune -f

log "[3/5] pulling image for tag '$TAG'"
if [[ "$TAG" == "latest" ]]; then
    docker pull misskey/misskey:latest
elif [[ "$TAG" =~ / ]]; then
    # PATH/IMAGE:TAG format
    docker pull "$TAG"
    docker tag "$TAG" misskey/misskey:latest
else
    # TAG format
    docker pull misskey/misskey:"$TAG"
    docker tag misskey/misskey:"$TAG" misskey/misskey:latest
fi

OLD_CONTAINER="$(docker compose ps web | tail -n1 | awk '{print $1}')"
log "[4/5] starting the new web container (current: ${OLD_CONTAINER:-none})"
docker compose up -d --no-recreate --wait --scale web=2 web

log "[5/5] stopping the old web container ($OLD_CONTAINER) and pruning"
docker stop "$OLD_CONTAINER"
docker container prune -f
docker image prune -f

log "done: update to tag '$TAG' finished in $(log_elapsed)"
