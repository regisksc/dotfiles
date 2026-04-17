#!/usr/bin/env bash
# lib/preflight.sh — bootstrap required tools before any category runs.
#
# Tools are classified as:
#   MANDATORY: required for install.sh to function (git, curl, python3, rsync)
#   OPTIONAL:  nice-to-have; skipped on failure (jq, envsubst with fallback)
#
# On failure:
#   - Mandatory: prompt user to retry or abort
#   - Optional: collect and report at end
#
# On success: collected in PREFLIGHT_MISSING_OPTIONAL for final report

PREFLIGHT_MISSING_OPTIONAL=()
PREFLIGHT_FAILED_MANDATORY=false

preflight() {
  log_warn "[preflight] This script may prompt for user input. Do not leave it unattended."
  log_info "[preflight] checking and installing required tools..."

  _preflight_xcode_clt   # macOS only — must be first (unlocks git, python3, curl)
  _preflight_package_managers
  _preflight_install_mandatory_tools
  _preflight_install_optional_tools
  _preflight_final_report

  [[ "$PREFLIGHT_FAILED_MANDATORY" == true ]] && exit 1
  log_info "[preflight] all mandatory tools ready."
}

# ── Check if tool is already installed (idempotent) ─────────────────────────

_tool_present() {
  command -v "$1" >/dev/null 2>&1
}

# ── macOS: Xcode Command Line Tools ─────────────────────────────────────────

_preflight_xcode_clt() {
  [[ "$OS" == "macos" ]] || return 0
  _tool_present xcode-select && { log_debug "[preflight] Xcode CLT already installed"; return 0; }

  log_info "[preflight] Xcode Command Line Tools needed — installing..."
  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] would install Xcode CLT"; return 0
  fi

  touch /tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
  local prod
  prod=$(softwareupdate -l 2>/dev/null \
    | grep -E '\*.*Command Line Tools' \
    | tail -1 \
    | sed 's/^[^:]*: //')

  if [[ -n "$prod" ]]; then
    softwareupdate -i "$prod" --verbose 2>&1 || {
      log_error "[preflight] Xcode CLT install failed (possibly user cancelled GUI prompt)"
      _prompt_retry_or_abort "[preflight] Xcode CLT" "_preflight_xcode_clt"
      return 0
    }
  else
    xcode-select --install 2>&1 || {
      log_error "[preflight] xcode-select --install failed"
      _prompt_retry_or_abort "[preflight] Xcode CLT" "_preflight_xcode_clt"
      return 0
    }
  fi
}

# ── Install Homebrew (macOS) or verify package manager (Linux) ──────────────

_preflight_package_managers() {
  case "$OS" in
    macos)
      _tool_present brew && { log_debug "[preflight] Homebrew already present"; return 0; }
      log_info "[preflight] installing Homebrew..."
      if [[ "$DRY_RUN" == true ]]; then
        log_info "[dry-run] would install Homebrew"; return 0
      fi
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1 || {
        log_error "[preflight] Homebrew install failed"
        _prompt_retry_or_abort "[preflight] Homebrew" "_preflight_package_managers"
        return 0
      }
      eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null)" || true
      ;;
    linux)
      [[ "$PKG_MANAGER" != "unknown" ]] || {
        log_error "[preflight] No supported package manager found (apt, dnf, pacman)"
        PREFLIGHT_FAILED_MANDATORY=true
      }
      ;;
  esac
}

# ── Install mandatory tools (one at a time, with per-tool retry) ────────────

_preflight_install_mandatory_tools() {
  local mandatory=(git curl python3 rsync)
  local tool
  for tool in "${mandatory[@]}"; do
    _preflight_install_mandatory_tool "$tool"
  done
}

_preflight_install_mandatory_tool() {
  local tool="$1"
  _tool_present "$tool" && { log_debug "[preflight] $tool: already installed"; return 0; }

  log_info "[preflight] installing mandatory tool: $tool"
  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] would install $tool"; return 0
  fi

  case "$OS" in
    macos)  _preflight_install_via_brew "$tool" ;;
    linux)  _preflight_install_via_apt  "$tool" ;;
  esac
}

_preflight_install_via_brew() {
  local tool="$1"
  local formula="$tool"
  [[ "$tool" == "python3" ]] && formula="python@3.11"  # Homebrew formula name differs

  brew install "$formula" 2>&1 || {
    log_error "[preflight] Failed to install $tool via brew"
    _prompt_retry_or_abort "[preflight] $tool" "_preflight_install_via_brew" "$tool"
  }

  if ! _tool_present "$tool"; then
    log_error "[preflight] $tool still not found after brew install"
    PREFLIGHT_FAILED_MANDATORY=true
    log_error "[preflight] Manual intervention needed: run 'brew install $formula' and retry"
  fi
}

_preflight_install_via_apt() {
  local tool="$1"
  local pkg="$tool"
  [[ "$tool" == "python3" ]] && pkg="python3-minimal"

  sudo apt-get update -qq 2>/dev/null
  sudo apt-get install -y "$pkg" 2>&1 || {
    log_error "[preflight] Failed to install $tool via apt"
    _prompt_retry_or_abort "[preflight] $tool" "_preflight_install_via_apt" "$tool"
  }

  if ! _tool_present "$tool"; then
    log_error "[preflight] $tool still not found after apt install"
    PREFLIGHT_FAILED_MANDATORY=true
    log_error "[preflight] Manual intervention needed: run 'sudo apt-get install -y $pkg' and retry"
  fi
}

# ── Install optional tools (failures collected, not fatal) ───────────────────

_preflight_install_optional_tools() {
  _preflight_install_optional_tool "jq"
  _preflight_install_optional_tool "envsubst" "gettext"
}

_preflight_install_optional_tool() {
  local tool="$1"
  local pkg="${2:-$1}"

  _tool_present "$tool" && return 0

  log_info "[preflight] optional tool: installing $tool"
  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] would install $tool"; return 0
  fi

  case "$OS" in
    macos)
      brew install "$pkg" 2>/dev/null || {
        log_warn "[preflight] Failed to install optional $tool via brew (continuing)"
        PREFLIGHT_MISSING_OPTIONAL+=("$tool")
      }
      ;;
    linux)
      sudo apt-get install -y "$pkg" 2>/dev/null || {
        log_warn "[preflight] Failed to install optional $tool via apt (continuing)"
        PREFLIGHT_MISSING_OPTIONAL+=("$tool")
      }
      ;;
  esac
}

# ── Prompt user: retry installation or abort all ──────────────────────────

_prompt_retry_or_abort() {
  local label="$1"
  local retry_fn="$2"
  shift 2
  local args=("$@")

  [[ "$DRY_RUN" == true ]] && return 0
  [[ "$YES" == true ]] && { PREFLIGHT_FAILED_MANDATORY=true; return 0; }

  read -r -p "$label install failed. Retry? [y/N] " ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    log_info "Retrying $label..."
    "$retry_fn" "${args[@]}" || {
      log_error "$label failed again. Cannot continue."
      PREFLIGHT_FAILED_MANDATORY=true
    }
  else
    log_warn "Skipping $label. Install will likely fail downstream."
    PREFLIGHT_FAILED_MANDATORY=true
  fi
}

# ── Final report ──────────────────────────────────────────────────────────

_preflight_final_report() {
  echo
  if [[ ${#PREFLIGHT_MISSING_OPTIONAL[@]} -eq 0 ]]; then
    log_info "[preflight] all optional tools available"
  else
    log_warn "[preflight] some optional tools not available:"
    printf "  - %s\n" "${PREFLIGHT_MISSING_OPTIONAL[@]}"
    log_warn "         Features may be limited (e.g., schedule, jq-based scripts)"
  fi
  echo
}
