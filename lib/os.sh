#!/usr/bin/env bash
# os.sh — OS and package manager detection.
#
# Sets globals:
#   OS              "macos" | "linux"
#   OS_DISTRO       "ubuntu"|"debian"|"fedora"|"arch"|"unknown" (linux only)
#   PKG_MANAGER     "brew"|"apt"|"dnf"|"pacman"|"unknown"

OS=""
OS_DISTRO=""
PKG_MANAGER=""

detect_os() {
  local override="${1:-}"
  if [[ -n "$override" ]]; then
    OS="$override"
  else
    case "$(uname -s)" in
      Darwin) OS="macos" ;;
      Linux)  OS="linux" ;;
      *) log_error "Unsupported OS: $(uname -s)"; return 1 ;;
    esac
  fi

  if [[ "$OS" == "linux" ]]; then
    if [[ -r /etc/os-release ]]; then
      # shellcheck disable=SC1091
      . /etc/os-release
      OS_DISTRO="${ID:-unknown}"
    else
      OS_DISTRO="unknown"
    fi
  fi

  detect_pkg_manager
  export OS OS_DISTRO PKG_MANAGER
  log_debug "detected os=$OS distro=$OS_DISTRO pkg=$PKG_MANAGER"
}

detect_pkg_manager() {
  if [[ "$OS" == "macos" ]]; then
    PKG_MANAGER="brew"
    return
  fi
  if command -v apt-get >/dev/null 2>&1; then PKG_MANAGER="apt"
  elif command -v dnf >/dev/null 2>&1;     then PKG_MANAGER="dnf"
  elif command -v pacman >/dev/null 2>&1;  then PKG_MANAGER="pacman"
  else PKG_MANAGER="unknown"
  fi
}
