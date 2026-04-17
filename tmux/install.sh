#!/usr/bin/env bash
# tmux/install.sh
# Interface: install_tmux | backup_tmux | status_tmux

install_tmux() {
  log_info "[tmux] deploying config..."
  link_package "${_TMUX_DIR}/files"
}

backup_tmux() {
  log_info "[tmux] backup skipped — source of truth in repo"
}

status_tmux() {
  _status_symlink "${HOME}/.tmux.conf"
}

_TMUX_DIR="${DOTFILES_ROOT}/tmux"
