#!/usr/bin/env bash
# doctor.sh — environment validation, action planning, plan printing.

PLAN=()

validate_environment() {
  log_info "Validating environment..."
  local ok=0
  command -v bash   >/dev/null || { log_error "bash missing"; ok=1; }
  command -v git    >/dev/null || { log_warn  "git missing (recommended)"; }
  command -v curl   >/dev/null || { log_warn  "curl missing (recommended)"; }

  case "$OS" in
    macos)
      command -v brew >/dev/null || log_warn "Homebrew not installed — install_system_packages will try to bootstrap it"
      ;;
    linux)
      [[ "$PKG_MANAGER" == "unknown" ]] && log_warn "No supported Linux package manager detected"
      ;;
  esac

  local cat
  for cat in shell git tmux nvim packages dev ai; do
    [[ -d "${DOTFILES_ROOT}/${cat}" ]] || log_warn "missing ${cat}/ directory"
  done
  return $ok
}

plan_actions() {
  PLAN=()
  PLAN+=("preflight: ensure git, curl, python3, rsync, envsubst, jq are present")
  PLAN+=("install system packages via ${PKG_MANAGER} (packages/)")
  PLAN+=("bootstrap dev toolchains (dev/)")
  PLAN+=("deploy shell config symlinks (shell/)")
  PLAN+=("deploy git config symlinks (git/)")
  PLAN+=("deploy tmux config symlinks (tmux/)")
  PLAN+=("deploy nvim config symlinks (nvim/)")
  PLAN+=("deploy AI environment: claude, opencode, goose (ai/)")
  PLAN+=("run health checks & save progress")
}

print_plan() {
  echo
  echo "================== PLAN =================="
  local i=1
  for step in "${PLAN[@]}"; do
    printf " %2d. %s\n" "$i" "$step"
    i=$((i+1))
  done
  echo "==========================================="
  echo " os=$OS  machine=$MACHINE_NAME  dry_run=$DRY_RUN"
  echo "==========================================="
}
