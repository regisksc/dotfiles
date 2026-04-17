#!/usr/bin/env bash
# install.sh — workstation bootstrap orchestrator
#
# Lifecycle-based entrypoint. Each category lives in its own directory
# with its own install.sh exposing:
#   install_<category>   backup_<category>   status_<category>
#
# Usage:
#   ./install.sh [MODE] [OPTIONS]
#
# Modes:
#   install     Bootstrap or reconcile this machine (default)
#   doctor      Dry-run: validate env, print plan, change nothing
#   backup      Capture current machine config into repo
#   sync        Refresh manifests + secret scan
#   update      Detect untracked important software/config (drift)
#   rollback    Revert actions using state/actions.jsonl
#   status      Show managed state, symlinks, drift
#
# Options:
#   --dry-run            Plan but do not execute
#   --doctor             Alias for doctor mode
#   --yes                Skip confirmations
#   --verbose            Verbose logging
#   --only CATEGORY      Run only one category (e.g. --only ai)
#   --machine-name NAME  Override hostname
#   --os OS              Override OS (macos|linux)
#   --log-dir DIR        Override log dir (default: ./logs)
#   --state-dir DIR      Override state dir (default: ./state)
#   -h, --help           Show this help

set -Eeuo pipefail
IFS=$'\n\t'

DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_ROOT

# --- load shared lib ----------------------------------------------------
for _lib in logging os backup symlink secrets doctor discover rollback progress preflight; do
  # shellcheck disable=SC1090
  source "${DOTFILES_ROOT}/lib/${_lib}.sh"
done

# --- load category installers -------------------------------------------
_load_categories() {
  local only="${ONLY_CATEGORY:-}"
  local cats=(shell git tmux nvim packages dev ai agents)
  for cat in "${cats[@]}"; do
    [[ -n "$only" && "$cat" != "$only" ]] && continue
    local f="${DOTFILES_ROOT}/${cat}/install.sh"
    [[ -f "$f" ]] && source "$f" || log_warn "missing ${cat}/install.sh"
  done
}

# --- defaults -----------------------------------------------------------
MODE="install"
DRY_RUN=false
YES=false
VERBOSE=false
MACHINE_NAME="$(hostname -s 2>/dev/null || hostname)"
OS_OVERRIDE=""
LOG_DIR="${DOTFILES_ROOT}/logs"
STATE_DIR="${DOTFILES_ROOT}/state"
BACKUP_DIR="${DOTFILES_ROOT}/backups"
ONLY_CATEGORY=""

# --- CLI ----------------------------------------------------------------
usage() { sed -n '2,32p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

parse_cli() {
  if [[ $# -gt 0 && "$1" != -* ]]; then MODE="$1"; shift; fi
  while [[ $# -gt 0 ]]; do
    case "$1" in
      install|doctor|backup|sync|update|rollback|status) MODE="$1"; shift ;;
      --dry-run)       DRY_RUN=true; shift ;;
      --doctor)        MODE="doctor"; DRY_RUN=true; shift ;;
      --yes)           YES=true; shift ;;
      --verbose)       VERBOSE=true; shift ;;
      --only)          ONLY_CATEGORY="$2"; shift 2 ;;
      --machine-name)  MACHINE_NAME="$2"; shift 2 ;;
      --os)            OS_OVERRIDE="$2"; shift 2 ;;
      --log-dir)       LOG_DIR="$2"; shift 2 ;;
      --state-dir)     STATE_DIR="$2"; shift 2 ;;
      -h|--help)       usage; exit 0 ;;
      *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
    esac
  done
  [[ "$MODE" == "doctor" ]] && DRY_RUN=true
  export MODE DRY_RUN YES VERBOSE MACHINE_NAME LOG_DIR STATE_DIR BACKUP_DIR ONLY_CATEGORY
}

# --- lock ---------------------------------------------------------------
LOCK_FILE=""
acquire_lock() {
  mkdir -p "${STATE_DIR}"
  LOCK_FILE="${STATE_DIR}/install.lock"
  if [[ -e "$LOCK_FILE" ]] && kill -0 "$(cat "$LOCK_FILE" 2>/dev/null)" 2>/dev/null; then
    log_error "Another install is running (pid $(cat "$LOCK_FILE"))."; exit 1
  fi
  echo $$ > "$LOCK_FILE"
  trap 'rm -f "$LOCK_FILE"' EXIT
}

confirm() {
  [[ "$YES" == true || "$DRY_RUN" == true ]] && return 0
  read -r -p "${1:-Proceed?} [y/N] " ans
  [[ "$ans" =~ ^[Yy]$ ]]
}

# --- helpers ------------------------------------------------------------
_status_symlink() {
  local p="$1"
  if [[ -L "$p" ]]; then   echo "  $p → $(readlink "$p") [ok]"
  elif [[ -e "$p" ]]; then echo "  $p [exists, NOT symlinked]"
  else                      echo "  $p [MISSING]"
  fi
}
export -f _status_symlink

# --- commands -----------------------------------------------------------
cmd_install() {
  validate_environment || exit 1
  plan_actions; print_plan
  confirm "Apply the plan above?" || { log_warn "Aborted."; exit 2; }

  preflight
  progress_mark "install" "start"
  install_packages
  install_dev
  install_shell
  install_git
  install_tmux
  install_nvim
  install_ai
  install_agents
  run_health_checks
  print_post_install_checklist
  progress_mark "install" "done"
}

cmd_doctor() {
  validate_environment || { log_error "Environment validation failed."; exit 1; }
  plan_actions; print_plan
  log_info "Doctor complete — no changes made."
}

cmd_backup() {
  progress_mark "backup" "start"
  backup_packages
  backup_shell
  backup_ai
  backup_agents
  progress_mark "backup" "done"
  log_info "Backup complete. Review: git diff"
}

cmd_sync() {
  backup_packages
  backup_shell
  backup_ai
  backup_agents
  secret_scan "${DOTFILES_ROOT}" || { log_error "Secret scan failed."; exit 1; }
  log_info "Sync complete."
}

cmd_update() {
  discover_untracked_configs
  log_info "Discovery complete. See ${STATE_DIR}/discovery.txt"
}

cmd_rollback() {
  log_warn "Rolling back from ${STATE_DIR}/actions.jsonl"
  confirm "Rollback will reverse recorded actions. Continue?" || exit 2
  rollback_from_log "${STATE_DIR}/actions.jsonl"
}

cmd_status() {
  status_shell; status_git; status_tmux; status_nvim
  status_ai
  status_agents
  status_packages
}

# --- health checks ------------------------------------------------------
run_health_checks() {
  log_info "Running health checks..."
  local failed=0
  command -v git >/dev/null || { log_warn "git missing"; failed=1; }
  [[ $failed -eq 0 ]] && log_info "Health checks passed."
}

print_post_install_checklist() {
  [[ "$DRY_RUN" == true ]] && return 0
  cat <<'EOF'

================== POST-INSTALL CHECKLIST ==================
✓ Preflight tools installed
✓ System packages installed
✓ Dev toolchains bootstrapped
✓ Shell, git, tmux, nvim configs deployed
✓ AI environment synced

NEXT STEPS:
  1. Populate secrets for template rendering:
       cp templates/.env.example .env.local
       $EDITOR .env.local  # fill in ANTHROPIC_API_KEY, etc.

  2. Re-run install to render templates with your API keys:
       ./install.sh install --only ai

  3. Verify symlinks and status:
       ./install.sh status

  4. Test your environment:
       zsh                    # restart shell
       echo $ANTHROPIC_API_KEY  # verify env loaded
       claude --version       # verify Claude Code works

  5. (Optional) Set up periodic sync in cron/launchd:
       ./install.sh install --only schedules

  6. Commit your .env.local reference (NEVER):
       .env.local is .gitignored — keep secrets local

Reference templates:
  - API keys: templates/.env.example
  - Config: README.md "What gets captured" section
  - Troubleshooting: docs/TESTING.md

==========================================================
EOF
}

# --- main ---------------------------------------------------------------
main() {
  parse_cli "$@"
  init_logging "$LOG_DIR" "$STATE_DIR" "$VERBOSE"
  detect_os "$OS_OVERRIDE"
  acquire_lock
  _load_categories

  log_info "install.sh mode=$MODE dry_run=$DRY_RUN os=$OS machine=$MACHINE_NAME"
  [[ -n "$ONLY_CATEGORY" ]] && log_info "scope: --only $ONLY_CATEGORY"

  case "$MODE" in
    install)   cmd_install ;;
    doctor)    cmd_doctor ;;
    backup)    cmd_backup ;;
    sync)      cmd_sync ;;
    update)    cmd_update ;;
    rollback)  cmd_rollback ;;
    status)    cmd_status ;;
    *) log_error "Unknown mode: $MODE"; exit 1 ;;
  esac

  echo
  echo "=== DONE: mode=$MODE dry_run=$DRY_RUN os=$OS ==="
}

main "$@"
