#!/usr/bin/env bash
# dev/install.sh — dev toolchain bootstrap (pyenv, nvm/fnm, rustup, go)
# Interface: install_dev | backup_dev | status_dev

install_dev() {
  log_info "[dev] bootstrapping toolchains..."
  _dev_pyenv
  _dev_node
  _dev_rust
  _dev_go
}

backup_dev() {
  log_info "[dev] toolchain versions captured via packages/manifests"
}

status_dev() {
  local tools=(pyenv node python3 cargo go)
  local t
  for t in "${tools[@]}"; do
    if command -v "$t" >/dev/null 2>&1; then
      echo "  $t: $(command -v "$t")"
    else
      echo "  $t: NOT FOUND"
    fi
  done
}

_dev_run() {
  [[ "$DRY_RUN" == true ]] && { log_info "[dry-run] $*"; return; }
  "$@"
}

_dev_pyenv() {
  if ! command -v pyenv >/dev/null 2>&1; then
    log_info "[dev] installing pyenv..."
    _dev_run curl https://pyenv.run | bash || true
  else
    log_info "[dev] pyenv already present"
  fi
}

_dev_node() {
  if ! command -v node >/dev/null 2>&1 && ! command -v fnm >/dev/null 2>&1; then
    log_info "[dev] installing fnm (fast Node manager)..."
    _dev_run curl -fsSL https://fnm.vercel.app/install | bash || true
  else
    log_info "[dev] node/fnm already present"
  fi
}

_dev_rust() {
  if ! command -v rustup >/dev/null 2>&1; then
    log_info "[dev] installing rustup..."
    _dev_run curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || true
  else
    log_info "[dev] rustup already present"
  fi
}

_dev_go() {
  if ! command -v go >/dev/null 2>&1; then
    log_warn "[dev] go not found — install via brew (macos) or https://go.dev/dl"
  else
    log_info "[dev] go already present"
  fi
}
