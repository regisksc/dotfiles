#!/usr/bin/env bash
# secrets.sh — templating + basic secret scanning.
#
# Templates use ${VAR} substitution from env + $DOTFILES_ROOT/.env.local
# (which is gitignored).

_load_local_env() {
  local env_file="${DOTFILES_ROOT}/.env.local"
  [[ -f "$env_file" ]] || return 0
  set -a
  # shellcheck disable=SC1090
  . "$env_file"
  set +a
}

render_template() {
  local in="$1" out="$2"

  if [[ "$DRY_RUN" == true ]]; then
    log_info "[dry-run] would render $in -> $out"
    return 0
  fi

  _load_local_env

  # Collect only the ${UPPER_VARS} present in the template so envsubst
  # does not eat unrelated $ patterns like JSON "$schema" fields.
  local vars
  vars="$(grep -oE '\$\{[A-Z_][A-Z0-9_]*\}' "$in" | sort -u | tr '\n' ',')"

  if command -v envsubst >/dev/null 2>&1; then
    envsubst "$vars" < "$in" > "$out"
  else
    # fallback: manual ${VAR} substitution only
    local content; content="$(cat "$in")"
    while IFS= read -r var; do
      local val="${!var:-}"
      content="${content//\$\{${var}\}/$val}"
    done < <(grep -oE '\$\{[A-Z_][A-Z0-9_]*\}' "$in" | tr -d '${}' | sort -u)
    printf '%s' "$content" > "$out"
  fi
  log_action "template" "$out" "absent" "rendered" "" "ok" "rm $out"
}

# secret_scan <path> — returns non-zero if likely secrets are found.
secret_scan() {
  local root="$1"
  log_info "secret_scan: $root"
  local patterns=(
    'AKIA[0-9A-Z]{16}'                       # AWS access key
    'sk-[A-Za-z0-9]{32,}'                    # OpenAI-ish
    'ghp_[A-Za-z0-9]{36}'                    # GitHub PAT
    'xox[baprs]-[A-Za-z0-9-]{10,}'           # Slack
    '-----BEGIN (RSA|OPENSSH|EC|DSA) PRIVATE KEY-----'
  )
  local hits=0
  local p
  for p in "${patterns[@]}"; do
    if grep -REn --exclude-dir=.git --exclude-dir=backups --exclude-dir=logs \
         --exclude=".env.local" "$p" "$root" >/dev/null 2>&1; then
      log_error "Potential secret matching /$p/ found."
      hits=$((hits+1))
    fi
  done
  return $hits
}
