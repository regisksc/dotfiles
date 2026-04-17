#!/usr/bin/env bash
# packages/install.sh — system package installation
# Interface: install_packages | backup_packages | status_packages

install_packages() {
  log_info "[packages] installing system packages..."
  case "$PKG_MANAGER" in
    brew)   _pkg_brew ;;
    apt)    _pkg_apt ;;
    dnf)    _pkg_dnf ;;
    pacman) _pkg_pacman ;;
    *)      log_warn "[packages] no supported package manager" ;;
  esac
  _pkg_npm_globals
  _pkg_pipx
  _pkg_cargo
}

backup_packages() {
  log_info "[packages] capturing installed packages into manifests..."
  local mdir="${CATEGORY_DIR}/manifests"
  mkdir -p "$mdir"

  if [[ "$OS" == "macos" ]] && command -v brew >/dev/null; then
    [[ "$DRY_RUN" == true ]] || brew bundle dump --force --file="${mdir}/Brewfile"
    log_info "[packages] Brewfile updated"
  fi
  if command -v npm >/dev/null; then
    [[ "$DRY_RUN" == true ]] || npm list -g --depth=0 --parseable 2>/dev/null \
      | awk -F/ 'NR>1{print $NF}' > "${mdir}/npm-global.txt" || true
  fi
  if command -v pipx >/dev/null; then
    [[ "$DRY_RUN" == true ]] || pipx list --short > "${mdir}/pipx.txt" || true
  fi
  if command -v cargo >/dev/null; then
    [[ "$DRY_RUN" == true ]] || cargo install --list 2>/dev/null \
      | awk '/^[a-zA-Z0-9_-]+ v/{print $1}' > "${mdir}/cargo.txt" || true
  fi
  if [[ "$PKG_MANAGER" == "apt" ]]; then
    [[ "$DRY_RUN" == true ]] || apt-mark showmanual > "${mdir}/apt.txt" || true
  fi
}

status_packages() {
  local mdir="${CATEGORY_DIR}/manifests"
  echo "  manifests: $(ls "$mdir" 2>/dev/null | tr '\n' ' ')"
}

# --- internal -----------------------------------------------------------
_pkg_run() {
  [[ "$DRY_RUN" == true ]] && { log_info "[dry-run] $*"; return; }
  "$@"
}

_pkg_brew() {
  local bf="${CATEGORY_DIR}/manifests/Brewfile"
  [[ -f "$bf" ]] || { log_warn "[packages] Brewfile missing"; return; }
  command -v brew >/dev/null || {
    log_info "[packages] installing Homebrew..."
    _pkg_run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  }
  _pkg_run brew bundle --file="$bf"
}

_pkg_apt() {
  local list="${CATEGORY_DIR}/manifests/apt.txt"
  [[ -f "$list" ]] || return
  _pkg_run sudo apt-get update
  # shellcheck disable=SC2046
  _pkg_run sudo apt-get install -y $(grep -v '^\s*#' "$list" | xargs)
}

_pkg_dnf() {
  local list="${CATEGORY_DIR}/manifests/dnf.txt"
  [[ -f "$list" ]] || return
  # shellcheck disable=SC2046
  _pkg_run sudo dnf install -y $(grep -v '^\s*#' "$list" | xargs)
}

_pkg_pacman() {
  local list="${CATEGORY_DIR}/manifests/pacman.txt"
  [[ -f "$list" ]] || return
  # shellcheck disable=SC2046
  _pkg_run sudo pacman -S --needed --noconfirm $(grep -v '^\s*#' "$list" | xargs)
}

_pkg_npm_globals() {
  local list="${CATEGORY_DIR}/manifests/npm-global.txt"
  [[ -f "$list" ]] && command -v npm >/dev/null || return
  local pkg
  while read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    _pkg_run npm install -g "$pkg"
  done < "$list"
}

_pkg_pipx() {
  local list="${CATEGORY_DIR}/manifests/pipx.txt"
  [[ -f "$list" ]] && command -v pipx >/dev/null || return
  local pkg
  while read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    pkg="${pkg%% *}"  # strip version
    _pkg_run pipx install "$pkg"
  done < "$list"
}

_pkg_cargo() {
  local list="${CATEGORY_DIR}/manifests/cargo.txt"
  [[ -f "$list" ]] && command -v cargo >/dev/null || return
  local pkg
  while read -r pkg; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    _pkg_run cargo install "$pkg"
  done < "$list"
}

CATEGORY_DIR="${DOTFILES_ROOT}/packages"
