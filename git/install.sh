#!/usr/bin/env bash
# git/install.sh — git config deployment
# Interface: install_git | backup_git | status_git

install_git() {
  log_info "[git] deploying config files..."
  link_package "${_GIT_DIR}/files"

  # Render gitconfig.local from template if not present
  local local_cfg="${HOME}/.gitconfig.local"
  if [[ ! -f "$local_cfg" ]]; then
    local tmpl="${DOTFILES_ROOT}/templates/gitconfig.local.tmpl"
    [[ -f "$tmpl" ]] && render_template "$tmpl" "$local_cfg" || true
  fi
}

backup_git() {
  log_info "[git] backup skipped — git config is source of truth in repo"
}

status_git() {
  _status_symlink "${HOME}/.gitconfig"
  _status_symlink "${HOME}/.gitconfig.local"
}

_GIT_DIR="${DOTFILES_ROOT}/git"
