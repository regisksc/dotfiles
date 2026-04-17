#!/usr/bin/env bash
# nvim/install.sh
# Interface: install_nvim | backup_nvim | status_nvim

install_nvim() {
  log_info "[nvim] deploying config..."
  link_package "${_NVIM_DIR}/files"
}

backup_nvim() {
  log_info "[nvim] backup skipped — source of truth in repo"
}

status_nvim() {
  _status_symlink "${HOME}/.config/nvim/init.lua"
}

_NVIM_DIR="${DOTFILES_ROOT}/nvim"
