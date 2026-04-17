#!/usr/bin/env bash
# packages.sh — system package + dev toolchain installation.

_run() {
  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] $*"
  else
    log_debug "exec: $*"
    "$@"
  fi
}

install_system_packages() {
  log_info "install_system_packages (pkg=$PKG_MANAGER)"
  case "$PKG_MANAGER" in
    brew)   _install_brew ;;
    apt)    _install_apt ;;
    dnf)    _install_dnf ;;
    pacman) _install_pacman ;;
    *)      log_warn "No package manager; skipping." ;;
  esac
}

_install_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    log_info "Bootstrapping Homebrew..."
    if [[ "$DRY_RUN" != true ]]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
  fi
  local bf="${DOTFILES_ROOT}/manifests/Brewfile"
  [[ -f "$bf" ]] && _run brew bundle --file="$bf" || log_warn "manifests/Brewfile missing"
}

_install_apt() {
  local list="${DOTFILES_ROOT}/manifests/apt.txt"
  [[ -f "$list" ]] || { log_warn "manifests/apt.txt missing"; return 0; }
  _run sudo apt-get update
  # shellcheck disable=SC2046
  _run sudo apt-get install -y $(grep -v '^\s*#' "$list" | xargs)
}

_install_dnf() {
  local list="${DOTFILES_ROOT}/manifests/dnf.txt"
  [[ -f "$list" ]] || { log_warn "manifests/dnf.txt missing"; return 0; }
  # shellcheck disable=SC2046
  _run sudo dnf install -y $(grep -v '^\s*#' "$list" | xargs)
}

_install_pacman() {
  local list="${DOTFILES_ROOT}/manifests/pacman.txt"
  [[ -f "$list" ]] || { log_warn "manifests/pacman.txt missing"; return 0; }
  # shellcheck disable=SC2046
  _run sudo pacman -S --needed --noconfirm $(grep -v '^\s*#' "$list" | xargs)
}

install_dev_toolchains() {
  log_info "install_dev_toolchains"
  _install_npm_globals
  _install_pipx
  _install_cargo
}

_install_npm_globals() {
  local list="${DOTFILES_ROOT}/manifests/npm-global.txt"
  [[ -f "$list" ]] && command -v npm >/dev/null || return 0
  local pkg
  while read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    _run npm install -g "$pkg"
  done < "$list"
}

_install_pipx() {
  local list="${DOTFILES_ROOT}/manifests/pipx.txt"
  [[ -f "$list" ]] && command -v pipx >/dev/null || return 0
  local pkg
  while read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    _run pipx install "$pkg"
  done < "$list"
}

_install_cargo() {
  local list="${DOTFILES_ROOT}/manifests/cargo.txt"
  [[ -f "$list" ]] && command -v cargo >/dev/null || return 0
  local pkg
  while read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    _run cargo install "$pkg"
  done < "$list"
}
