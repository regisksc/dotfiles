#!/usr/bin/env bash
# rollback.sh — reverse actions recorded in state/actions.jsonl
#
# JSONL record shape:
#   {ts, type, path, prev, new, backup, status, hint}
#
# Rollback walks entries in REVERSE order and attempts the inverse.
# Types handled: symlink, backup, template. Others are logged and skipped.

rollback_from_log() {
  local log_file="$1"
  [[ -f "$log_file" ]] || { log_error "no action log at $log_file"; return 1; }

  local reversed; reversed="$(mktemp)"
  tac "$log_file" 2>/dev/null > "$reversed" || tail -r "$log_file" > "$reversed"

  local line
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    _rollback_one "$line"
  done < "$reversed"
  rm -f "$reversed"
  log_info "Rollback pass complete. Review logs for skipped entries."
}

_json_field() {
  # extremely small JSON field extractor; tolerates our own emitter only
  local json="$1" key="$2"
  printf '%s' "$json" | sed -n "s/.*\"${key}\":\"\\([^\"]*\\)\".*/\\1/p"
}

_rollback_one() {
  local json="$1"
  local type path prev new backup
  type="$(_json_field "$json" type)"
  path="$(_json_field "$json" path)"
  prev="$(_json_field "$json" prev)"
  new="$(_json_field "$json" new)"
  backup="$(_json_field "$json" backup)"

  case "$type" in
    symlink)
      if [[ -L "$path" ]]; then
        log_info "rollback: rm symlink $path"
        [[ "$DRY_RUN" == true ]] || rm -f "$path"
      fi
      if [[ -n "$backup" && -e "$backup" ]]; then
        log_info "rollback: restore $backup -> $path"
        [[ "$DRY_RUN" == true ]] || cp -a "$backup" "$path"
      fi
      ;;
    template)
      if [[ -f "$path" ]]; then
        log_info "rollback: rm rendered $path"
        [[ "$DRY_RUN" == true ]] || rm -f "$path"
      fi
      ;;
    backup)
      log_debug "rollback: backup entry (no-op): $path"
      ;;
    *)
      log_warn "rollback: unknown type=$type path=$path (skipped)"
      ;;
  esac
}
