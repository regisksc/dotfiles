#!/usr/bin/env bash
# backup.sh — backup-before-replace + manifest capture.

# backup_file <path>
# If $path exists and is not already a symlink into $DOTFILES_ROOT,
# copy it into $BACKUP_DIR/<epoch>/... and echo the backup path.
backup_file() {
  local src="$1"
  [[ -e "$src" || -L "$src" ]] || { echo ""; return 0; }

  local ts; ts="$(date +%Y%m%d-%H%M%S)"
  local rel="${src#/}"
  local dest="${BACKUP_DIR}/${ts}/${rel}"
  mkdir -p "$(dirname "$dest")"

  if [[ "$DRY_RUN" == true ]]; then
    log_debug "[dry-run] would back up $src -> $dest"
    echo "$dest"; return 0
  fi

  cp -a "$src" "$dest"
  log_action "backup" "$src" "exists" "copied" "$dest" "ok" "rm $dest to discard"
  echo "$dest"
}

backup_existing_state() {
  log_info "backup_existing_state: snapshotting dotfile targets..."
  mkdir -p "$BACKUP_DIR"
  # Per-dotfile backup is performed on-demand by create_symlink.
}

# backup_manifests_from_machine — snapshot current packages into manifests/
backup_manifests_from_machine() {
  mkdir -p "${DOTFILES_ROOT}/manifests"
  if [[ "$OS" == "macos" ]] && command -v brew >/dev/null 2>&1; then
    log_info "Dumping Brewfile..."
    [[ "$DRY_RUN" == true ]] || brew bundle dump --force --file="${DOTFILES_ROOT}/manifests/Brewfile"
  fi
  if command -v npm >/dev/null 2>&1; then
    log_info "Dumping npm globals..."
    [[ "$DRY_RUN" == true ]] || npm list -g --depth=0 --parseable 2>/dev/null \
      | awk -F/ 'NR>1{print $NF}' > "${DOTFILES_ROOT}/manifests/npm-global.txt" || true
  fi
  if command -v pipx >/dev/null 2>&1; then
    log_info "Dumping pipx list..."
    [[ "$DRY_RUN" == true ]] || pipx list --short > "${DOTFILES_ROOT}/manifests/pipx.txt" || true
  fi
  if command -v cargo >/dev/null 2>&1; then
    log_info "Dumping cargo installs..."
    [[ "$DRY_RUN" == true ]] || cargo install --list 2>/dev/null \
      | awk '/^[a-zA-Z0-9_-]+ v/ {print $1}' > "${DOTFILES_ROOT}/manifests/cargo.txt" || true
  fi
  if [[ "$PKG_MANAGER" == "apt" ]]; then
    [[ "$DRY_RUN" == true ]] || apt-mark showmanual > "${DOTFILES_ROOT}/manifests/apt.txt" || true
  fi
}
