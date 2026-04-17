#!/usr/bin/env bash
# discover.sh — drift discovery: find important config/software not yet tracked.
#
# Writes candidates to state/discovery.txt for human review. Allowlist-first:
# we only look in well-known locations and ignore known caches/state.

_KNOWN_CACHE_DIRS=(
  "Cache" "Caches" "cache" "logs" "Crash*" "GPUCache" "Code Cache"
  "node_modules" ".DS_Store" "Trash" "tmp"
)

_should_skip() {
  local path="$1"
  local part
  for part in "${_KNOWN_CACHE_DIRS[@]}"; do
    [[ "$path" == *"/$part"* ]] && return 0
  done
  return 1
}

discover_untracked_configs() {
  local out="${STATE_DIR}/discovery.txt"
  mkdir -p "$STATE_DIR"
  : > "$out"

  log_info "Scanning ~/.config, ~/.local/share, home dotfiles..."

  local roots=(
    "$HOME/.config"
    "$HOME/.local/share"
  )
  local r
  for r in "${roots[@]}"; do
    [[ -d "$r" ]] || continue
    find "$r" -maxdepth 2 -type d 2>/dev/null | while read -r d; do
      _should_skip "$d" && continue
      local name; name="$(basename "$d")"
      # naive: flag if not already referenced in repo
      if ! grep -rq "$name" "${DOTFILES_ROOT}/dotfiles" "${DOTFILES_ROOT}/ai" "${DOTFILES_ROOT}/manifests" 2>/dev/null; then
        echo "$d" >> "$out"
      fi
    done
  done

  # Home dotfiles (top-level only)
  find "$HOME" -maxdepth 1 -name '.*' -type f 2>/dev/null | while read -r f; do
    local name; name="$(basename "$f")"
    if ! grep -rq "$name" "${DOTFILES_ROOT}/dotfiles" 2>/dev/null; then
      echo "$f" >> "$out"
    fi
  done

  log_info "Discovery candidates: $(wc -l < "$out" | tr -d ' ')"
  log_info "Review: $out"
}

update_manifests() {
  backup_manifests_from_machine
}
