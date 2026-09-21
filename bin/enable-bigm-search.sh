#!/bin/bash
# Creates index on note table
# Usage: ./enable-bigm-search.sh

set -euCo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>&1 >/dev/null && pwd)"
export COMPOSE_PROJECT_DIR="${COMPOSE_PROJECT_DIR:-"${SCRIPT_DIR}"/..}"
export COMPOSE_FILE="$SCRIPT_DIR"/../docker-compose.yml
. "$SCRIPT_DIR"/../etc/docker.env

docker compose exec db psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
  create index concurrently if not exists
    note_lower_text_bigm
  on note
  using gin(lower(text) gin_bigm_ops)
"
