#!/usr/bin/env bash
# symlink.sh — conflict-aware symlink deployment (stow-like).
#
# Layout: dotfiles/<package>/... mirrors paths relative to $HOME.
# Overlays: overlays/{common,macos,linux,machine/<host>}/... same semantics.

# create_symlink <src> <dest>
create_symlink() {
  local src="$1" dest="$2"
  mkdir -p "$(dirname "$dest")"

  if [[ -L "$dest" ]]; then
    local current; current="$(readlink "$dest")"
    if [[ "$current" == "$src" ]]; then
      log_debug "symlink ok: $dest -> $src"
      return 0
    fi
  fi

  local backup=""
  if [[ -e "$dest" || -L "$dest" ]]; then
    backup="$(backup_file "$dest")"
    [[ "$DRY_RUN" == true ]] || rm -rf "$dest"
  fi

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] would link $dest -> $src"
    return 0
  fi

  ln -s "$src" "$dest"
  log_action "symlink" "$dest" "absent_or_replaced" "$src" "$backup" "ok" "rm $dest && mv $backup $dest"
  printf '%s\t%s\n' "$dest" "$src" >> "${STATE_DIR}/symlinks.tsv"
  log_info "linked $dest -> $src"
}

# link_package <package_dir>
# Walks files under a package dir and mirrors them under $HOME.
link_package() {
  local pkg_dir="$1"
  [[ -d "$pkg_dir" ]] || return 0
  while IFS= read -r -d '' f; do
    local rel="${f#"$pkg_dir"/}"
    create_symlink "$f" "$HOME/$rel"
  done < <(find "$pkg_dir" -type f -print0)
}

create_symlinks() {
  log_info "Deploying dotfile symlinks..."
  : > "${STATE_DIR}/symlinks.tsv"
  local pkg
  for pkg in "${DOTFILES_ROOT}/dotfiles/"*/; do
    [[ -d "$pkg" ]] && link_package "$pkg"
  done
}

apply_machine_overlays() {
  log_info "Applying overlays (common → $OS → machine/$MACHINE_NAME)..."
  link_package "${DOTFILES_ROOT}/overlays/common"
  link_package "${DOTFILES_ROOT}/overlays/${OS}"
  link_package "${DOTFILES_ROOT}/overlays/machine/${MACHINE_NAME}"
}
