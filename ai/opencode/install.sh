#!/usr/bin/env bash
# ai/opencode/install.sh — Opencode environment deployment
# Interface: install_ai_opencode | backup_ai_opencode | status_ai_opencode

OPENCODE_DIR="${HOME}/.config/opencode"
OPENCODE_SRC="${DOTFILES_ROOT}/ai/opencode"

install_ai_opencode() {
  log_info "[ai/opencode] deploying..."
  mkdir -p "$OPENCODE_DIR"

  # Public subtrees: symlink directories
  local sub
  for sub in skills hooks rules; do
    local src="${OPENCODE_SRC}/public/${sub}"
    [[ -d "$src" ]] || continue
    local dest="${OPENCODE_DIR}/${sub}"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
      log_debug "[ai/opencode] $sub already linked"
    else
      backup_file "$dest"
      [[ "$DRY_RUN" == true ]] || { rm -rf "$dest"; ln -s "$src" "$dest"; }
      log_action "symlink" "$dest" "prev" "$src" "" "ok" "rm $dest"
      log_info "[ai/opencode] linked $sub"
    fi
  done

  # Public single files
  local f
  for f in CLAUDE.md AGENTS.md; do
    local src="${OPENCODE_SRC}/public/${f}"
    [[ -f "$src" ]] && create_symlink "$src" "${OPENCODE_DIR}/${f}"
  done

  # Render secret-bearing configs from templates
  for f in opencode.json config.json providers.json mcp.json; do
    local tmpl="${OPENCODE_SRC}/templates/${f}.tmpl"
    [[ -f "$tmpl" ]] || continue
    local dest="${OPENCODE_DIR}/${f}"
    backup_file "$dest"
    render_template "$tmpl" "$dest"
    log_info "[ai/opencode] rendered $f"
  done
}

backup_ai_opencode() {
  log_info "[ai/opencode] capturing from ~/.config/opencode/..."
  local pub="${OPENCODE_SRC}/public"
  local tmpl_dir="${OPENCODE_SRC}/templates"
  mkdir -p "$pub" "$tmpl_dir"

  # Safe public dirs
  local sub
  for sub in skills hooks rules; do
    local src="${OPENCODE_DIR}/${sub}"
    [[ -d "$src" && ! -L "$src" ]] || continue
    [[ "$DRY_RUN" == true ]] || rsync -a --delete "${src}/" "${pub}/${sub}/"
    log_info "[ai/opencode] captured $sub"
  done

  # Public files
  local f
  for f in CLAUDE.md AGENTS.md; do
    [[ -f "${OPENCODE_DIR}/${f}" && ! -L "${OPENCODE_DIR}/${f}" ]] || continue
    [[ "$DRY_RUN" == true ]] || cp "${OPENCODE_DIR}/${f}" "${pub}/${f}"
  done

  # Template-ify secret-bearing JSON configs
  for f in opencode.json config.json providers.json mcp.json; do
    local src="${OPENCODE_DIR}/${f}"
    [[ -f "$src" ]] || continue
    log_info "[ai/opencode] templating $f..."
    [[ "$DRY_RUN" == true ]] || \
      python3 -c "
import json, re, sys
with open('$src') as fh: raw = fh.read()
# Replace anything that looks like a key/token value
def scrub(obj, path=''):
    if isinstance(obj, dict):
        return {k: scrub(v, path+'.'+k) for k,v in obj.items()}
    if isinstance(obj, str) and len(obj) > 20 and re.search(r'[A-Za-z0-9_-]{20,}', obj):
        return '\${' + re.sub(r'[^A-Z0-9_]', '_', path.upper().strip('.')) + '}'
    return obj
d = json.loads(raw)
print(json.dumps(scrub(d), indent=2))
" > "${tmpl_dir}/${f}.tmpl" 2>/dev/null || cp "$src" "${tmpl_dir}/${f}.tmpl"
  done
}

status_ai_opencode() {
  local items=(skills hooks rules CLAUDE.md opencode.json mcp.json)
  local item
  for item in "${items[@]}"; do
    local p="${OPENCODE_DIR}/${item}"
    if [[ -L "$p" ]]; then echo "  opencode/$item → $(readlink "$p") [symlink]"
    elif [[ -e "$p" ]]; then echo "  opencode/$item [exists]"
    else echo "  opencode/$item [MISSING]"
    fi
  done
}
