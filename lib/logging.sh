#!/usr/bin/env bash
# logging.sh — dual logging: human-readable + JSONL action log
#
# Exposes:
#   init_logging <log_dir> <state_dir> <verbose>
#   log_info / log_warn / log_error / log_debug <msg...>
#   log_action <type> <path> <prev> <new> <backup> <status> <hint>
#
# JSONL action entries are the authoritative record used by rollback.

LOG_FILE=""
ACTION_LOG=""
_VERBOSE=false

_ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }

init_logging() {
  local log_dir="$1" state_dir="$2" verbose="${3:-false}"
  mkdir -p "$log_dir" "$state_dir"
  LOG_FILE="${log_dir}/install-$(date +%Y%m%d-%H%M%S).log"
  ACTION_LOG="${state_dir}/actions.jsonl"
  _VERBOSE="$verbose"
  : > "$LOG_FILE"
  touch "$ACTION_LOG"
  export LOG_FILE ACTION_LOG _VERBOSE
  log_info "logging initialized: $LOG_FILE"
}

_log() {
  local level="$1"; shift
  local msg="$*"
  local line="[$(_ts)] [$level] $msg"
  echo "$line" | tee -a "$LOG_FILE" >&2
}

log_info()  { _log INFO  "$*"; }
log_warn()  { _log WARN  "$*"; }
log_error() { _log ERROR "$*"; }
log_debug() { [[ "$_VERBOSE" == true ]] && _log DEBUG "$*" || true; }

# log_action writes one JSONL line. Fields are positional for simplicity.
# Usage: log_action TYPE PATH PREV NEW BACKUP STATUS HINT
log_action() {
  local type="$1" path="$2" prev="$3" new="$4" backup="$5" status="$6" hint="${7:-}"
  # escape minimal: replace " with \"
  _esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
  printf '{"ts":"%s","type":"%s","path":"%s","prev":"%s","new":"%s","backup":"%s","status":"%s","hint":"%s"}\n' \
    "$(_ts)" "$(_esc "$type")" "$(_esc "$path")" "$(_esc "$prev")" \
    "$(_esc "$new")" "$(_esc "$backup")" "$(_esc "$status")" "$(_esc "$hint")" \
    >> "$ACTION_LOG"
}
