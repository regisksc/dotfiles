#!/usr/bin/env bash
# ai.sh — AI tooling deployment (skills, hooks, MCP, plugin/app config).
#
# Each subtree under ai/ declares how its contents should be deployed via
# a MANIFEST file (shell k=v). Supported keys:
#   TARGET=~/.config/xyz         # deploy dest (required)
#   MODE=symlink|copy|template   # default symlink
#   CLASSIFY=public|template|private|ignore   # default public

install_ai_tooling() {
  log_info "install_ai_tooling"
  local base="${DOTFILES_ROOT}/ai"
  [[ -d "$base" ]] || { log_warn "ai/ directory missing"; return 0; }

  local sub
  for sub in "$base"/*/; do
    [[ -d "$sub" ]] || continue
    _deploy_ai_subtree "$sub"
  done
}

_deploy_ai_subtree() {
  local sub="$1"
  local manifest="${sub}MANIFEST"
  local name; name="$(basename "$sub")"

  if [[ ! -f "$manifest" ]]; then
    log_warn "ai/$name: MANIFEST missing, skipping"
    return 0
  fi

  # shellcheck disable=SC1090
  local TARGET="" MODE="symlink" CLASSIFY="public"
  . "$manifest"
  TARGET="${TARGET/#\~/$HOME}"

  case "$CLASSIFY" in
    ignore)   log_info "ai/$name: CLASSIFY=ignore, skipping"; return 0 ;;
    private)  log_warn "ai/$name: CLASSIFY=private — ensure not committed" ;;
  esac

  case "$MODE" in
    symlink) link_package "$sub" ;;  # uses home-relative layout
    copy)    _run mkdir -p "$TARGET" && _run cp -a "$sub"/. "$TARGET/" ;;
    template) _deploy_ai_templates "$sub" "$TARGET" ;;
    *) log_warn "ai/$name: unknown MODE=$MODE" ;;
  esac
}

_deploy_ai_templates() {
  local src="$1" dest="$2"
  mkdir -p "$dest"
  local f rel out
  while IFS= read -r -d '' f; do
    rel="${f#"$src"/}"
    out="${dest}/${rel%.tmpl}"
    if [[ "$DRY_RUN" == true ]]; then
      log_info "[dry-run] would render $f -> $out"
    else
      mkdir -p "$(dirname "$out")"
      render_template "$f" "$out"
    fi
  done < <(find "$src" -type f -name '*.tmpl' -print0)
}
