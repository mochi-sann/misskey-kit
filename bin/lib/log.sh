#!/bin/bash
# Timestamped progress logging shared by bin/*.sh
# Usage: . "$SCRIPT_DIR"/lib/log.sh
#
# Messages go to stderr so that they interleave with the unbuffered output of
# docker/pgbackrest. When run from cron they end up in the cron container log
# (docker compose logs cron).

LOG_TAG="${LOG_TAG:-$(basename "${BASH_SOURCE[1]:-$0}" .sh)}"

log() {
    printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S%z')" "$LOG_TAG" "$*" >&2
}

# Report where a `set -e` abort happened instead of dying silently.
log_trap_error() {
    trap 'log "FAILED: exit $? at line $LINENO"' ERR
}

# Seconds elapsed since the script started, for "done in Ns" messages.
log_elapsed() {
    printf '%ds' "$SECONDS"
}
